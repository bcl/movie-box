# Movie Box - Offline Movie Server for Roku

Stream movies from a Raspberry Pi without using a network connection. Useful
during power outages, hiking in remote locations (with a HMDI monitor strapped
to your pack, or locations with restricted or no available network.

This combines my HMS and Clortho projects with a simple installation script to
setup an old Pi I have laying around so that it will stream movies from a USB
drive directly to the Roku. No network, no switches, no USB hubs needed.

## Hardware Needed

 * Raspberry Pi or other Debian based system. I used a Model B.
 * Power supply for the Pi. Use the largest you have around, I used an Apple charger.
 * Roku player. I used is a model N1000
 * USB Keyboard
 * USB drive. I used a small 16GB Sandisk drive.
 * Ethernet cable.
 * HDMI cable compatible with your TV or Monitor.
 * A TV or Monitor.
 * (optionally) an amplifier for sound.

## Installation

Start out with a fresh SD card and install [Raspian Jessie
Lite](https://www.raspberrypi.org/downloads/raspbian/) to the card and make
sure that it boots when connected to the TV, Keyboard, and power supply.

Format the USB drive with the ext4 filesystem and copy the contents of this
repository over to a directory on it named /movie-box/. Then create a Movies
directory and install the files and movies you want to stream, following the
directions for [configuring HMS cover images](https://github.com/bcl/hms).

You should have a directory tree that looks something like:

```
├── lost+found
├── movie-box
│   ├── clortho
│   │   ├── COPYING
│   │   ├── README
│   │   ├── requirements.txt
│   │   └── src
│   │       └── clortho.py
│   ├── config
│   │   ├── clortho
│   │   │   └── clortho.service
│   │   └── debian
│   │       ├── dnsmasq.conf
│   │       ├── interfaces
│   │       └── lighttpd.conf
│   ├── HMS
│   │   ├── HMS
│   │   │   ├── app.mk
│   │   │   ├── images
│   │   │   │   ├── MainMenu_Icon_CenterFocus_HD.png
│   │   │   │   ├── MainMenu_Icon_CenterFocus_SD.png
│   │   │   │   ├── MainMenu_Icon_Side_HD.png
│   │   │   │   ├── MainMenu_Icon_Side_SD.png
│   │   │   │   ├── Overhang_Background_HD.png
│   │   │   │   ├── Overhang_Background_SD.png
│   │   │   │   ├── Overhang_Logo_HD.png
│   │   │   │   └── Overhang_Logo_SD.png
│   │   │   ├── Makefile
│   │   │   ├── manifest
│   │   │   └── source
│   │   │       ├── appMain.brs
│   │   │       ├── appMediaServer.brs
│   │   │       ├── checkServerUrl.brs
│   │   │       ├── deviceInfo.brs
│   │   │       ├── generalDlgs.brs
│   │   │       ├── generalUtils.brs
│   │   │       ├── getDirectoryListing.brs
│   │   │       ├── searchScreen.brs
│   │   │       └── urlUtils.brs
│   │   ├── LICENSE
│   │   ├── README
│   │   └── scripts
│   │       ├── makebif.py
│   │       └── nobif.py
│   ├── install-on-debian.sh
│   ├── README.md
│   ├── TODO
└── Movies
    ├── HarryPotter
    │   ├── HarryPotter-Year1-SorcerersStone.m4v
    │   ├── HarryPotter-Year1-SorcerersStone-SD.bif
    │   ├── HarryPotter-Year1-SorcerersStone-SD.jpg
    │   ├── HarryPotter-Year2-ChamberOfSecrets.m4v
    │   ├── HarryPotter-Year2-ChamberOfSecrets-SD.bif
    │   ├── HarryPotter-Year2-ChamberOfSecrets-SD.jpg
    │   ├── HarryPotter-Year3-PrisonerOfAzkaban.m4v
    │   ├── HarryPotter-Year3-PrisonerOfAzkaban-SD.bif
    │   ├── HarryPotter-Year3-PrisonerOfAzkaban-SD.jpg
    │   ├── HarryPotter-Year4-GobletOfFire.m4v
    │   ├── HarryPotter-Year4-GobletOfFire-SD.bif
    │   ├── HarryPotter-Year4-GobletOfFire-SD.jpg
    │   ├── HarryPotter-Year5-OrderOfThePhoenix.m4v
    │   ├── HarryPotter-Year5-OrderOfThePhoenix-SD.bif
    │   ├── HarryPotter-Year5-OrderOfThePhoenix-SD.jpg
    │   ├── HarryPotter-Year6-HalfBloodPrince.m4v
    │   ├── HarryPotter-Year6-HalfBloodPrince-SD.bif
    │   ├── HarryPotter-Year6-HalfBloodPrince-SD.jpg
    │   ├── HarryPotter-Year7-DeathlyHollows-Part1.m4v
    │   ├── HarryPotter-Year7-DeathlyHollows-Part1-SD.bif
    │   ├── HarryPotter-Year7-DeathlyHollows-Part1-SD.jpg
    │   ├── HarryPotter-Year7-DeathlyHollows-Part2.m4v
    │   ├── HarryPotter-Year7-DeathlyHollows-Part2-SD.bif
    │   ├── HarryPotter-Year7-DeathlyHollows-Part2-SD.jpg
    │   └── movies
    ├── Placeholder
    │   └── episodes
    ├── Search-HD.png
    ├── Search-SD.png
    ├── Setup-HD.png
    └── Setup-SD.png
```

HMS v3.0 and before have a 1-off erro when using a single directory, as you can
see above I've added a `Placeholder` directory until I can debug and fix it.

Next you need to label the filesystem containing the Movies directory. You can
do this using the `e2label` utility -- `e2label /dev/sdX1 movie-box`. It is
important that this is labeled correctly, otherwise the movie partition
won't be mounted when the Pi reboots.

## Roku Developer Mode

Since [HMS](https://github.com/bcl/hms) isn't an official Roku channel it has
to be installed directly to the device using Developer Mode. You can enable
this mode by booting the Roku and hitting the following keys on the remote
(quickly, otherwise they will be ignored): `HOME HOME HOME UP UP Righ Left
Right Left Right`

This will enter developer mode and ask you to set a password. Set it to
`password` (or edit the install script so that the `ROKU_DEV_PASSWORD` matches
what you set.

## Install Movie Box

Turn off the Roku player for now, connect the Pi to the TV and your LAN (it
needs to download some packages first). Log into the Pi, sudo to root, and then
insert the USB drive you created above and mount it on a temporary directory
like /mnt/usb1. eg. `mkdir /mnt/usb1 && mount /dev/sda1 /mnt/usb1`

Then run the install script: `cd /mnt/usb1 && ./install-on-debian.sh`. The
script will download a few packages, then prompt you to unplug your LAN and
connect the Ethernet cable to the Roku. After this point you don't want to plug
in the LAN unless you temporarily disable the dnsmasq service.

If everything went according to plan you should now be able to reboot
everything and select the HMS application on the Roku. When you first boot it
will complain about not being able to connect to the internet. This is normal,
it actually is connected to the Pi, but it cannot talk to the roku servers so
it gets confused. Hit OK and then HOME to get back to the menu.

You can check that the Roku actually got an IP address by looking in the
settings->player info menu. The IP address should be something like
192.168.0.67

# Troubleshooting

If you have problems with playback check the lighttpd logs in /var/log/lighttpd/

If there are problems with getting an IP on the Roku check that dnsmasq is
running and dhcpcd is not by using `systemctl status dnsmasq` and `systemctl
status dhcpcd`

If you need to reconnect your LAN you should run:

 * `systemctl stop dnsmasq && systemctl start dhcpcd`

This keeps the DHCP server, provided by dnsmasq, from interfering with the
DHCP server on your LAN.
