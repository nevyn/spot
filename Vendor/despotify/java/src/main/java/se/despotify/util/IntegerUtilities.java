package se.despotify.util;

public class IntegerUtilities {
	public static byte[] toBytes(int i){
		byte[] b = new byte[4];
		
		b[0] = (byte)(i >> 24);
		b[1] = (byte)(i >> 16);
		b[2] = (byte)(i >>  8);
		b[3] = (byte)(i);
		
		return b;
	}
	
	public static long bytesToUnsignedInteger(byte[] b){
		return bytesToUnsignedInteger(b, 0);
	}
	
	public static long bytesToUnsignedInteger(byte[] b, int off){
		return  ((b[off    ] << 24) & 0xFFFFFFFF) |
				((b[off + 1] << 16) & 0x00FFFFFF) |
				((b[off + 2] <<  8) & 0x0000FFFF) |
				((b[off + 3]      ) & 0x000000FF);
	}
	
	public static int bytesToInteger(byte[] b){
		return bytesToInteger(b, 0);
	}
	
	public static int bytesToInteger(byte[] b, int off){
		return 	((b[off    ] << 24) & 0xFFFFFFFF) |
				((b[off + 1] << 16) & 0x00FFFFFF) |
				((b[off + 2] <<  8) & 0x0000FFFF) |
				((b[off + 3]      ) & 0x000000FF);
	}
}
