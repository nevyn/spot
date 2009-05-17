package se.despotify.client.protocol.channel;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import se.despotify.exceptions.TimeoutException;
import se.despotify.util.Hex;

import java.nio.ByteBuffer;
import java.util.LinkedList;
import java.util.List;
import java.util.concurrent.Semaphore;
import java.util.concurrent.TimeUnit;

public class ChannelCallback implements ChannelListener {

  private static Logger log = LoggerFactory.getLogger(ChannelCallback.class);

  private long defaultTimeout = 60;
  private TimeUnit defaultTimeoutUnit = TimeUnit.SECONDS;

	private Semaphore        done;
	private List<ByteBuffer> buffers;
	private int              bytes;
	
	public ChannelCallback(){
		this.done    = new Semaphore(1);
		this.buffers = new LinkedList<ByteBuffer>();
		this.bytes   = 0;
		
		this.done.acquireUninterruptibly();
	}
	
	public void channelData(Channel channel, byte[] data){
		ByteBuffer buffer = ByteBuffer.wrap(data);
		
		this.bytes += data.length;
		
		this.buffers.add(buffer);
	}
	
	public void channelEnd(Channel channel){
		Channel.unregister(channel.getId());
		
		this.done.release();
	}
	
	public void channelError(Channel channel){
		this.done.release();
	}
	
	public void channelHeader(Channel channel, byte[] header){
		/* Ignore */
	}

  @Deprecated
   /**
    * @deprecated use {@link #getData(String, long, java.util.concurrent.TimeUnit)}
    */
   public byte[] getData() {
     return getData("anonymous packet", defaultTimeout,  defaultTimeoutUnit);
   }

  public byte[] getData(String packetDescription) {
    return getData(packetDescription, defaultTimeout,  defaultTimeoutUnit);
  }

  @Deprecated
  /**
   * @deprecated use {@link #getData(String, long, java.util.concurrent.TimeUnit)}
   */
  public byte[] getData(long timeout, TimeUnit timeoutUnit) {
    return getData("anonymous packet", timeout,  timeoutUnit);
  }

  /**
   *
   * @param packetDescription true if log data received. set false when they contain GZIPed data et c.
   * @param timeout
   * @param timeoutUnit
   * @return
   */
	public byte[] getData(String packetDescription, long timeout, TimeUnit timeoutUnit){

    if (packetDescription != null && log.isDebugEnabled()) {
      log.debug("waiting for "+packetDescription+" data from server.");
    }

    long started = System.currentTimeMillis();

    try {
      // wait for data to become available.
      if (!this.done.tryAcquire(timeout, timeoutUnit)) {
        throw new TimeoutException(System.currentTimeMillis() - started);
      }
    } catch (InterruptedException e) {
      log.error("Exception while waiting for data", e);
    }
//    this.done.acquireUninterruptibly();
		
		/* Data buffer. */
		ByteBuffer data = ByteBuffer.allocate(this.bytes);
		
		for(ByteBuffer b : this.buffers){
			data.put(b);
		}

    byte[] arr = data.array();

    long millisecondsSpent = System.currentTimeMillis() - started;

    if (packetDescription != null && log.isInfoEnabled()) {
      log.info("received " + packetDescription + " containing" + arr.length + " bytes in " + millisecondsSpent + " milliseconds:\n" + Hex.log(arr, log));
    }

		/* Return data bytes. */
		return arr;
	}
}
