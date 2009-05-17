package se.despotify.crypto;

import java.security.KeyPair;
import java.security.KeyPairGenerator;
import java.security.NoSuchAlgorithmException;
import java.security.interfaces.RSAKey;
import java.security.interfaces.RSAPrivateKey;
import java.security.interfaces.RSAPublicKey;
import java.util.Arrays;

public class RSA {
	private static KeyPairGenerator keyPairGenerator;
	private static RSA              instance;
	
	static{
		try{
			keyPairGenerator = KeyPairGenerator.getInstance("RSA");
		}
		catch(NoSuchAlgorithmException e){
			System.err.println("Algorithm not available: " + e.getMessage());
		}
		
		instance = new RSA();
	}
	
	public static RSAKeyPair generateKeyPair(int keysize){
		if(keyPairGenerator == null){
			return null;
		}
		
		/* Initialize key pair generator with keysize in bits */
		keyPairGenerator.initialize(keysize);
		
		/* Generate key pair */
		KeyPair keyPair = keyPairGenerator.generateKeyPair();
		
		/* Return key pair */
		return instance.new RSAKeyPair(keyPair);
	}
	
	public static byte[] keyToBytes(RSAKey key){
		byte[] bytes = key.getModulus().toByteArray();
		
		if(bytes.length % 8 != 0 && bytes[0] == 0x00){
			bytes = Arrays.copyOfRange(bytes, 1, bytes.length);
		}
		
		return bytes;
	}
	
	public class RSAKeyPair {
		private RSAPublicKey  publicKey;
		private RSAPrivateKey privateKey;
		
		public RSAKeyPair(RSAPublicKey publicKey, RSAPrivateKey privateKey){
			this.publicKey  = publicKey;
			this.privateKey = privateKey;
		}
		
		public RSAKeyPair(KeyPair keyPair){			
			this((RSAPublicKey)keyPair.getPublic(), (RSAPrivateKey)keyPair.getPrivate());
		}

		public RSAPublicKey getPublicKey(){
			return this.publicKey;
		}
		
		public byte[] getPublicKeyBytes(){
			return keyToBytes(this.publicKey);
		}

		public RSAPrivateKey getPrivateKey(){
			return this.privateKey;
		}
		
		public byte[] getPrivateKeyBytes(){
			return keyToBytes(this.privateKey);
		}
	}
}
