package se.despotify.client.protocol.channel;

import se.despotify.util.ShortUtilities;

import java.util.Arrays;
import java.util.HashMap;
import java.util.Map;

public class Channel {
	/* Static channel id counter. */
	private static int nextId = 0;
	private static Map<Integer, Channel> channels;
	
	static {
		Channel.channels = new HashMap<Integer, Channel>();
	}
	
	/* Channel variables. */
	private int             id;
	private String          name;
	private State           state;
	private Type            type;
	private int             headerLength;
	private int             dataLength;
	private ChannelListener listener;
	
	public Channel(String name, Type type, ChannelListener listener){
		this.id           = Channel.nextId++;
		this.name         = name + "-" + this.id;
		this.state        = State.STATE_HEADER;
		this.type         = type;
		this.headerLength = 0;
		this.dataLength   = 0;
		this.listener     = listener;
		
		/* Force data state for AES key channel. */
		if(this.type.equals(Type.TYPE_AESKEY)){
			this.state = State.STATE_DATA;
		}
	}
	
	public int getId(){
		return this.id;
	}
	
	public String getName(){
		return this.name;
	}
	
	public State getState(){
		return this.state;
	}
	
	public Type getType(){
		return this.type;
	}
	
	public int getHeaderLength(){
		return this.headerLength;
	}
	
	public int getDataLength(){
		return this.dataLength;
	}
	
	public static void register(Channel channel){
		Channel.channels.put(channel.getId(), channel);
	}
	
	public static void unregister(int id){
		Channel.channels.remove(id);
	}
	
	public static void process(byte[] payload){
		Channel channel;
		int     offset         = 0;
		int     length         = payload.length;
		int     headerLength   = 0;
		int     consumedLength = 0;
		
		/* Get Channel by id from payload. */
		if((channel = Channel.channels.get(ShortUtilities.bytesToUnsignedShort(payload))) == null){
			System.err.println("Channel not found!");
			
			return;
		};
		
		offset += 2;
		length -= 2;
		
		if(channel.state.equals(State.STATE_HEADER)){
			if(length < 2){
				System.err.println("Length is smaller than 2!");
				
				return; 
			}
			
			while(consumedLength < length){
				/* Extract length of next data. */
				headerLength = ShortUtilities.bytesToUnsignedShort(payload, offset);
				
				offset         += 2;
				consumedLength += 2;
				
				if(headerLength == 0){
					break;
				}
				
				if(consumedLength + headerLength > length){
					System.err.println("Not enough data!");
					
					return;
				}
				
				if(channel.listener != null){
					channel.listener.channelHeader(channel,
						Arrays.copyOfRange(payload, offset, offset + headerLength)
					);
				}
				
				offset         += headerLength;
				consumedLength += headerLength;
				
				channel.headerLength += headerLength;
			}
			
			if(consumedLength != length){
				System.err.println("Didn't consume all data!");
				
				return;
			}
			
			/* Upgrade state if this was the last (zero size) header. */
			if(headerLength == 0){
				channel.state = State.STATE_DATA;
			}
			
			return;
		}
		
		/*
		 * Now we're either in the CHANNEL_DATA or CHANNEL_ERROR state.
		 * If in CHANNEL_DATA and length is zero, switch to CHANNEL_END,
		 * thus letting the callback routine know this is the last packet.
		 */
		if(length == 0){
			channel.state = State.STATE_END;
			
			if(channel.listener != null){
				channel.listener.channelEnd(channel);
			}
		}
		else{
			if(channel.listener != null){
				channel.listener.channelData(channel,
					Arrays.copyOfRange(payload, offset, offset + length)
				);
			}
		}
		
		channel.dataLength += length;
		
		/* If this is an AES key channel, force end state. */
		if(channel.type.equals(Type.TYPE_AESKEY)){
			channel.state = State.STATE_END;
			
			if(channel.listener != null){
				channel.listener.channelEnd(channel);
			}
		}
	}
	
	public static void error(byte[] payload){
		Channel channel;
		
		/* Get Channel by id from payload. */
		if((channel = Channel.channels.get(ShortUtilities.bytesToUnsignedShort(payload))) == null){
			System.err.println("Channel not found!");
			
			return;
		};
		
		if(channel.listener != null){
			channel.listener.channelError(channel);
		}
		
		Channel.channels.remove(channel.getId());
	}
	
	public enum State {
		STATE_HEADER,
		STATE_DATA,
		STATE_END,
		STATE_ERROR
	}
	
	public enum Type {
		TYPE_AD,
		TYPE_IMAGE,
		TYPE_SEARCH,
		TYPE_AESKEY,
		TYPE_SUBSTREAM,
		TYPE_BROWSE,
		TYPE_PLAYLIST
	}
}
