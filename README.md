# QuantD Cloud Native Linux

QuantD Cloud Native Linux is an open-source, Debian-based Linux distribution designed for cloud-native learning and development.

It provides a practical, ready-to-use developer workstation image for experimenting with Kubernetes, container runtimes, and modern infrastructure tooling — without the repetitive system setup typically required on general-purpose distributions.

---

## Purpose

Modern cloud-native workflows require consistent system configuration, container tooling, and Kubernetes-compatible defaults. While general-purpose Linux distributions are flexible, developers often spend significant time reconfiguring the same environment across machines.

QuantD focuses on:

- Providing a reproducible Debian-based developer desktop image  
- Offering sensible defaults for container and Kubernetes experimentation  
- Reducing friction for students and engineers learning platform workflows  
- Maintaining a transparent and community-buildable ISO pipeline  

---

## Scope

QuantD is intended as:

- A personal and community-driven learning project  
- A developer-focused workstation environment  
- A lightweight cloud-native lab system  

It is not positioned as an enterprise Linux replacement or production server distribution.

---

## Objectives

**QuantD Cloud Native Linux** aims to provide:

- A reproducible Debian-based developer workstation image  
- Practical defaults for container and Kubernetes development  
- A clear path from local development to platform engineering workflows  
- An easy-to-build, community-maintained ISO pipeline  

---

## Current Status

This repository currently builds a Debian 13 (Trixie)-based live ISO using `live-build`, with:

- MATE desktop environment  
- PipeWire audio stack  
- Bluetooth support  
- Live boot + Calamares installer integration  
- Reproducible build configuration in `config/`  

## Desktop ISO: Cloud-Native Tooling Included

The current desktop profile includes support for:

### 1) Kubernetes development and local cluster testing

- `kubectl`
- `kustomize`
- `kind`

### 2) Container runtime experimentation

- `containerd`
- `podman`, `podman-compose`
- `buildah`, `skopeo`
- OCI runtimes: `runc`, `crun`
- CNI plugins: `containernetworking-plugins`
- Container UI: `cockpit` + `cockpit-podman` (web console for container management)

> `CRI-O` integration is on the roadmap and may be provided via an optional profile/repository path in a future release.

### 3) Platform engineering and infrastructure workflows

- `ansible`
- `ansible-lint`
- `terraform-switcher` (for Terraform version management)

### 4) DevOps automation and Infrastructure-as-Code practices

- `jq`, `yq`
- `yamllint`
- `shellcheck`

### 5) Reproducible development environments

- `direnv`
- `vagrant`

### 6) Cloud-native language and build toolchains

- `golang-go`
- `default-jdk`
- `maven`
- `gradle`

### 7) Code editor experience

- `geany`
- `kate`
- `neovim`

Preferred open-source VS Code-compatible option: **VSCodium (`codium`)** via optional external repository profile.

Example optional enablement (host/chroot profile step):

```bash
wget -qO - https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/raw/master/pub.gpg \
  | gpg --dearmor \
  | sudo tee /usr/share/keyrings/vscodium-archive-keyring.gpg >/dev/null

echo 'deb [signed-by=/usr/share/keyrings/vscodium-archive-keyring.gpg] https://download.vscodium.com/debs vscodium main' \
  | sudo tee /etc/apt/sources.list.d/vscodium.list

sudo apt update
sudo apt install -y codium
```

---

## Cloud-Native Direction (Planned)

Planned enhancements include curated profiles for tools such as:

- Expanded Kubernetes ecosystem (`helm`, additional debugging and cluster tooling)
- Additional runtime options (`CRI-O`, `nerdctl`, and advanced runtime tuning)
- Platform engineering helpers (GitOps, observability, policy, and broader IaC tooling)
- Optional role-based profiles (developer laptop, SRE workstation, platform builder)

> These capabilities are planned and will be introduced incrementally through package lists, hooks, and documented profiles.

---

## Repository Layout

```text
.
├── config/
│   ├── binary                  # binary-stage live-build options
│   ├── bootstrap               # bootstrap-stage options
│   ├── chroot                  # chroot-stage options
│   ├── common                  # shared live-build options
│   ├── source                  # source-stage options
│   ├── hooks/                  # build hooks
│   ├── includes.chroot/        # files copied into chroot
│   └── package-lists/          # package sets (*.list.chroot)
├── LICENSE.md
└── README.md
```

---

## Build Requirements

Use a Debian-based host and install:

```bash
sudo apt update
sudo apt install -y live-build xorriso curl wget git
```

---

## Build the ISO

From the repository root:

```bash
sudo lb clean --purge
lb config \
  --distribution trixie \
  --debian-installer live \
  --archive-areas "main contrib non-free non-free-firmware" \
  --binary-images iso-hybrid \
  --mirror-bootstrap http://deb.debian.org/debian/ \
  --mirror-binary http://deb.debian.org/debian/ \
  --mirror-chroot http://deb.debian.org/debian/ \
  --mirror-binary-security http://security.debian.org/ \
  --mirror-chroot-security http://security.debian.org/ \
  --bootappend-live "boot=live components quiet splash hostname=quantd user=quantd"  
sudo lb build
```

Expected output:

```text
live-image-amd64.hybrid.iso
```

---

## Test the ISO

### QEMU

```bash
qemu-system-x86_64 -cdrom live-image-amd64.hybrid.iso -m 4096
```

### USB (be careful with target disk)

```bash
sudo dd if=live-image-amd64.hybrid.iso of=/dev/sdX bs=4M status=progress oflag=sync
```

Replace `/dev/sdX` with the correct USB device.
---
## 📷 Screenshots
![Quantd Linux Boot](https://i.postimg.cc/rFMxsnL2/Screenshot-at-2026-03-01-21-29-38.png)  
![Quantd Linux Desktop](https://i.postimg.cc/cL5nDdtL/Screenshot-at-2026-03-01-21-30-20.png)  
![Quantd Linux Terminal](https://i.postimg.cc/Kz5Rspc6/Screenshot-at-2025-08-08-12-11-08.png)  
![Quantd Linux System](https://i.postimg.cc/cCb1VVpb/Screenshot-at-2025-08-08-12-09-55.png)  
![Control Center](https://i.postimg.cc/sXbmbpBM/Screenshot-at-2026-03-01-21-35-17.png)
![Package Manager](https://i.postimg.cc/PqxMx6YX/Screenshot-at-2026-03-01-21-34-57.png)
![Bluetooth Adaptors](https://i.postimg.cc/wMK5wgP4/Screenshot-at-2026-03-01-21-34-26.png)
![Installer](https://i.postimg.cc/vHt7vRv7/Screenshot-at-2026-03-01-21-33-37.png)
![Container Tools](https://i.postimg.cc/fLdmt1LM/Screenshot-at-2026-03-01-21-32-20.png)

---

## Download

You can download the latest stable release of QuantD Cloud Native Linux from:

**https://github.com/quantdlinux/quantd-iso/releases/latest**

Each release includes:

- The QuantD ISO image
- SHA256 checksum file

---

## Verify Download

After downloading the ISO, verify its integrity using the SHA256 checksum:

```bash
sha256sum quantd-<version>.iso
```
Each release includes:

- The ISO image
- SHA256 checksum file
---

## License

QuantD Cloud Native Linux is licensed under the **Apache License 2.0**.
See [LICENSE.md](LICENSE.md) for details.

## Disclaimer

QuantD is an independent personal open-source project.
It is not affiliated with, endorsed by, or related to Oracle Corporation.
All development is performed independently and outside of any employment duties.