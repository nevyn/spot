package se.despotify.client.protocol;

import se.despotify.crypto.*;
import se.despotify.crypto.DH.DHKeyPair;
import se.despotify.crypto.RSA.RSAKeyPair;
import se.despotify.domain.User;
import se.despotify.exceptions.AuthenticationException;
import se.despotify.exceptions.ConnectionException;
import se.despotify.exceptions.DespotifyException;

import javax.crypto.interfaces.DHPublicKey;
import java.nio.ByteBuffer;
import java.security.interfaces.RSAPublicKey;
import java.util.Arrays;
import java.util.Random;

public class Session {
	/* Spotify protocol to send and receive data. */
	private Protocol protocol;
	
	/* Client identification */
	protected byte[] clientId;
	protected int    clientRevision;
	
	/* 16 bytes of Shannon encryption output with random key */
	protected byte[] clientRandom;
	protected byte[] serverRandom;
	
	/* 
	 * Blob (1536-bit RSA signature at offset 128)
	 * is received at offset 16 in the cmd=0x02 packet.
	 */
	protected byte[] serverBlob;
	
	/* Username, password, salt, auth hash, auth HMAC and country. */
	protected byte[] username;
	protected byte[] password;
	protected byte[] salt;
	protected byte[] authHash;
	protected String country;

  private final User user;

	/* DH and RSA keys. */
	protected DHKeyPair   dhClientKeyPair;
	protected DHPublicKey dhServerPublicKey;
	protected byte[]      dhSharedKey;
	protected RSAKeyPair  rsaClientKeyPair;
	
	/* 
	 * Output form HMAC SHA-1, used for keying HMAC
	 * and for keying Shannon stream cipher.
	 */
	protected byte[] keyHmac;
	protected byte[] authHmac;
	protected byte[] keyRecv;
	protected byte[] keySend;
	protected int    keyRecvIv;
	protected int    keySendIv;
	
	/* Shannon stream cipher */
	protected Shannon shannonSend;
	protected Shannon shannonRecv;
	
	/*
	 * Waste some CPU time while computing a 32-bit value,
	 * that byteswapped and XOR'ed with a magic, modulus
	 * 2^deniminator becomes zero.
	 */
	protected int    puzzleDenominator;
	protected int    puzzleMagic;
	protected byte[] puzzleSolution;
	
	/* Cache hash. Automatically generated, but we're lazy. */
	protected byte[] cacheHash;
	
	/* Needed for auth hmac. */
	protected byte[] initialClientPacket;
	protected byte[] initialServerPacket;

  // FIXED:
  /**
   * Client revision sent to Spotify.
   * 99999 is used by despotify,
   * so I thought it could be fun for Spotify with 99987 for java despotify.
   *
   * TODO:
   * Best would perhaps be to automatically detect the current revision
   * by sending a burst of inital packets until found, save that value
   * in a file. Perhaps the despotify also connects to the  spotify repository
   * and makes sure no update of the lib is required.
   */
	public static final int CLIENT_REVISION = 99876;
	
	public Session(){
		this(-1);
	}
	
	/* Constructor for a new spotify session. */
	public Session(int revision){
    this.user = new User();

		/* Initialize protocol with this session. */
		this.protocol = new Protocol(this);
		
		/* Set client identification (Spotify 0.3.12 / r45126). */
		this.clientId       = new byte[]{0x01, 0x04, 0x01, 0x01};
		this.clientRevision = (revision < 0)?CLIENT_REVISION:revision;
		
		/* Client and server generate 16 random bytes each. */
		this.clientRandom = new byte[16];
		this.serverRandom = new byte[16];
		
		RandomBytes.randomBytes(this.clientRandom);
		
		/* Allocate buffer for server RSA key. */
		this.serverBlob = new byte[256];
		
		/* Allocate buffer for salt and auth hash. */
		this.salt     = new byte[10];
		this.authHash = new byte[20];
		
		/*
		 * Create a private and public DH key and allocate buffer
		 * for shared key. This, along with key signing, is used
		 * to securely agree on a session key for the Shannon stream
		 * cipher.
		 */
		this.dhClientKeyPair = DH.generateKeyPair(768);
		this.dhSharedKey     = new byte[96];
		
		/* Generate RSA key pair. */
		this.rsaClientKeyPair = RSA.generateKeyPair(1024);
		
		/* Allocate buffers for HMAC and Shannon stream cipher keys. */
		this.keyHmac   = new byte[20];
		this.authHmac  = new byte[20];
		this.keyRecv   = new byte[32];
		this.keySend   = new byte[32];
		this.keyRecvIv = 0;
		this.keySendIv = 0;
		
		/* Stream cipher instances. */
		this.shannonRecv = new Shannon();
		this.shannonSend = new Shannon();
		
		/* Allocate buffer for puzzle solution. */
		this.puzzleDenominator = 0;
		this.puzzleMagic       = 0;
		this.puzzleSolution    = new byte[8];
		
		/* Found in Storage.dat (cache) at offset 16. Modify first byte of cache hash. */
		this.cacheHash = new byte[]{
			(byte)0xf4, (byte)0xc2, (byte)0xaa, (byte)0x05,
			(byte)0xe8, (byte)0x25, (byte)0xa7, (byte)0xb5,
			(byte)0xe4, (byte)0xe6, (byte)0x59, (byte)0x0f,
			(byte)0x3d, (byte)0xd0, (byte)0xbe, (byte)0x0a,
			(byte)0xef, (byte)0x20, (byte)0x51, (byte)0x95
		};
		this.cacheHash[0] = (byte)new Random().nextInt();
		
		/* Not initialized. */
		this.initialClientPacket = null;
		this.initialServerPacket = null;
	}
	
	public String getUsername(){
		return new String(this.username);
	}
	
	public RSAPublicKey getRSAPublicKey(){
		return this.rsaClientKeyPair.getPublicKey();
	}
	
	public Protocol authenticate(String username, String password) throws DespotifyException {
		/* Set username and password. */
		this.username = username.getBytes();
		this.password = password.getBytes();
		
		/* Connect to a spotify server. */
		this.protocol.connect();

		/* Send and receive inital packets. */
    this.protocol.sendInitialPacket();
    this.protocol.receiveInitialPacket();


    user.setName(username);
		
		/* Generate auth hash. */
		this.generateAuthHash();
		
		/* Compute shared key (Diffie Hellman key exchange). */
		this.dhSharedKey = DH.computeSharedKey(
			this.dhClientKeyPair.getPrivateKey(),
			this.dhServerPublicKey
		);
		
		/* Prepare a message to authenticate. */
		ByteBuffer buffer = ByteBuffer.allocate(
			this.authHash.length + this.clientRandom.length + this.serverRandom.length + 1
		);
		
		/* Append auth hash, client and server random to message. */
		buffer.put(this.authHash);
		buffer.put(this.clientRandom);
		buffer.put(this.serverRandom);
		buffer.put((byte)0x00); /* Changed later */
		buffer.flip();
		
		/* Get message bytes and allocate space for HMACs. */
		byte[] bytes  = new byte[buffer.remaining()];
		byte[] hmac   = new byte[5 * 20];
		int    offset = 0;
		
		buffer.get(bytes);
		
		/* Run HMAC SHA-1 over message. 5 times. */
		for(int i = 1; i <= 5; i++){
			/* Change last byte (53) of message. */
			bytes[bytes.length - 1] = (byte)i;
			
			/* Compute HMAC SHA-1 using the shared key. */
			Hash.hmacSha1(bytes, this.dhSharedKey, hmac, offset);
			
			/* Overwrite first 20 bytes of message with output from this round. */
      System.arraycopy(hmac, offset, bytes, 0, 20);
			
			/* Advance to next position. */
			offset += 20;
		}
		
		/* Use field of HMACs to setup keys for Shannon stream cipher (key length: 32). */
		this.keySend = Arrays.copyOfRange(hmac, 20, 20 + 32);
		this.keyRecv = Arrays.copyOfRange(hmac, 52, 52 + 32);
		
		/* Set stream cipher keys. */
		this.shannonSend.key(this.keySend);
		this.shannonRecv.key(this.keyRecv);
		
		/* 
		 * First 20 bytes of HMAC output is used to key another HMAC computed
		 * for the second authentication packet send by the client.
		 */
		this.keyHmac = Arrays.copyOfRange(hmac, 0, 20);
		
		/* Solve puzzle */
		this.solvePuzzle();
		
		/* Generate HMAC */
		this.generateAuthHmac();
		
		/* Send authentication. */
		try{
			this.protocol.sendAuthenticationPacket();
			this.protocol.receiveAuthenticationPacket();
		}
		catch(DespotifyException e){
			throw new AuthenticationException(e.getMessage());
		}
		
		return this.protocol;
	}
	
	private void generateAuthHash(){
		ByteBuffer buffer = ByteBuffer.allocate(this.salt.length + 1 + this.password.length);
		
		buffer.put(this.salt); /* 10 bytes */
		buffer.put((byte)' ');
		buffer.put(this.password);
		
		this.authHash = Hash.sha1(buffer.array());
	}
	
	private void generateAuthHmac(){
		ByteBuffer buffer = ByteBuffer.allocate(
			this.initialClientPacket.length +
			this.initialServerPacket.length +
			1 + 1 + 2 + 4 + 0 + this.puzzleSolution.length
		);
		
		buffer.put(this.initialClientPacket);
		buffer.put(this.initialServerPacket);
		buffer.put((byte)0); /* Random data length */
		buffer.put((byte)0); /* Unknown */
		buffer.putShort((short)this.puzzleSolution.length);
		buffer.putInt(0x0000000); /* Unknown */
		//buffer.put(randomBytes); /* Zero random bytes :-) */
		buffer.put(this.puzzleSolution); /* 8 bytes */
		
		this.authHmac = Hash.hmacSha1(buffer.array(), this.keyHmac);
	}
	
	private void solvePuzzle(){
		long denominator, nominatorFromHash;
		byte[] digest;
		
		ByteBuffer buffer = ByteBuffer.allocate(
			this.serverRandom.length + this.puzzleSolution.length
		);
		
		/* Modulus operation by a power of two. */
		denominator = 1 << this.puzzleDenominator;
		denominator--;
		
		/* 
		 * Compute a hash over random data until
		 * (last dword byteswapped XOR magic number)
		 * mod denominator by server produces zero.
		 */
		do {
			/* Let's waste some precious pseudorandomness. */
			RandomBytes.randomBytes(this.puzzleSolution);
			
			/* Buffer with server random and random bytes (puzzle solution). */
			buffer.clear();
			buffer.put(this.serverRandom);
			buffer.put(this.puzzleSolution);
			
			/* Calculate digest. */
			digest = Hash.sha1(buffer.array());
			
			/* Convert bytes to integer (Java is big-endian). */
			nominatorFromHash = ((digest[16] & 0xFF) << 24) |
								((digest[17] & 0xFF) << 16) |
								((digest[18] & 0xFF) << 8)  |
								((digest[19] & 0xFF));
			
			/* XOR with a fancy magic. */
			nominatorFromHash ^= this.puzzleMagic;
		} while((nominatorFromHash & denominator) != 0);
	}

  public User getUser() {
    return user;
  }
}
