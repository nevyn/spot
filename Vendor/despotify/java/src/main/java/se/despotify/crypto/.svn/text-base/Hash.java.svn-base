package se.despotify.crypto;

import javax.crypto.Mac;
import javax.crypto.ShortBufferException;
import javax.crypto.spec.SecretKeySpec;
import java.security.InvalidKeyException;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;

public class Hash {
	private static MessageDigest digestSha1;
	private static MessageDigest digestMd5;
	private static Mac           hmacSha1;
	
	static{
		try{
			digestSha1 = MessageDigest.getInstance("SHA-1");
			digestMd5  = MessageDigest.getInstance("MD5");
			hmacSha1   = Mac.getInstance("HmacSHA1");
		}
		catch(NoSuchAlgorithmException e){
			System.err.println("Algorithm not available: " + e.getMessage());
		}
	}
	
	public static byte[] sha1(byte[] buffer){
		if(digestSha1 == null){
			return null;
		}
		
		return digestSha1.digest(buffer);
	}
	
	public static byte[] md5(byte[] buffer){
		if(digestMd5 == null){
			return null;
		}
		
		return digestMd5.digest(buffer);
	}
	
	public static byte[] hmacSha1(byte[] buffer, byte[] key){
		byte[] output = new byte[20];
		
		hmacSha1(buffer, key, output, 0);
		
		return output;
	}
	
	public static void hmacSha1(byte[] buffer, byte[] key, byte[] output, int offset){
		if(hmacSha1 == null){
			return;
		}
		
		SecretKeySpec secretKey = new SecretKeySpec(key, "HmacSHA1");
		
		try{
			hmacSha1.init(secretKey);
		}
		catch(InvalidKeyException e){
			System.err.println("Invalid key: " + e.getMessage());
			
			return;
		}
		
		hmacSha1.update(buffer);
		
		try{
			hmacSha1.doFinal(output, offset);
		}
		catch(ShortBufferException e){
			System.err.println("Output buffer is too short: " + e.getMessage());
		}
		catch(IllegalStateException e){
			System.err.println("Illegal state: " + e.getMessage());
		}
	}
}
