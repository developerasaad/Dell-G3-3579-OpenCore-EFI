#!/bin/bash
# mic-test.sh — guided microphone check.
#
# Reproduces the four measurements taken on this laptop:
#   quiet vs. sound source, at the default input volume vs. 100 %.
# Each test waits for Enter before recording. WAV files are kept so you can
# listen to them afterwards.
#
# Usage: bash mic-test.sh
#
# Needs the `mic-test` helper next to this script (or mic-test.swift + swiftc).

set -u

DIR="$(cd "$(dirname "$0")" && pwd)"
BIN="$DIR/mic-test"
SRC="$DIR/mic-test.swift"
STAMP=$(date +%Y%m%d-%H%M%S)
OUT="$HOME/Desktop/mic-test-$STAMP"
mkdir -p "$OUT"

# ---- prerequisites -------------------------------------------------------
if [ ! -x "$BIN" ]; then
    if command -v swiftc >/dev/null 2>&1 && [ -f "$SRC" ]; then
        echo "compiling mic-test.swift…"
        swiftc -O "$SRC" -o "$BIN" || { echo "compile failed"; exit 1; }
    else
        echo "mic-test helper not found next to this script (no binary, no swiftc)."
        exit 1
    fi
fi

ORIG_VOL=$(osascript -e 'input volume of (get volume settings)' 2>/dev/null || true)
case "${ORIG_VOL:-}" in ''|*[!0-9]*) ORIG_VOL=100 ;; esac

# Abort early if the audio HAL has no input device at all.
if ! system_profiler SPAudioDataType 2>/dev/null | grep -q "Built-in Microphone"; then
    echo "ERROR: macOS reports no audio input device."
    echo "       If sound is broken system-wide, restart coreaudiod:  sudo killall coreaudiod"
    exit 1
fi

echo "=============================================================="
echo " Microphone test — $(scutil --get ComputerName 2>/dev/null || hostname)"
echo " macOS $(sw_vers -productVersion) ($(sw_vers -buildVersion))   $(date '+%Y-%m-%d %H:%M')"
echo "=============================================================="
system_profiler SPAudioDataType 2>/dev/null | awk '
    /Built-in Microphone:/ { f=1 }
    f && /Input Source|Input Channels|Current SampleRate|Default Input Device/ { print "  " $0 }
    f && /Built-in Line Input:/ { exit }'
echo "  default input volume: ${ORIG_VOL}%"
echo "  reports: $OUT"
echo
echo "  Four tests, Enter before each one:"
echo "    1)  quiet,          default volume"
echo "    2)  make noise,     default volume"
echo "    3)  quiet,          100% volume"
echo "    4)  make noise,     100% volume"
echo

# Treat "-inf" as a very low number so comparisons stay numeric.
num() { case "${1:-}" in ""|"-inf") echo -999 ;; *) echo "$1" ;; esac; }

run() {   # run <no> <title> <volume> <seconds> <file> <varprefix>
    local n="$1" title="$2" vol="$3" secs="$4" file="$5" prefix="$6" out
    case "$vol" in ''|*[!0-9]*) vol=100 ;; esac
    echo "--------------------------------------------------------------"
    echo "$n)  $title  —  input ${vol}%, ${secs} s"
    osascript -e "set volume input volume $vol" >/dev/null 2>&1
    read -r -p "    Press Enter to start (Ctrl-C aborts)… " _
    for i in 3 2 1; do printf "    %s…\n" "$i"; sleep 1; done
    out=$("$BIN" "$secs" "$OUT/$file" 2>&1)
    echo "$out" | grep -E "input hardware format|level:|verdict:" | sed 's/^/    /'
    if echo "$out" | grep -q "0 ch"; then
        echo "    no input channels — audio subsystem problem. Try: sudo killall coreaudiod"
    fi
    eval "${prefix}_RMS=\$(echo \"\$out\" | awk '/^level:/{print \$3}')"
    eval "${prefix}_PEAK=\$(echo \"\$out\" | awk '/^level:/{print \$6}')"
    echo
}

run 1 "stay quiet — default volume"  "$ORIG_VOL" 5 "1-quiet-default.wav" T1
run 2 "make noise — default volume"  "$ORIG_VOL" 6 "2-sound-default.wav" T2
run 3 "stay quiet — 100% volume"     100         5 "3-quiet-100.wav"     T3
run 4 "make noise — 100% volume"     100         6 "4-sound-100.wav"     T4

# ---- summary -------------------------------------------------------------
echo "=============================================================="
echo " RESULTS"
echo "=============================================================="
printf "  %-4s %-30s %10s %10s\n" "test" "condition" "RMS dBFS" "peak dBFS"
printf "  %-4s %-30s %10s %10s\n" "1" "quiet, ${ORIG_VOL}%"     "${T1_RMS:-?}" "${T1_PEAK:-?}"
printf "  %-4s %-30s %10s %10s\n" "2" "noise, ${ORIG_VOL}%"     "${T2_RMS:-?}" "${T2_PEAK:-?}"
printf "  %-4s %-30s %10s %10s\n" "3" "quiet, 100%"             "${T3_RMS:-?}" "${T3_PEAK:-?}"
printf "  %-4s %-30s %10s %10s\n" "4" "noise, 100%"             "${T4_RMS:-?}" "${T4_PEAK:-?}"
echo

V4=$(num "${T4_RMS:-}")
if awk "BEGIN{exit !($V4 >= -55)}"; then
    echo "  VERDICT: microphone captures audio."
elif awk "BEGIN{exit !($V4 <= -80)}"; then
    echo "  VERDICT: no signal — device opened but delivered silence."
    echo "           Check System Settings → Sound → Input, and that the level meter moves."
else
    echo "  VERDICT: weak signal — something is captured but near the noise floor."
    echo "           Make the sound louder / closer and repeat test 4."
fi
echo "  Note: if test 4 is clear but test 2 is near-silent, that is the documented"
echo "        ALC236 gain behaviour — keep the input volume near maximum."

# ---- playback ------------------------------------------------------------
echo
read -r -p "  Press Enter to play back test 4 (Ctrl-C to skip)… " _ || true
if [ -f "$OUT/4-sound-100.wav" ] && afplay "$OUT/4-sound-100.wav" 2>/dev/null; then
    echo "  played: $OUT/4-sound-100.wav"
fi

# ---- volume --------------------------------------------------------------
echo
read -r -p "  Keep input volume at 100%? [K/r] " ans || true
case "${ans:-}" in
    r|R) osascript -e "set volume input volume $ORIG_VOL" >/dev/null 2>&1
         echo "  restored ${ORIG_VOL}%" ;;
    *)   echo "  left at 100%" ;;
esac

echo
echo "  WAV files: $OUT"
