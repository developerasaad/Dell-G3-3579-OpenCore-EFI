# SMBIOS Setup

## What's in the shipped config

Both EFIs ship with a **sample** platform identity for `MacBookPro15,2`,
generated with `macserial`. It is structurally valid, so the EFI boots and macOS
runs normally.

It is a **disposable sample, not a personal identity**. Don't use it with Apple
services (iMessage, FaceTime, App Store) and don't rely on it long-term —
regenerate your own before relying on the machine.

## Generate your own

Use [GenSMBIOS](https://github.com/corpnewt/GenSMBIOS) or `macserial` to generate
a serial, MLB and ROM for `MacBookPro15,2`, plus a fresh UUID:

```bash
# macOS, using macserial
macserial --generate --model MacBookPro15,2 --num 1
```

Then edit `EFI/OC/config.plist` → `PlatformInfo/Generic` and set:

| Key | What to put |
|-----|-------------|
| `SystemSerialNumber` | your generated serial |
| `MLB` | your generated MLB |
| `SystemUUID` | your own UUID (`uuidgen`) |
| `ROM` | 6-byte MAC or random data |

Generate a **separate** identity per installed macOS so the two installs don't
share one identity.

## Why this matters

- A serial that belongs to another machine can break iServices and App Store
  purchases, and can cause activation conflicts.
- Sharing one serial across multiple people/machines causes the same problems.
- The shipped sample is fine for boot testing; replace it when you start using
  Apple services.

## Boot safety

- Back up the existing EFI before writing anything to an EFI partition.
- Keep a USB OpenCore stick as a recovery path.
- Test a new EFI from USB first; install it to the internal EFI partition only
  after it boots reliably.
- On a multiboot machine, don't delete the Windows (`Microsoft/`) or vendor
  (`Dell/`) folders from the EFI partition — they belong to other operating
  systems.
