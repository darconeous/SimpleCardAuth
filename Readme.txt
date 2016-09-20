In order to install SimpleCardAuth on the RaspberryPi execute the following commands:
## RPI Installation ##

sudo apt-get install libusb-dev libusb++-0.1-4c2
sudo apt-get install libccid

sudo apt-get install pcscd

sudo apt-get install libpcsclite1
sudo apt-get install libpcsclite-dev
sudo apt-get install pcsc-tools
sudo apt-get install libpcsc-perl

sudo modprobe -r pn533
sudo modprobe -r nfc

sudo apt-get install libssl-dev
sudo apt-get install libreadline-dev

sudo apt-get install coolkey pcscd pcsc-tools pkg-config libpam-pkcs11 opensc libengine-pkcs11-openssl

sudo apt-get install sqlite3

#execute the following inside the "SimpleCardAuth" folder (or use the makefile alternatively)
gcc ecdsa-pkcs11-to-asn1.c -lcrypto -o ecdsa-pkcs11-to-asn1 

## Creating and revoking certificates ##
XCA is a tool with GUI support that allows management of certificates without knowledge about the shell.
So certificate management may be done by people with less technical background.

Official homepage: http://xca.hohnstaedt.de/
XCA download: http://xca.hohnstaedt.de/index.php/download

1. In order to install XCA execute the following steps:
sudo apt-get install libtool
sudo apt-get install libqt4-core libqt4-gui
sudo apt-get install libqt4-dev
2. download XCA according to http://xca.hohnstaedt.de/index.php/download
3. sudo ./configure; make -j6; sudo make install
