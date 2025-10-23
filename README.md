# Workstation setup

## Intial setup
After the system has been installed, the [setup script](scripts/initial-setup.sh) can be ran to handle
some basic tasks such as installing frequently used applications (chrome, vlc, gear-lever) and utilities
(google fonts, codecs). Run the script using the following command:

```sh
bash <(curl -s https://raw.githubusercontent.com/Stager-Software/workstation-setup/refs/heads/main/scripts/initial-setup.sh)
```

## Updating encryption
All Stager workstations use disk encryption by default. OpenSUSE handles this using LUKS. For some reason,
OpenSUSE comes with an absurd (between 6 and 8 million) LUKS iteration count by default, meaning that
decryption takes a very long time during startup. We prefer to lower this to a sensible count. A minimum
of 1000 is recommended as per [RFC 2898](https://datatracker.ietf.org/doc/html/rfc2898). We choose to do
200000, as it is still extremely safe while being much less than the OpenSUSE default, thus speeding up
the boot process.

You first need to determine which device is your LUKS encrypted device on your system. Do this by running `lsblk -f`.
This will return a list of your devices. One of these should have either `crypto` or `crypto_LUKS` in the `FSTYPE`
column. This will most likely be your LUKS device. In the example below, it would be `/dev/nvme0n1p2`. Remember the
device for further use.
```sh
NAME                    FSTYPE FSVER LABEL UUID                                   MOUNTPOINTS
nvme0n1
├─nvme0n1p1             vfat   FAT32       1AB2-1234                              /boot/efi
└─nvme0n1p2             crypto 2           1234abcd-5678-efgh-ijkl-9876mnopqrst
```

You can verify the LUKS device by running `sudo cryptsetup luksDump /dev/nvme0n1p2`.A LUKS device will
spit out a bunch of information about the device, while anything else will throw an error saying that
it is not a valid LUKS device. When you have determined your LUKS device, you can proceed with lowering the
iteration count. This is done using the following command:
```sh
sudo cryptsetup luksChangeKey --pbkdf-force-iterations 200000 --pbkdf pbkdf2 /dev/nvme0n1p2
```

## Benchmarking
We use Geekbench6 for CPU benchmarking. A quick benchmark can be ran using the following command:
```sh
mkdir -p /tmp/geekbench && wget -qO- https://cdn.geekbench.com/Geekbench-6.5.0-Linux.tar.gz | tar xz -C /tmp/geekbench --strip-components=1 && /tmp/geekbench/geekbench6
```
This outputs a benchmark together with a nice link to Geekbench that you can save and refer to later.
The scores are calibrated  against a baseline score of 2500 which is the score of an Intel Core i7-12700 - a
fairly modern and powerful processor. Higher scores are better, with double the score indicating
double the performance.
