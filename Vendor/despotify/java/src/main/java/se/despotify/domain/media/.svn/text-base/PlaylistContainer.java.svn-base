package se.despotify.domain.media;

import se.despotify.domain.Store;
import se.despotify.util.ChecksumCalculator;
import se.despotify.util.XMLElement;

import java.util.Iterator;
import java.util.List;
import java.util.ArrayList;

public class PlaylistContainer implements Iterable<Playlist> {
	private String         author;
	private List<Playlist> items;
	private long           revision;
	private long           checksum;

  public PlaylistContainer(){
		this.author    = null;
		this.items = new ArrayList<Playlist>();
		this.revision  = -1;
		this.checksum  = -1;
	}

  public long calculateChecksum() {
    ChecksumCalculator calculator = new ChecksumCalculator();
    for (Playlist playlist : items) {
      playlist.accept(calculator);
    }
    return calculator.getValue();
  }

	public String getAuthor(){
		return this.author;
	}
	
	public void setAuthor(String author){
		this.author = author;
	}
	
	public List<Playlist> getItems(){
		return this.items;
	}
	
	public void setItems(List<Playlist> items){
		this.items = items;
	}
	
	public long getRevision(){
		return this.revision;
	}
	
	public void setRevision(long revision){
		this.revision = revision;
	}
	
	public long getChecksum(){
		return this.checksum;
	}
	
	public void setChecksum(long checksum){
		this.checksum = checksum;
	}
	
	public Iterator<Playlist> iterator(){
		return this.items.iterator();
	}


	public static PlaylistContainer fromXMLElement(XMLElement playlistsElement, Store store, PlaylistContainer playlists){

		/* Get "change" element. */
		XMLElement changeElement = playlistsElement.getChild("next-change").getChild("change");
		
		if (changeElement.hasChild("user")) {
		  playlists.author = changeElement.getChildText("user").trim();
    }
		
		/* Get items (comma separated list). */
		if(changeElement.getChild("ops").hasChild("add")){
			String items = changeElement.getChild("ops").getChild("add").getChildText("items");
			
			for(String playlistUUID : items.split(",")){
        playlistUUID = playlistUUID.trim();
        if (playlistUUID.length() == 34 && playlistUUID.endsWith("02")) {
          playlistUUID = playlistUUID.substring(0, 32);
        }
        Playlist playlist = store.getPlaylist(playlistUUID);
        if (!playlists.getItems().contains(playlist)) {
          playlists.getItems().add(playlist);
        }
        // todo remove deleted?
			}
		}
		
		/* Get "version" element. */
		XMLElement versionElement = playlistsElement.getChild("next-change").getChild("version");
		
		/* Split version string into parts. */
		String[] versionTagValues = versionElement.getText().split(",", 4);

    playlists.setRevision(Long.parseLong(versionTagValues[0]));
    playlists.setChecksum(Long.parseLong(versionTagValues[2]));

    if (playlists.getItems().size() != Long.parseLong(versionTagValues[1])) {
      throw new RuntimeException();
    }
    if (playlists.calculateChecksum() != playlists.getChecksum()) {
      throw new RuntimeException();
    }

		return playlists;
	}

  @Override
  public String toString() {
    return "PlaylistContainer{" +
        "author='" + author + '\'' +
        ", items=" + (items == null ? null : items.size())  +
        ", revision=" + revision +
        ", checksum=" + checksum +
        '}';
  }
}
