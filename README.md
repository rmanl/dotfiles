# ❄️ NixOS installation

## Remote installation

> [!NOTE]
> Disable secureboot on target device

**1. Login to bootstrapped ISO and setup connection

- Wired should be connected, for wifi use nmcli

```console
ip a
nmcli device wifi connect <SSID> password <PASSWORD>
```

- Remove old boot options

```console
efibootmgr -b <NUMBER> -B
```

**2. Build minimal config

- Single drive systems

```console
./scripts/bootstrap-nixos.sh -n <HOSTNAME> -d <TARGET IP> -k ~/.ssh/id_<USER>
```

- Multi drive systems, use drive labels that are declared in the disko config
  file

```console
./scripts/bootstrap-nixos.sh -n <HOSTNAME> -d <TARGET IP> -k ~/.ssh/id_<USER> --luks-secondary-drive-labels <DRIVELABEL1>,<DRIVELABEL2>
```

> [!CAUTION]
> After reboot check connection(reconnect if on wifi) The ip has to match the
> target ip from step 2, if it doesn't reboot again.

**3. Create keys for secure boot(optional)

```console
nix-shell -p sbctl
sudo sbctl create-keys
```

**4. Copy host ssh id & temp config

- From host copy the ssh id to target

```console
sftp <user>@<TARGET IP>
put .ssh/id_<USER>*
```

- On target copy the config file

```console
cp nix-config/installer/config ~/.ssh
```

**5. Build config

```console
just rebuild
reboot
```

> [!NOTE]
> when no devshell availabe run `nix develop` and than rebuild

**6. Secure boot with lanzaboote(optional, requires step 3)**
https://github.com/nix-community/lanzaboote/blob/master/docs/QUICK_START.md

- edit bios
  - set admin password
  - enable secure boot in setup mode
- check machine is ready
  - `sudo sbctl verify`
- enroll keys(depends on system)
  - `sudo sbctl enroll-keys --microsoft`

## After install(optional)

**Change luks password

```console
# test current passphrase
sudo cryptsetup --verbose open --test-passphrase /path/to/dev/

# change the passphrase
sudo cryptsetup luksChangeKey /path/to/dev/
```

## New device setup

**1. Get drive by-id(s)

```console
# list devices
sudo ls -la /dev/disk/by-id

# example name
nvme-eui.002538554140fdb5
```

## Windows Boot Manager on multi-disk systems

**1. Find Windows EFI Partition

```console
lsblk -o NAME,FSTYPE,SIZE,MOUNTPOINT
```

**2. Mount Windows EFI Partition

```console
sudo mkdir -p /mnt/win-efi
sudo mount /dev/<DISK> /mnt/win-efi
```

**3. Copy Contents of Windows EFI to NixOS EFI

```console
sudo rsync -av /mnt/win-efi/EFI/Microsoft /boot/EFI/
```

**4. Clean up

```console
sudo umount /mnt/win-efi
sudo rm -rf /mnt/win-efi
```
