package se.despotify.client.protocol.channel;

import javax.crypto.BadPaddingException;
import javax.crypto.Cipher;
import javax.crypto.IllegalBlockSizeException;
import javax.crypto.NoSuchPaddingException;
import javax.crypto.spec.IvParameterSpec;
import javax.crypto.spec.SecretKeySpec;
import java.io.IOException;
import java.io.OutputStream;
import java.security.InvalidAlgorithmParameterException;
import java.security.InvalidKeyException;
import java.security.Key;
import java.security.NoSuchAlgorithmException;

public class ChannelAudioHandler implements ChannelListener {
	private Cipher       cipher;
	private Key          key;
	private byte[]       iv;
	private int          offset;
	private OutputStream output;
	
	public ChannelAudioHandler(byte[] key, OutputStream output){
		/* Get AES cipher instance. */
		try {
			this.cipher = Cipher.getInstance("AES/CTR/NoPadding");
		}
		catch (NoSuchAlgorithmException e){
			System.err.println("AES not available! Aargh!");
		}
		catch (NoSuchPaddingException e){
			System.out.println("No padding not available... haha!");
		}
		
		/* Create secret key from bytes. */
		this.key = new SecretKeySpec(key, "AES");
		
		/* Set IV. */
		this.iv = new byte[]{
			(byte)0x72, (byte)0xe0, (byte)0x67, (byte)0xfb,
			(byte)0xdd, (byte)0xcb, (byte)0xcf, (byte)0x77,
			(byte)0xeb, (byte)0xe8, (byte)0xbc, (byte)0x64,
			(byte)0x3f, (byte)0x63, (byte)0x0d, (byte)0x93
		};
		
		/* Initialize cipher with key and iv in encrypt mode. */
		try {
			this.cipher.init(Cipher.ENCRYPT_MODE, this.key, new IvParameterSpec(this.iv));
		}
		catch (InvalidKeyException e){
			System.out.println("Invalid key!");
		}
		catch (InvalidAlgorithmParameterException e){
			System.out.println("Invalid IV!");
		}
		
		/* Set output stream. */
		this.output = output;
	}
	
	public void channelHeader(Channel channel, byte[] header){
		/* Do nothing. */
	}
	
	public void channelData(Channel channel, byte[] data){
		/* Offsets needed for deinterleaving. */
		int off, w, x, y, z;
		
		/* Allocate space for ciphertext. */
		byte[] ciphertext = new byte[data.length + 1024];
		byte[] keystream  = new byte[16];
		
		/* Decrypt each 1024 byte block. */
		for(int block = 0; block < data.length / 1024; block++){
			/* Deinterleave the 4x256 byte blocks. */
			off = block * 1024;
			w	= block * 1024 + 0 * 256;
			x	= block * 1024 + 1 * 256;
			y	= block * 1024 + 2 * 256;
			z	= block * 1024 + 3 * 256;
			
			for(int i = 0; i < 1024 && (block * 1024 + i) < data.length; i += 4){
				ciphertext[off++] = data[w++];
				ciphertext[off++] = data[x++];
				ciphertext[off++] = data[y++];
				ciphertext[off++] = data[z++];
			}
			
			/* Decrypt 1024 bytes block. This will fail for the last block. */
			for(int i = 0; i < 1024 && (block * 1024 + i) < data.length; i += 16){
				/* Produce 16 bytes of keystream from the IV. */
				try{
					keystream = this.cipher.doFinal(this.iv);
				}
				catch(IllegalBlockSizeException e){
					e.printStackTrace();
				}
				catch(BadPaddingException e){
					e.printStackTrace();
				}
				
				/* 
				 * Produce plaintext by XORing ciphertext with keystream.
				 * And somehow I also need to XOR with the IV... Please
				 * somebody tell me what I'm doing wrong, or is it the
				 * Java implementation of AES? At least it works like this.
				 */
				for(int j = 0; j < 16; j++){
					ciphertext[block * 1024 + i + j] ^= keystream[j] ^ this.iv[j];
				}

				/* Update IV counter. */
				for(int j = 15; j >= 0; j--){
					this.iv[j] += 1;
					
					if((int)(this.iv[j] & 0xFF) != 0){
						break;
					}
				}
				
				/* Set new IV. */
				try{
					this.cipher.init(Cipher.ENCRYPT_MODE, this.key, new IvParameterSpec(this.iv));
				}
				catch(InvalidKeyException e){
					e.printStackTrace();
				}
				catch(InvalidAlgorithmParameterException e){
					e.printStackTrace();
				}
			}
		}
		
		/* Write data to output stream. */
		try{
			this.output.write(ciphertext, 0, ciphertext.length - 1024);
		}
		catch(IOException e){
			/* Just don't care... */
		}
	}
	
	public void channelEnd(Channel channel){
		this.offset += channel.getDataLength();
		
		Channel.unregister(channel.getId());
	}
	
	public void channelError(Channel channel){
		/* Do nothing. */
	}
}
