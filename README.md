<div align="center">

# AnyDesk Legacy for Debian

**One-command installer for the legacy AnyDesk 6.0.1 (AMD64) on Debian.**

![AnyDesk](https://img.shields.io/badge/AnyDesk-6.0.1-ef443b?style=for-the-badge)
![Debian](https://img.shields.io/badge/Debian-13_Trixie-a81d33?style=for-the-badge&logo=debian&logoColor=white)
![Arch](https://img.shields.io/badge/arch-amd64-blue?style=for-the-badge)
![License](https://img.shields.io/badge/scripts-MIT-green?style=for-the-badge)

[Quick start](#-quick-start) · [Usage](#-usage) · [Remote access](#-remote-access-over-ssh) · [Security](#-security) · [Licensing](#-licensing)

</div>

---

## Features

- Original AnyDesk 6.0.1 binary
- SHA512 verification of the AnyDesk package
- GTK2 and PangoX compatibility libraries installed automatically
- Automatic APT dependency handling
- Systemd service, enabled at boot
- Included uninstaller

## Supported platforms

| OS                    | Architecture | Status         |
| --------------------- | ------------ | -------------- |
| Debian 13 Trixie      | AMD64        | ✅ Tested      |
| Debian 12 Bookworm    | AMD64        | ⚠️ Not tested  |
| Other Debian versions | AMD64        | ⚠️ Not tested  |
| Other architectures   | Any          | ❌ Unsupported |

---

## Quick start

### Install

```bash
curl -fsSL https://raw.githubusercontent.com/ChandanShakya/anydesk-legacy-debian/main/install.sh | bash
```

<details>
<summary>Or clone and run</summary>

```bash
git clone https://github.com/ChandanShakya/anydesk-legacy-debian.git
cd anydesk-legacy-debian
chmod +x install.sh
./install.sh
```

</details>

### Uninstall

```bash
curl -fsSL https://raw.githubusercontent.com/ChandanShakya/anydesk-legacy-debian/main/uninstall.sh | bash
```

<details>
<summary>Or from a clone</summary>

```bash
chmod +x uninstall.sh
./uninstall.sh
```

</details>

> [!NOTE]
> Compatibility libraries are kept on uninstall because other applications may use them.

---

## Usage

| Task                    | Command                    |
| ----------------------- | -------------------------- |
| Get AnyDesk ID          | `anydesk --get-id`         |
| Check service           | `systemctl status anydesk` |
| Check connection status | `anydesk --get-status`     |
| Launch the GUI          | `anydesk`                  |

---

## Remote access over SSH

The ID can be read from the terminal. A password cannot be read back, only set, so choose one and set it.

### Set your own password

Inside an SSH session (or any local terminal):

```bash
read -rsp 'AnyDesk password: ' PW; echo
echo "$PW" | sudo anydesk --set-password
echo "ID: $(anydesk --get-id)"
```

From another machine, in a single command:

```bash
ssh -t user@host 'read -rsp "AnyDesk password: " PW; echo; echo "$PW" | sudo anydesk --set-password; echo "ID: $(anydesk --get-id)"'
```

### Or generate a random password

```bash
PW="$(openssl rand -base64 18)"
echo "$PW" | sudo anydesk --set-password
echo "ID: $(anydesk --get-id)  Password: $PW"
```

> [!TIP]
> `read -rs` keeps your password off the screen and out of shell history. Avoid typing it inline in a command.

> [!NOTE]
> The `anydesk` service must be running. If `--get-id` fails, try it with `sudo`. If `--set-password` is not supported by your build, set the password once in the AnyDesk GUI settings.

---

## Security

> [!WARNING]
> AnyDesk 6.0.1 is an old release and may contain unpatched vulnerabilities. Do not expose unattended access without a strong password.

- The AnyDesk binary is verified against the SHA512 checksum from the AUR PKGBUILD.
- Compatibility packages are checked for expected package name, version and architecture, but are not independently checksum-pinned in this version.

---

## Package sources

| Package                  | Source                                                                                                                            |
| ------------------------ | --------------------------------------------------------------------------------------------------------------------------------- |
| AnyDesk 6.0.1 (archived) | [web.archive.org](https://web.archive.org/web/20230419070452if_/https://download.anydesk.com/linux/deb/anydesk_6.0.1-1_amd64.deb) |
| GTKGLExt                 | [deb.debian.org](https://deb.debian.org/debian/pool/main/g/gtkglext/)                                                             |
| PangoX                   | [deb.debian.org](https://deb.debian.org/debian/pool/main/p/pangox-compat/)                                                        |

---

## Licensing

AnyDesk is proprietary software owned by AnyDesk Software GmbH.

This repository provides installation automation only. It does not modify, crack or redistribute the AnyDesk executable. Users must comply with AnyDesk's applicable licence and terms of use. No guarantee is made about commercial-use warnings or timeouts.

The installation scripts are provided under the [MIT License](LICENSE).
