package se.despotify.crypto;

import javax.crypto.KeyAgreement;
import javax.crypto.interfaces.DHKey;
import javax.crypto.interfaces.DHPrivateKey;
import javax.crypto.interfaces.DHPublicKey;
import javax.crypto.spec.DHParameterSpec;
import javax.crypto.spec.DHPrivateKeySpec;
import javax.crypto.spec.DHPublicKeySpec;
import java.math.BigInteger;
import java.nio.ByteBuffer;
import java.security.*;
import java.security.spec.InvalidKeySpecException;
import java.security.spec.KeySpec;
import java.util.Arrays;

public class DH {
	private static KeyPairGenerator keyPairGenerator;
	private static KeyAgreement     keyAgreement;
	private static KeyFactory       keyFactory;
	private static DH               instance;
	
	private static BigInteger generator = new BigInteger("2");
	private static BigInteger prime     = bytesToBigInteger(new byte[]{
		/* Well-known Group 1, 768-bit prime */
		(byte)0xff, (byte)0xff, (byte)0xff, (byte)0xff, (byte)0xff, (byte)0xff, (byte)0xff, (byte)0xff,
		(byte)0xc9, (byte)0x0f, (byte)0xda, (byte)0xa2, (byte)0x21, (byte)0x68, (byte)0xc2, (byte)0x34,
		(byte)0xc4, (byte)0xc6, (byte)0x62, (byte)0x8b, (byte)0x80, (byte)0xdc, (byte)0x1c, (byte)0xd1,
		(byte)0x29, (byte)0x02, (byte)0x4e, (byte)0x08, (byte)0x8a, (byte)0x67, (byte)0xcc, (byte)0x74,
		(byte)0x02, (byte)0x0b, (byte)0xbe, (byte)0xa6, (byte)0x3b, (byte)0x13, (byte)0x9b, (byte)0x22,
		(byte)0x51, (byte)0x4a, (byte)0x08, (byte)0x79, (byte)0x8e, (byte)0x34, (byte)0x04, (byte)0xdd,
		(byte)0xef, (byte)0x95, (byte)0x19, (byte)0xb3, (byte)0xcd, (byte)0x3a, (byte)0x43, (byte)0x1b,
		(byte)0x30, (byte)0x2b, (byte)0x0a, (byte)0x6d, (byte)0xf2, (byte)0x5f, (byte)0x14, (byte)0x37,
		(byte)0x4f, (byte)0xe1, (byte)0x35, (byte)0x6d, (byte)0x6d, (byte)0x51, (byte)0xc2, (byte)0x45,
		(byte)0xe4, (byte)0x85, (byte)0xb5, (byte)0x76, (byte)0x62, (byte)0x5e, (byte)0x7e, (byte)0xc6,
		(byte)0xf4, (byte)0x4c, (byte)0x42, (byte)0xe9, (byte)0xa6, (byte)0x3a, (byte)0x36, (byte)0x20,
		(byte)0xff, (byte)0xff, (byte)0xff, (byte)0xff, (byte)0xff, (byte)0xff, (byte)0xff, (byte)0xff
	});
	
	static{
		try{
			keyPairGenerator = KeyPairGenerator.getInstance("DH");
			keyAgreement     = KeyAgreement.getInstance("DH");
			keyFactory       = KeyFactory.getInstance("DH");
		}
		catch(NoSuchAlgorithmException e){
			System.err.println("Algorithm not available: " + e.getMessage());
		}
		
		instance = new DH();
	}
	
	public static DHKeyPair generateKeyPair(int keysize){
		if(keyPairGenerator == null){
			return null;
		}
		
		/* Initialize key pair generator with prime, generator and keysize */
		try{
			keyPairGenerator.initialize(
				new DHParameterSpec(prime, generator, keysize)
			);
		}
		catch(InvalidAlgorithmParameterException e){
			System.err.println("Invalid parameter spec: " + e.getMessage());
			
			return null;
		}
		
		/* Generate key pair */
		KeyPair keyPair = keyPairGenerator.generateKeyPair();
		
		/* Return key pair */
		return instance.new DHKeyPair(keyPair);
	}
	
	public static byte[] computeSharedKey(DHPrivateKey privateKey, DHPublicKey publicKey){
		if(keyAgreement == null){
			return null;
		}
		
		try{
			keyAgreement.init(privateKey);
			keyAgreement.doPhase(publicKey, true);
		}
		catch(InvalidKeyException e){
			System.err.println("Invalid key: " + e.getMessage());
			
			return null;
		}
		
		return keyAgreement.generateSecret();
	}
	
	public static BigInteger bytesToBigInteger(byte[] bytes){
		/* Pad with 0x00 so we don't get a negative BigInteger!!! */
		ByteBuffer key = ByteBuffer.allocate(bytes.length + 1);
		
		key.put((byte)0x00);
		key.put(bytes);
		
		return new BigInteger(key.array());
	}
	
	public static byte[] keyToBytes(DHKey key){
		byte[] bytes = null;
		
		if(key instanceof DHPublicKey){
			bytes = ((DHPublicKey)key).getY().toByteArray();
		}
		else if(key instanceof DHPrivateKey){
			bytes = ((DHPrivateKey)key).getX().toByteArray();
		}
		
		if(bytes == null){
			return null;
		}
		
		if(bytes.length % 8 != 0 && bytes[0] == 0x00){
			bytes = Arrays.copyOfRange(bytes, 1, bytes.length);
		}
		
		return bytes;
	}
	
	public static DHPublicKey bytesToPublicKey(DHParameterSpec parameterSpec, byte[] bytes){
		/* Set Y (public key), P and G values. */
		KeySpec keySpec = new DHPublicKeySpec(
			bytesToBigInteger(bytes),
			parameterSpec.getP(),
			parameterSpec.getG()
		);
		
		/* Generate public key from key spec */
		try{
			return (DHPublicKey)keyFactory.generatePublic(keySpec);
		}
		catch(InvalidKeySpecException e){
			System.err.println("Invalid key spec: " + e.getMessage());
		}
		
		return null;
	}
	
	public static DHPrivateKey bytesToPrivateKey(DHParameterSpec parameterSpec, byte[] bytes){
		/* Set X (private key), P and G values. */
		KeySpec keySpec = new DHPrivateKeySpec(
			bytesToBigInteger(bytes),
			parameterSpec.getP(),
			parameterSpec.getG()
		);
		
		/* Generate private key from key spec */
		try{
			return (DHPrivateKey)keyFactory.generatePrivate(keySpec);
		}
		catch(InvalidKeySpecException e){
			System.err.println("Invalid key spec: " + e.getMessage());
		}
		
		return null;
	}
	
	public class DHKeyPair {
		private DHPublicKey  publicKey;
		private DHPrivateKey privateKey;
		
		public DHKeyPair(DHPublicKey publicKey, DHPrivateKey privateKey){
			this.publicKey  = publicKey;
			this.privateKey = privateKey;
		}
		
		public DHKeyPair(KeyPair keyPair){			
			this((DHPublicKey)keyPair.getPublic(), (DHPrivateKey)keyPair.getPrivate());
		}

		public DHPublicKey getPublicKey(){
			return this.publicKey;
		}
		
		public byte[] getPublicKeyBytes(){
			return keyToBytes(this.publicKey);
		}

		public DHPrivateKey getPrivateKey(){
			return this.privateKey;
		}
		
		public byte[] getPrivateKeyBytes(){
			return keyToBytes(this.privateKey);
		}
	}
}
