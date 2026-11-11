// mic-test.swift — record N seconds from the default input and measure signal level.
// Usage: mic-test [seconds=4] [out.wav]
//
// Prints RMS and peak dBFS, writes a standard 16-bit PCM WAV.
//   RMS <= -80 dBFS → digital silence (device opened, no signal)
//   RMS >= -55 dBFS → clear signal (speech/music)
//
// The WAV is written explicitly in the timer block: calling exit() straight
// after the capture would skip AVAudioFile's flush and leave a header with
// zero frames.

import AVFoundation
import Foundation

let args = CommandLine.arguments
let seconds = args.count > 1 ? Double(args[1]) ?? 4 : 4
let outPath = args.count > 2 ? args[2] : "mic-test.wav"
let fmt = { (_ s: String) in FileHandle.standardOutput.write((s + "\n").data(using: .utf8)!) }
let sema = DispatchSemaphore(value: 0)

let status = AVCaptureDevice.authorizationStatus(for: .audio)
fmt("authStatus: \(status.rawValue)  (0=notDetermined 1=restricted 2=denied 3=authorized)")
if status != .authorized {
    AVCaptureDevice.requestAccess(for: .audio) { granted in
        fmt("permission granted: \(granted)")
        sema.signal()
    }
    sema.wait()
    guard AVCaptureDevice.authorizationStatus(for: .audio) == .authorized else {
        fmt("FAIL: microphone permission denied — grant it to this terminal app and re-run")
        exit(1)
    }
} else {
    fmt("permission: already granted")
}

let engine = AVAudioEngine()
let input = engine.inputNode
let hwFormat = input.inputFormat(forBus: 0)
fmt("input hardware format: \(hwFormat.sampleRate) Hz, \(hwFormat.channelCount) ch")
guard hwFormat.sampleRate > 0, hwFormat.channelCount > 0 else {
    fmt("FAIL: input node reports no channels — no mic hardware exposed")
    exit(1)
}

let recFormat = AVAudioFormat(standardFormatWithSampleRate: hwFormat.sampleRate, channels: 1)!
var sumSq = 0.0
var peak = 0.0
var frames = 0
var captured: [Float] = []
let lock = NSLock()

input.installTap(onBus: 0, bufferSize: 4096, format: recFormat) { buffer, _ in
    guard let ch = buffer.floatChannelData?[0] else { return }
    let n = Int(buffer.frameLength)
    lock.lock()
    for i in 0..<n {
        let v = ch[i]
        sumSq += Double(v * v)
        let a = abs(Double(v))
        if a > peak { peak = a }
        captured.append(v)
    }
    frames += n
    lock.unlock()
}

engine.prepare()
do { try engine.start() } catch {
    fmt("FAIL: engine start error: \(error)")
    exit(1)
}
fmt("REC ⏺  recording for \(Int(seconds)) s…")

DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
    input.removeTap(onBus: 0)
    engine.stop()

    lock.lock()
    let samples = captured
    let n = frames
    let rms = n > 0 ? sqrt(sumSq / Double(n)) : 0
    let pk = peak
    lock.unlock()

    // ---- write a valid 16-bit PCM mono WAV -------------------------------
    var data = Data()
    func le32(_ v: UInt32) { var x = v.littleEndian; withUnsafeBytes(of: &x) { data.append(contentsOf: $0) } }
    func le16(_ v: UInt16) { var x = v.littleEndian; withUnsafeBytes(of: &x) { data.append(contentsOf: $0) } }
    let sr = UInt32(hwFormat.sampleRate)
    let dataSize = UInt32(samples.count * 2)
    data.append(contentsOf: Array("RIFF".utf8)); le32(36 + dataSize)
    data.append(contentsOf: Array("WAVE".utf8))
    data.append(contentsOf: Array("fmt ".utf8)); le32(16); le16(1); le16(1)
    le32(sr); le32(sr * 2); le16(2); le16(16)
    data.append(contentsOf: Array("data".utf8)); le32(dataSize)
    for v in samples {
        let clamped = max(-1.0, min(1.0, Double(v)))
        le16(UInt16(bitPattern: Int16(clamped * 32767.0)))
    }
    try? data.write(to: URL(fileURLWithPath: outPath))

    let toDb: (Double) -> String = { x in x <= 0 ? "-inf" : String(format: "%.1f", 20 * log10(x)) }
    fmt("REC ⏹  done: \(n) frames, \(String(format: "%.1f", Double(n) / hwFormat.sampleRate)) s captured")
    fmt("level:  RMS \(toDb(rms)) dBFS   peak \(toDb(pk)) dBFS")

    if n == 0 {
        fmt("verdict: NO DATA — tap delivered nothing")
        exit(2)
    } else if rms <= pow(10, -80 / 20) {
        fmt("verdict: SILENT — device opened but delivers no signal")
    } else if rms >= pow(10, -55 / 20) {
        fmt("verdict: SIGNAL DETECTED — microphone is capturing audio")
    } else {
        fmt("verdict: WEAK SIGNAL — near the noise floor; speak louder and re-run")
    }
    fmt("saved: \(outPath)")
    exit(0)
}
dispatchMain()
