{ pkgs, lib, ... }@inputs: {
    imports = [
        # inputs.sentinelone.nixosModules.sentinelone
        ./hardware-marvin.nix
        ../archetype/personal.nix
        ../modules/display-manager.nix
        ../modules/desktop-environment.nix
        ../modules/user-definitions.nix
    ];

    personal.enable = true;

    user-definitions.ajlow.enable = true;
    
    display-manager.enable = lib.mkForce false;
    # desktop-environment.enable = lib.mkForce false;

    services.desktopManager.cosmic.enable = true;
    services.displayManager.cosmic-greeter.enable = true;
    services.desktopManager.cosmic.xwayland.enable = true;

    environment.systemPackages = with pkgs; [
        cosmic-bg
        cosmic-ext-ctl
        gpsd
    ];

    powerManagement.cpuFreqGovernor = "powersave";

    services.sentinelone = {
        enable = true;
        sentinelOneManagementTokenPath = /etc/nixos/sentinelOne.token;
        email = "alowry@sram.com";
        serialNumber = "DPR8SQ3";
        package = pkgs.sentinelone.overrideAttrs (old: {
            version = "sentinelone.package.version"; 
            src = /etc/nixos/SentinelAgent_linux_x86_64_v24_3_3_6.deb;
        });
    };

    services.udev.extraRules = let
        gpsdPath = "${pkgs.gpsd}/bin/gpsd";
    in ''
##### FROM: https://gitlab.com/sram/ese/packaging/-/blob/main/misc/sram-udev/sram-udev/etc/udev/rules.d/99-sram.rules?ref_type=heads

# Only run these rules when adding USB devices
SUBSYSTEM!="usb_device", \
ACTION!="add", \
GOTO="usbdevice_end"

# Permissions and drivers for USB devices
# VID/PID pairs for Wispy USB dongle. Set Permissions to 0666 to allow
# non-group users to access this device
ATTRS{idVendor}=="1781", \
ATTRS{idProduct}=="083e", \
MODE:="0666"

ATTRS{idVendor}=="04b4", \
ATTRS{idProduct}=="0bad", \
MODE:="0666"

ATTRS{idVendor}=="1781", \
ATTRS{idProduct}=="083f", \
MODE:="0666"

ATTRS{idVendor}=="1dd5", \
ATTRS{idProduct}=="5000", \
MODE:="0666"

ATTRS{idVendor}=="1dd5", \
ATTRS{idProduct}=="2400", \
MODE:="0666"

ATTRS{idVendor}=="1dd5", \
ATTRS{idProduct}=="0900", \
MODE:="0666"

ATTRS{idVendor}=="1dd5", \
ATTRS{idProduct}=="2410", \
MODE:="0666"

# Atmel AVRISP mkII
ATTRS{idVendor}=="03eb", \
ATTRS{idProduct}=="2104", \
MODE:="0666"

# Atmel ICE
ATTRS{idVendor}=="03eb", \
ATTRS{idProduct}=="2141", \
MODE:="0666"

# USBTiny AVR ISP Programmer
ATTRS{idVendor}=="1781", \
ATTRS{idProduct}=="0c9f", \
MODE:="0666"

# FTDI -> bootsticks and LibTest DUT
ATTRS{idVendor}=="0403", \
ATTRS{idProduct}=="6001", \
MODE:="0666", \
RUN+="/bin/sh -c 'echo 1 > /sys/bus/usb-serial/devices/%k/latency_timer'"

# FTDI 232H USB chip for flashing I2C EEPROM
ATTRS{idVendor}=="0403", \
ATTRS{idProduct}=="6014", \
MODE:="0666"

# Segger JLink
ATTRS{idVendor}=="1366", \
ATTRS{idProduct}=="1015", \
MODE:="0666"

# Keithley USBTMC multimeter
ATTRS{idVendor}=="05e6", \
ATTRS{idProduct}=="2100", \
MODE:="0666"

# Keithley 2200-20-5 USBTMC power supply
ATTRS{idVendor}=="05e6", \
ATTRS{idProduct}=="2200", \
MODE:="0666"

# Keithley 2260B-XX-XX power supply
ATTRS{idVendor}=="05e6", \
ATTRS{idProduct}=="2260", \
MODE:="0666"

# Keithley 2280S-32-6 USBTMC power supply
ATTRS{idVendor}=="05e6", \
ATTRS{idProduct}=="2280", \
MODE:="0666"

# Keithley DMM6500
ATTRS{idVendor}=="05e6", \
ATTRS{idProduct}=="6500", \
MODE:="0666"

# Arduino UNO
ATTRS{idVendor}=="2341", \
ATTRS{idProduct}=="0043", \
MODE:="0666"

# KS34461A USBTMC Multimeter
ATTRS{idVendor}=="0957", \
ATTRS{idProduct}=="1c07", \
MODE:="0666"

ATTRS{idVendor}=="0957", \
ATTRS{idProduct}=="1a07", \
MODE:="0666"

ATTRS{idVendor}=="2a8d", \
ATTRS{idProduct}=="1301", \
MODE:="0666"

# Optomistic Products Universal LightProbe Spectra USB Sensor
ATTRS{idVendor}=="10c4", \
ATTRS{idProduct}=="8060", \
MODE:="0666"

ATTRS{idVendor}=="10c4", \
ATTRS{idProduct}=="ea60", \
MODE:="0666"

# Optomistic Products Universal LightProbe Spectra USB Sensor - use cp210x driver
ATTR{idVendor}=="10c4", \
ATTR{idProduct}=="8060", \
RUN+="/sbin/modprobe -b cp210x", \
RUN+="/bin/sh -c 'echo 10c4 8060 > /sys/bus/usb-serial/drivers/cp210x/new_id'"

# Very old Phidgets devices
ATTRS{idVendor}=="0925", \
ATTRS{idProduct}=="8101", \
MODE:="0666"

ATTRS{idVendor}=="0925", \
ATTRS{idProduct}=="8104", \
MODE:="0666"

ATTRS{idVendor}=="0925", \
ATTRS{idProduct}=="8201", \
MODE:="0666"

# All current and future Phidgets - Vendor = 0x06c2, Product = 0x0030 - 0x00af
ATTRS{idVendor}=="06c2", \
ATTRS{idProduct}=="00[3-a][0-f]", \
MODE:="0666"

# Tektronic MDO4054B-3 Mixed Domain Oscilloscope
ATTRS{idVendor}=="0699", \
ATTRS{idProduct}=="0453", \
MODE:="0666"

# Red Magic Probe
ATTRS{idVendor}=="1d50", \
ATTRS{idProduct}=="6018", \
MODE:="0666"

ATTRS{idVendor}=="1d50", \
ATTRS{idProduct}=="6017", \
MODE:="0666"

# Hameg HM8135 RF Generator
ATTRS{idVendor}=="0403", \
ATTRS{idProduct}=="ed74", \
MODE:="0666"

# FTDI+nRF52 Ant stick, Mr. ANT v1
SUBSYSTEM=="tty", \
ATTRS{idVendor}=="0403", \
ATTRS{manufacturer}=="Quarq", \
ATTRS{product}=="nRF52_Ant_Interface", \
GROUP="dialout", \
MODE="0660", \
SYMLINK+="ttyANTF ttyANTF.%n"

# KM003C POWERZ USB-C Amp Meter
SUBSYSTEM=="usb", \
ATTRS{idVendor}=="5fc9", \
ATTRS{idProduct}=="0063", \
MODE="0666"

# NEW USB DEVICE RULES GO HERE

LABEL="usbdevice_end"

# All serial ports will be set to 0666
KERNEL=="ttyS*", \
MODE:="0666"

# For GPS Daemon bu353gps
SUBSYSTEM=="tty", \
ACTION=="add", \
ATTRS{idProduct}=="2303", \
ATTRS{idVendor}=="067b", \
SYMLINK+="ttyGPS", \
RUN+="${gpsdPath} /dev/ttyGPS -F /var/run/gpsd.sock"

# Shimano SM-PCE1 Interface Box
ATTRS{idVendor}=="1e44", \
ATTRS{idProduct}=="71f4", \
MODE:="0666"

# Shimano SM-PCE1 Interface Box - use ti_usb_3410_5052 driver
ATTR{idVendor}=="1e44", \
ATTR{idProduct}=="71f4", \
RUN+="/sbin/modprobe -b ti_usb_3410_5052", \
RUN+="/bin/sh -c 'echo 1e44 71f4 > /sys/bus/usb-serial/drivers/ti_usb_3410_5052/new_id'"

#nrf52840 bambam USB devices
ATTRS{idVendor}=="1915", \
ATTRS{idProduct}=="520f", \
ENV{ID_MM_DEVICE_IGNORE}="1", \
MODE:="0666"

ATTRS{idVendor}=="1915", \
ATTRS{idProduct}=="520d", \
ENV{ID_MM_DEVICE_IGNORE}="1", \
MODE:="0666"

ATTRS{idVendor}=="1915", \
ATTRS{idProduct}=="521f", \
ENV{ID_MM_DEVICE_IGNORE}="1", \
MODE:="0666"

#Oasis Scientific USB Camera
ATTRS{idVendor}=="eb1a", \
ATTRS{idProduct}=="299f", \
ATTR{index}=="0", \
MODE:="0666", \
SYMLINK+="Supereye%n"

#Sandisk Flash Drive for FTF Material Number
ATTRS{idVendor}=="0781", \
ATTRS{idProduct}=="5583", \
SYMLINK+= "fixture_info", \
MODE:="0640", \
GROUP="sram"

# Alcor USB flash drive
ATTRS{idVendor}=="058f", \
ATTRS{idProduct}=="6387", \
SYMLINK+= "fixture_info", \
MODE:="0640", \
GROUP="sram"

# USB mass storage devices, checking for the SRAM_INFO volume label
ACTION=="add", \
KERNEL=="sd?", \
SUBSYSTEM=="block", \
ENV{ID_BUS}=="usb", \
ENV{SYSTEMD_WANTS}="sram-fixture-info-drive-mount.service"

# Prolific Technology, Inc. PL2303 Serial Port
ATTRS{idVendor}=="067b", \
ATTRS{idProduct}=="2303", \
MODE:="0666"

# All current and future Yepkit - Vendor = 0x0424, Product = 0x2514
SUBSYSTEMS=="usb", \
ACTION=="add", \
ATTRS{idVendor}=="0424", \
ATTRS{idProduct}=="2514", \
MODE:="0666"

# RF Chamber Serial Cable
SUBSYSTEM=="tty", \
ATTRS{idVendor}=="0403", \
ATTRS{manufacturer}=="SRAM", \
ATTRS{product}=="D4250_RF_Chamber_Cable", \
MODE="0666", \
SYMLINK+="ttyD4250RFCHAMBER%n"

# Keysight 34465A DMM
ATTRS{idVendor}=="2a8d", \
ATTRS{idProduct}=="0101", \
MODE:="0666"

# Agilent 34465A DMM
ATTRS{idVendor}=="2a8d", \
ATTRS{idProduct}=="0301", \
MODE:="0666"

# Keysight 34461A DMM
ATTRS{idVendor}=="2a8d", \
ATTRS{idProduct}=="1401", \
MODE:="0666"

# Rigol DL3021 DC LOAD
ATTRS{idVendor}=="1ab1", \
ATTRS{idProduct}=="0e11", \
MODE:="0666"

# Rigol DM3000 series DMM
ATTRS{idVendor}=="1ab1", \
ATTRS{idProduct}=="0c94", \
MODE:="0666"

# Rigol DSG830 series Signal Generator
ATTRS{idVendor}=="1ab1", \
ATTRS{idProduct}=="099c", \
MODE:="0666"

#TTi MX0100TP PSU
ATTRS{idVendor}=="103e", \
ATTRS{idProduct}=="04ba", \
MODE:="0666"

# Faulhaber Motor Controller
ATTRS{idVendor}=="2b8d", \
ATTRS{idProduct}=="0030", \
MODE:="0666"

# Waveshare USB to RS232, RS485, TTL
SUBSYSTEM=="tty", \
ATTRS{manufacturer}=="Waveshare", \
ATTRS{product}=="FT232RL", \
SYMLINK+="waveshare_ftdi", \
MODE="0666", \
GROUP="sram"

# Arducam 8mp IMX219 AF camera
KERNEL=="video*", \
ATTR{name}=="Arducam_8mp: USB Camera", \
ATTR{index}=="0", \
MODE:="0666", \
SYMLINK+="Arducam_8mp"

# Patlite LED NE-WN-USB
SUBSYSTEM=="usb", \
ATTR{idVendor}=="191a", \
ATTR{idProduct}=="6001", \
MODE="0666"

# Atmel JTAGICE mkII Programmer
ATTRS{idVendor}=="03eb", \
ATTRS{idProduct}=="2103", \
MODE="0666", \
SYMLINK+="avrjtag"

SUBSYSTEM=="usb_device", \
ACTION=="add", \
ATTRS{product}=="MSP-FET430UIF JTAG Tool", \
ATTRS{bNumConfigurations}=="1", \
RUN+="/sbin/modprobe ti_usb_3410_5052"

SUBSYSTEM=="usb_device", \
ACTION=="add", \
ATTRS{product}=="MSP-FET430UIF JTAG Tool", \
ATTRS{bNumConfigurations}=="2", \
ATTRS{bConfigurationValue}=="1", \
RUN+="/bin/sh -c 'echo 2 > /sys%p/device/bConfigurationValue'"

# Use the tty subsystem to get a stable name for the FET
SUBSYSTEM=="tty", \
ACTION=="add", \
ATTRS{product}=="MSP-FET430UIF JTAG Tool", \
SYMLINK+="ttyTIUSB ttyTIUSB.%n"

# Nugget + FTDI cable
SUBSYSTEM=="tty", \
ACTION=="add", \
ATTRS{product}=="NUGGET", \
SYMLINK+="ttyNugget"

# FTDI chip used in vu
SUBSYSTEM=="tty", \
ACTION=="add", \
ATTRS{idVendor}=="0403", \
ATTRS{idProduct}=="6015", \
SYMLINK+="ttyVU"

# FTDI cable
SUBSYSTEM=="tty", \
ACTION=="add", \
ATTRS{product}=="TTL232R-3V3", \
SYMLINK+="ttyFTDI_CABLE ttyFTDI_CABLE%n", \
RUN+="/bin/sh -c 'echo 1 > /sys%p/device/latency_timer'"

# other FTDI cable
SUBSYSTEM=="tty", \
ACTION=="add", \
ATTRS{product}=="TTL232R-1V8", \
SYMLINK+="ttyFTDI_CABLE ttyFTDI_CABLE%n"

# FTDI cable
SUBSYSTEM=="tty", \
ACTION=="add", \
ATTRS{product}=="TTL232R-3V3-TX", \
SYMLINK+="ttyFTDI_CABLE_TX", \
RUN+="/bin/sh -c 'echo 1 > /sys%p/device/latency_timer'"

# FTDI cable
SUBSYSTEM=="tty", \
ACTION=="add", \
ATTRS{product}=="TTL232R-1V8-TX", \
SYMLINK+="ttyFTDI_CABLE_TX"

## Ryan's really counterfeit cable
## "Prolifec" USB-Serial controller
SUBSYSTEM=="tty", \
ACTION=="add", \
ATTRS{idVendor}=="4348", \
ATTRS{idProduct}=="5523", \
SYMLINK+="ttyPROLIFIC ttyPROLIFIC%n"

# LinkUSBi 1-wire temp sensor
SUBSYSTEM=="tty", \
ACTION=="add", \
ATTRS{product}=="1-wire Interface", \
SYMLINK+="ttyONEWIRE ttyONEWIRE%n"

# New spidersim, not FTDI cable...
SUBSYSTEM=="tty", \
ACTION=="add", \
ATTRS{serial}!="SRAMLINK", \
ATTRS{product}!="TTL232R-3V3", \
ATTRS{product}!="TTL232R-3V3-TX", \
ATTRS{product}!="NUGGET", \
ATTRS{product}!="1-wire Interface", \
ATTRS{idVendor}=="0403", \
ATTRS{idProduct}=="6001", \
SYMLINK+="ttyFTDI ttyFTDI%n"

# Relay built with FTDI cable.
SUBSYSTEMS=="usb", \
ACTION=="add", \
ATTRS{product}=="TTL232R-3V3-RELAY", \
ATTRS{idVendor}=="0403", \
GROUP="dialout"

# Alcor Micro USB-Serial controller
SUBSYSTEM=="tty", \
ACTION=="add", \
ATTRS{idVendor}=="058f", \
ATTRS{idProduct}=="9720", \
SYMLINK+="ttyALCOR"

# Prolific USB-Serial controller
SUBSYSTEM=="tty", \
ACTION=="add", \
ATTRS{manufacturer}=="Prolific Technology Inc.", \
SYMLINK+="ttyPROLIFIC ttyPROLIFIC%n"

# Delcom Blinky Lights
#SUBSYSTEM=="hid", \
ACTION=="add", \
ATTRS{idVendor}=="0fc5", \
ATTRS{idProduct}=="b080", \
MODE="0666", \
SYMLINK+="DELCOMb080 DelcomIndicator"

# Delcom Blinky Lights
# This device type is supposedly not a HID device, although it should be! #@!$%!!!
#SUBSYSTEM=="hid", \
ACTION=="add", \
ATTRS{idVendor}=="0fc5", \
ATTRS{idProduct}=="1223", \
MODE="0666", \
SYMLINK+="DELCOM1223"

# Labjack (all devices)
ATTRS{idVendor}=="0cd5", \
MODE="0666"

# Labjack U3
ATTRS{idVendor}=="0cd5", \
ATTRS{idProduct}=="0003", \
MODE="0666", \
SYMLINK+="LabJack_U3"

# Labjack U6
ATTRS{idVendor}=="0cd5", \
ATTRS{idProduct}=="0006", \
MODE="0666", \
SYMLINK+="LabJack_U6"

# Phidget Stepper
ATTRS{idVendor}=="06c2", \
ATTRS{idProduct}=="007b", \
MODE="0666", \
SYMLINK+="Phidget_Stepper"

# Phidget Thermocouple
ATTRS{idVendor}=="06c2", \
ATTRS{idProduct}=="0070", \
MODE="0666", \
SYMLINK+="Phidget_Thermocouple"

# Phidget DC Motor Controller
ATTRS{idVendor}=="06c2", \
ATTRS{idProduct}=="003e", \
MODE="0666", \
SYMLINK+="Phidget_DC_Motor_Controller"

# Phidget Encoder
ATTRS{idVendor}=="06c2", \
ATTRS{idProduct}=="0080", \
MODE="0666", \
SYMLINK+="Phidget_Encoder"

# Shimano box
SUBSYSTEM=="tty", \
ACTION=="add", \
ATTRS{idProduct}=="71f4", \
ATTRS{idVendor}=="1e44", \
SYMLINK+="ttyDi2"

# Segger devices
ACTION=="add", \
SUBSYSTEM=="usb", \
ATTRS{idVendor}=="1366", \
GROUP="plugdev", \
SYMLINK+="Jlink"

ACTION=="add", \
SUBSYSTEMS=="usb", \
DRIVERS=="cdc_acm", \
ATTRS{iad_bFirstInterface}=="?*", \
GOTO="maybe_bmp"

GOTO="not_any_bmp"

LABEL="maybe_bmp"

# Black Magic Probe (jtagger from tag-connect)
# there are two connections, one for GDB and one for uart debugging
SUBSYSTEMS=="usb", \
ATTRS{interface}!="Black Magic GDB Server", \
GOTO="not_bmp"

SUBSYSTEM=="tty", \
ATTRS{serial}=="*", \
SYMLINK+="ttyBmpGdb ttyBmpGdb.%s{serial}"

LABEL="not_bmp"

ATTRS{interface}!="Black Magic UART Port", \
GOTO="not_targ"

SUBSYSTEM=="tty", \
ATTRS{serial}=="*", \
SYMLINK+="ttyBmpTarg ttyBmpTarg.%s{serial}"

LABEL="not_targ"

# nRF52840-based Ant interface
ATTRS{interface}!="ANT Interface", \
GOTO="not_targ2"

SUBSYSTEM=="tty", \
ATTRS{serial}=="*", \
SYMLINK+="ttyANT2 ttyANTK ttyANT.%s{serial}"

LABEL="not_targ2"

SUBSYSTEM=="tty", \
ATTRS{interface}=="Velotron Interface", \
SYMLINK+="ttyVelotron ttyVelotron.%n"

SUBSYSTEM=="tty", \
ATTRS{interface}=="Debug Interface", \
SYMLINK+="ttyDebug ttyDebug.%n"

SUBSYSTEM=="tty", \
ATTRS{interface}=="Vu Test", \
SYMLINK+="ttyVuTest ttyVuTest%n"

ATTRS{interface}!="Know Pressure GDB Server", \
GOTO="not_bmp2"

SUBSYSTEM=="tty", \
ATTRS{interface}=="Know Pressure GDB Server", \
SYMLINK+="ttyKnowPressureGdb"

SUBSYSTEM=="tty", \
ATTRS{serial}=="*", \
SYMLINK+="ttyBmpGdb ttyBmpGdb.%s{serial}"

LABEL="not_bmp2"

SUBSYSTEM=="tty", \
ATTRS{interface}=="Know Pressure UART Port", \
SYMLINK+="ttyKnowPressureTarg"

SUBSYSTEM=="tty", \
ATTRS{interface}=="Nano GDB Server", \
SYMLINK+="ttyNanoGdb"

SUBSYSTEM=="tty", \
ATTRS{interface}=="Nano GDB Server", \
SYMLINK+="ttyBmpGdb"

SUBSYSTEM=="tty", \
ATTRS{interface}=="Nano UART Port", \
SYMLINK+="ttyNanoTarg"

SUBSYSTEM=="tty", \
ATTRS{interface}=="Black Magic GDB Server", \
SYMLINK+="ttyBlackSphereBmpGdb"

LABEL="not_any_bmp"

# GW Instek GSP-730 Spectrum Analyzer
# (Internal USB-to-UART converter)
SUBSYSTEM=="tty", \
ATTRS{idVendor}=="2184", \
ATTRS{idProduct}=="002a", \
GROUP="dialout", \
MODE="0660", \
SYMLINK="ttyInstekGSP730_USB"

# OMEGA PX409 USB Precision Pressure Transducer (Contains FT232)
# Absolute pressure version
SUBSYSTEM=="tty", \
ATTRS{idVendor}=="0403", \
ATTRS{idProduct}=="6001", \
ATTRS{manufacturer}=="Omega", \
ATTRS{product}=="PX409-A", \
GROUP="dialout", \
MODE="0660", \
SYMLINK+="ttyOmegaPX409-A ttyOmegaPX409-A-%n ttyOmegaPX409-A.%s{serial}"

# OMEGA PX409 USB Precision Pressure Transducer (Contains FT232)
# Gauge pressure version
SUBSYSTEM=="tty", \
ATTRS{idVendor}=="0403", \
ATTRS{idProduct}=="6001", \
ATTRS{manufacturer}=="Omega", \
ATTRS{product}=="PX409-G", \
GROUP="dialout", \
MODE="0660", \
SYMLINK+="ttyOmegaPX409-G ttyOmegaPX409-G-%n ttyOmegaPX409-G.%s{serial}"

# Keysight / Agilent / HP 34410A 6.5 Digit Multimeter (Uses usbtmc)
SUBSYSTEM=="usb", \
ATTRS{idVendor}=="0957", \
ATTRS{idProduct}=="0607", \
GROUP="dialout", \
MODE="0660", \
SYMLINK+="Keysight34410A Keysight34410A-%n"

# USB to 3V serial UART interface cable for KnowPressure prototypes
SUBSYSTEM=="tty", \
ATTRS{idVendor}=="0403", \
ATTRS{idProduct}=="6001", \
ATTRS{manufacturer}=="Quarq", \
ATTRS{product}=="KnowPressure_Debug_Cable", \
GROUP="dialout", \
MODE="0660", \
SYMLINK+="ttyKnowPressureDebug ttyKnowPressureDebug-%n"

# USB to 3V serial UART interface cable for Nano prototypes
SUBSYSTEM=="tty", \
ATTRS{idVendor}=="0403", \
ATTRS{idProduct}=="6001", \
ATTRS{manufacturer}=="Quarq", \
ATTRS{product}=="Nano_Debug_Cable", \
GROUP="dialout", \
MODE="0660", \
SYMLINK+="ttyNanoDebug ttyNanoDebug-%n"

# FTDI+nRF52 Ant stick
SUBSYSTEM=="tty", \
ATTRS{idVendor}=="0403", \
ATTRS{manufacturer}=="Quarq", \
ATTRS{product}=="nRF52_Ant_Interface", \
GROUP="dialout", \
MODE="0660", \
SYMLINK+="ttyANTF ttyANTF.%n"

# FTDI Velotron interface
SUBSYSTEM=="tty", \
ATTRS{idVendor}=="0403", \
ATTRS{manufacturer}=="Quarq", \
ATTRS{product}=="Velotron_Interface", \
GROUP="dialout", \
MODE="0660", \
SYMLINK+="ttyVelotron ttyVelotron.%n"

# FTDI Velotron control interface
SUBSYSTEM=="tty", \
ATTRS{idVendor}=="0403", \
ATTRS{manufacturer}=="Quarq", \
ATTRS{product}=="Velotron_Control_Interface", \
GROUP="dialout", \
MODE="0660", \
SYMLINK+="ttyVelotronControl ttyVelotronControl.%n"

# BK Hardware
# (Using Cygnal Integrated Products, Inc. CP210x UART Bridge)
# Several BK products use this chip, and with no customization, so we
# can't quite be sure which model we have!
#
# Products include:
# - Model 880 Handheld LCR Meter
# - Model 1685B 1-60VDC, 5A power supply
#
SUBSYSTEM=="tty", \
ATTRS{idVendor}=="10c4", \
ATTRS{idProduct}=="ea60", \
GROUP="dialout", \
MODE="0660", \
SYMLINK+="ttyBKPrecision ttyttyBKPrecision-%n"

# Ubisys 13.56 MHz RFID USB Stick
# (Using CDC serial driver)
SUBSYSTEM=="tty", \
ATTRS{idVendor}=="19a6", \
ATTRS{idProduct}=="0003", \
GROUP="dialout", \
MODE="0660", \
SYMLINK+="ttyUbisysRFID ttyUbisysRFID-%n"

# USB Watchdog Dongle
# (based on QinHeng Electronics HL-340 USB-Serial adapter chipset)
# (https://phab.quarq.com/T6458)
SUBSYSTEM=="tty", \
ATTRS{idVendor}=="1a86", \
ATTRS{idProduct}=="7523", \
GROUP="dialout", \
MODE="0660", \
SYMLINK+="ttyUSBWDT ttyUSBWDT-%n ttyCH340 ttyCH340.%n"

# Borescope camera
SUBSYSTEM=="video4linux", \
ATTRS{idVendor}=="f007", \
ATTRS{idProduct}=="a999", \
SYMLINK+="video.borescope"

# Borescope camera, Alcor Micro
SUBSYSTEM=="video4linux", \
ATTRS{idVendor}=="058f", \
ATTRS{idProduct}=="3822", \
SYMLINK+="video.borescope"

# Omega OS-MINIUSB-SN201
# USB Infrared Temperature Sensor
SUBSYSTEM=="tty", \
ATTRS{idVendor}=="0403", \
ATTRS{idProduct}=="6015", \
ATTRS{manufacturer}=="Omega", \
ATTRS{product}=="Omega OS-MINIUSB", \
GROUP="dialout", \
MODE="0660", \
SYMLINK+="ttyOS-MINIUSB ttyOS-MINIUSB-%n"

# Shockwiz FTDI Druck DPI104
SUBSYSTEM=="tty", \
ATTRS{idVendor}=="0403", \
ATTRS{idProduct}=="6001", \
ATTRS{manufacturer}=="GE", \
ATTRS{product}=="Druck DPI104", \
SYMLINK+="ttyGEDruckDPI104"

# SainSmart 8-Channel USB Relay Module
# This particular serial number used to control a warning light/buzzer combo.
#SUBSYSTEM=="tty", \
ATTRS{idVendor}=="0403", \
ATTRS{idProduct}=="6001", \
ATTRS{serial}=="A90767Z7", \
GROUP="dialout", \
MODE="0660", \
SYMLINK+="WarningLight WarningLight-%n"

# Futek USB220 USB Output Kit
SUBSYSTEM=="tty", \
ATTRS{idVendor}=="0403", \
ATTRS{idProduct}=="6001", \
ATTRS{manufacturer}=="FUTEK", \
ATTRS{product}=="USB220", \
GROUP="plugdev", \
MODE="0666", \
SYMLINK+="ttyFutekUSB220 ttyFutekUSB220-%n ttyFutekUSB220.%s{serial}"

# ZBIKE TORQUE MODULE TESTS
SUBSYSTEM=="usb", \
ATTR{idVendor}=="0403", \
ATTR{idProduct}=="6001", \
GROUP="plugdev", \
MODE="0666"

SUBSYSTEM=="usb", \
ATTR{idVendor}=="0403", \
ATTR{idProduct}=="6011", \
GROUP="plugdev", \
MODE="0666"

SUBSYSTEM=="usb", \
ATTR{idVendor}=="0403", \
ATTR{idProduct}=="6010", \
GROUP="plugdev", \
MODE="0666"

SUBSYSTEM=="usb", \
ATTR{idVendor}=="0403", \
ATTR{idProduct}=="6014", \
GROUP="plugdev", \
MODE="0666", \
SYMLINK+="ttyFTDI232H ttyFTDI232H-%n"

SUBSYSTEM=="usb", \
ATTR{idVendor}=="0403", \
ATTR{idProduct}=="6015", \
GROUP="plugdev", \
MODE="0666"

# END OF ZBIKE TORQUE MODULE TESTS

# Directemp Sensor
SUBSYSTEM=="tty", \
ATTRS{idVendor}=="1dfd", \
ATTRS{idProduct}=="0001", \
ATTRS{manufacturer}=="Quality Thermistor, Inc.", \
GROUP="plugdev", \
MODE="0666", \
SYMLINK+="ttyDirectemp ttyDirectemp-%n"
    '';

    services.postgresql = {
        enable = true;
        ensureDatabases = [ "mydatabase" ];
        authentication = pkgs.lib.mkOverride 10 ''
            #type database  DBuser  auth-method
            local all       all     trust
        ''; 
    };

    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

    networking.hostName = "marvin"; # Define your hostname.

    boot.kernelPackages = pkgs.linuxPackages_latest;

    #networking.firewall.allowedTCPPorts = [ ... ];
    #networking.firewall.allowedUDPPorts = [ ... ];

    # This value determines the NixOS release from which the default
    # settings for stateful data, like file locations and database versions
    # on your system were taken. It‘s perfectly fine and recommended to leave
    # this value at the release version of the first install of this system.
    # Before changing this value read the documentation for this option
    # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
    system.stateVersion = "24.05"; # Did you read the comment?
}
