# gns3_tap0
This repository contains a script that automates the configuration of a network bridge on GNS3 VM. The script sets up a bridge interface (`br0`) connected to `eth1` and a tap interface (`tap0`). It uses systemd to ensure that the configuration is applied at every boot.
