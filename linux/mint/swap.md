# Swap
Linux Mint might install with just a 2 gigabytes swap partition by default. We prefer to have a bit more - generally the same amount of swap as the RAM that the machine has.

To check this, run the following: 

```sh
swapon --show
```

This will display you swap files or partitions and their sizes. Check them and determine whether they are enough for you - if so, then just leave them, otherwise we can continue increasing swap. 

We start by disabling swap and deleting its logical volume. Do this by running the following:

```sh
sudo swapoff -a
sudo lvremove /dev/mapper/vgmint-swap_1
```

Next we want to remove the 'old' swap entry from `fstab`. For this, run `sudo xed /etc/fstab` and fine a line referencing the swap partition or logical volume. Delete this (or just comment it out) and then save and exit the file.

Next run `df -h /` and copy the output file system (something like `/dev/mapper/vgmint-root`). With this ready, you can do the following:

```sh
sudo lvextend -l +100%FREE <your-lvm-root>
sudo resize2fs <your-lvm-root>
```

Finally, we can create and enable the new swap file using the following commands:

```sh
sudo fallocate -l 32G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
```

Verify whether the new swap was set up correctly by running `swapon --show` again. This should now display a 32 gigabyte swap file and no swap partition. To make sure that the `fstab` entry went well, you can also restart your workstation and then run `swapon --show` again. If you still see the 32 gigabytes swap file, you're all set!