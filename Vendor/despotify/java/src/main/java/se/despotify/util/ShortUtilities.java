package se.despotify.util;

public class ShortUtilities {
	public static byte[] toBytes(short i){
		byte[] b = new byte[2];
		
		b[0] = (byte)(i >> 8);
		b[1] = (byte)(i);
		
		return b;
	}
	
	public static int bytesToUnsignedShort(byte[] b){
		return bytesToUnsignedShort(b, 0);
	}
	
	public static int bytesToUnsignedShort(byte[] b, int off){
		return (((b[off    ] << 8) & 0xFFFF) |
				((b[off + 1]     ) & 0x00FF));
	}
	
	public static short bytesToShort(byte[] b){
		return bytesToShort(b, 0);
	}
	
	public static short bytesToShort(byte[] b, int off){
		return (short)(((b[off    ] << 8) & 0xFFFF) |
						(b[off + 1]     ) & 0x00FF);
	}
}
