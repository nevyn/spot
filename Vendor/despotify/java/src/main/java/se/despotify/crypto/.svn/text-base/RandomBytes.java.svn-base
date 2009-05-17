package se.despotify.crypto;

import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;

public class RandomBytes {
	private static SecureRandom secureRandom;
	
	static{
		try{
			secureRandom = SecureRandom.getInstance("SHA1PRNG");
		}
		catch(NoSuchAlgorithmException e){
			System.err.println("Algorithm not available: " + e.getMessage());
		}
	}
	
	public static void randomBytes(byte[] buffer){
		if(secureRandom == null){
			return;
		}
		
		secureRandom.nextBytes(buffer);
	}
}
