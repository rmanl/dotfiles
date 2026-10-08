# ❄️ NixOS installation

## Remote installation

> [!NOTE]
> Disable secureboot on target device

**1. Login to bootstrapped ISO and setup connection**

- Wired should be connected, for wifi use nmcli

```console
ip a
nmcli device wifi connect <SSID> password <PASSWORD>
```

- Remove old boot options

```console
efibootmgr -b <NUMBER> -B
```

**2. Build minimal config**

```console
just bootstrap
```

> [!NOTE]
> You'll be prompted for the target hostname and IP.

> [!CAUTION]
> After reboot check connection (reconnect if on wifi). The IP has to match the
> target IP from step 2, if it doesn't reboot again.

**3. Create keys for secure boot (optional)**

```console
nix-shell -p sbctl
sudo sbctl create-keys
```

**4. Copy host ssh id & temp config**

- From host copy the ssh id to target

```console
sftp <user>@<TARGET IP>
put .ssh/id_<USER>*
```

- On target copy the config file

```console
cp <REPO>/installer/config ~/.ssh
```

**5. Build config**

```console
just rebuild
reboot
```

> [!NOTE]
> When no devshell available run `nix develop` and then rebuild

**6. Secure boot with lanzaboote (optional, requires step 3)**

https://github.com/nix-community/lanzaboote/blob/master/docs/QUICK_START.md

- Edit bios
  - Set admin password
  - Enable secure boot in setup mode
- Check machine is ready
  - `sudo sbctl verify`
- Enroll keys (depends on system)
  - `sudo sbctl enroll-keys --microsoft`

## After install (optional)

**Change luks password**

```console
# test current passphrase
sudo cryptsetup --verbose open --test-passphrase /path/to/dev/

# change the passphrase
sudo cryptsetup luksChangeKey /path/to/dev/
```

## New device setup

**1. Get drive by-id(s)**

```console
# list devices
sudo ls -la /dev/disk/by-id

# example name
nvme-eui.002538554140fdb5
```

## Windows Boot Manager on multi-disk systems

**1. Find Windows EFI Partition**

```console
lsblk -o NAME,FSTYPE,SIZE,MOUNTPOINT
```

**2. Mount Windows EFI Partition**

```console
sudo mkdir -p /mnt/win-efi
sudo mount -o ro /dev/<DISK> /mnt/win-efi
```

**3. Copy Contents of Windows EFI to NixOS EFI**

```console
sudo rsync -av /mnt/win-efi/EFI/Microsoft /boot/EFI/
```

**4. Clean up**

```console
sudo umount /mnt/win-efi
sudo rm -rf /mnt/win-efi
```
