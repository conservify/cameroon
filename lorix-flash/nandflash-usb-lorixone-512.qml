import SAMBA 3.1
import SAMBA.Connection.Serial 3.1
import SAMBA.Device.SAMA5D4 3.1

AppletLoader {
	connection: SerialConnection {
		port: "ttyACM0"
		baudRate: 230400
	}

	device: SAMA5D4 {
		// board: sama5d4-lorix-one
		config {
			nandIoset: 1
			nandBusWidth: 8
			nandHeader: 0xc1e04e07
		}
	}

	onConnectionOpened: {
		// initialize Low-Level applet
		appletInitialize("lowlevel")

		// initialize NAND flash applet
		appletInitialize("nandflash")

		// erase all memory
		appletErase(0, connection.applet.memorySize)

		// write files
		appletWrite(0x000000, "build/images/sama5d4-lorix-one-512/at91bootstrap.bin", true)
		appletWrite(0x040000, "build/images/sama5d4-lorix-one-512/u-boot.bin")
		appletWrite(0x180000, "build/images/sama5d4-lorix-one-512/zImage-at91-sama5d4_lorix_one_512.dtb")
		appletWrite(0x200000, "build/images/sama5d4-lorix-one-512/zImage")
		appletWrite(0x800000, "build/images/sama5d4-lorix-one-512/wifx-base-sama5d4-lorix-one-512.ubi")
	}
}
