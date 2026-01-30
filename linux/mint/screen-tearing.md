### Screen tearing
> **_WARNING:_** This is a bit risky (albeit fixable) and not really tested much. If you can deal with screen tearing, just leave it as is.

Some workstation experience screen tearing, especially when working with multiple monitors. Screen tearing will look like you screen is split into multiple columns, where one responds slower then the other. You can test it by either scrolling through text documents or simply dragging a window around an otherwise empty screen. Its not a huge issue, but it just looks quite ugly. Luckily, it's fixable.

Most of our workstations run Intel onboard graphics, so this fix is specifically for that. Run the following command and reboot:
```sh
sudo tee -a /etc/X11/xorg.conf.d/20-intel.conf <<EOF
Section "Device"
	Identifier "Intel Graphics"
	Driver "intel"
	Option "TearFree" "true"
EndSection
EOF
```

> **_NOTE:_** This can result in a black screen after the reboot. This means that something has gone wrong, but luckily this is also fixable. Open the command line using `Ctrl+Alt+F1` and delete the file you just created by running `sudo rm /etc/X11/xorg.conf.d/20-intel.conf`.