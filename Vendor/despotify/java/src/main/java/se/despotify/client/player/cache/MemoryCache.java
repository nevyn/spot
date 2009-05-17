package se.despotify.client.player.cache;

import java.util.HashMap;
import java.util.Map;

public class MemoryCache implements Cache {
	private Map<String, byte[]> data = new HashMap<String, byte[]>();
	
	public MemoryCache(){
		this.data = new HashMap<String, byte[]>();
	}
	
	public void clear(){
		this.data.clear();
	}
	
	public void clear(String category){
		for(String key : this.data.keySet()){
			if(key.startsWith(category + "-")){
				this.data.remove(key);
			}
		}
	}
	
	public boolean contains(String category, String hash){
		return this.data.containsKey(category + "-" + hash);
	}
	
	public byte[] load(String category, String hash){
		return this.data.get(category + "-" + hash);
	}
	
	public void remove(String category, String hash){
		this.data.remove(category + "-" + hash);
	}
	
	public void store(String category, String hash, byte[] data){
		this.data.put(category + "-" + hash, data);
	}
}
