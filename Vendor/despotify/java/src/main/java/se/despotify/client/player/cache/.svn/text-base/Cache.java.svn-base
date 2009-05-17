package se.despotify.client.player.cache;

public interface Cache {
	public void clear();
	public void clear(String category);
	public boolean contains(String category, String hash);
	public byte[] load(String category, String hash);
	public void remove(String category, String hash);
	public void store(String category, String hash, byte[] data);
}
