package se.despotify.util;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.nio.ByteBuffer;
import java.util.LinkedList;
import java.util.List;
import java.util.zip.GZIPInputStream;

public class GZIP {
	private static final int BUFFER_SIZE = 4096;
	
	public static byte[] inflate(byte[] bytes){
		ByteArrayInputStream byteArrayInputStream;
		GZIPInputStream      gzipInputStream;
		List<ByteBuffer>     buffers;
		ByteBuffer           buffer;
		int                  nbytes;
		
		/* Get InputStream of bytes. */
		byteArrayInputStream = new ByteArrayInputStream(bytes);
		
		/* Allocate buffer. */
		buffer  = ByteBuffer.allocate(GZIP.BUFFER_SIZE);
		buffers = new LinkedList<ByteBuffer>();
		nbytes  = 0;
		
		/* Inflate deflated data. */
		try{
			gzipInputStream = new GZIPInputStream(byteArrayInputStream);
			
			while(gzipInputStream.available() > 0){
				if(!buffer.hasRemaining()){
					nbytes += buffer.position();
					
					buffer.flip();
					buffers.add(buffer);
					
					buffer = ByteBuffer.allocate(GZIP.BUFFER_SIZE);
				}
				
				buffer.put((byte)gzipInputStream.read());
			}
		}
		catch(IOException e){
			/* 
			 * This also catches EOFException's. Do nothing, just return what we
			 * decompressed so far.
			 */
		}
		
		byte[]     data       = new byte[nbytes + buffer.position()];
		ByteBuffer dataBuffer = ByteBuffer.wrap(data);
		
		buffer.flip();
		buffers.add(buffer);
		
		for(ByteBuffer b : buffers){
			dataBuffer.put(b);
		}
		
		return data;
	}
}
