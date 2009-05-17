package se.despotify.domain.media;

import se.despotify.domain.Store;
import se.despotify.util.XMLElement;

import java.util.List;
import java.util.ArrayList;

public class Result {
	private int          version;
	private String       query;
	private String       suggestion;
	private int          totalArtists;
	private int          totalAlbums;
	private int          totalTracks;
	private List<Artist> artists;
	private List<Album>  albums;
	private List<Track>  tracks;
	
	public Result(){
		this.version      = 1;
		this.query        = null;
		this.suggestion   = null;
		this.totalArtists = 0;
		this.totalAlbums  = 0;
		this.totalTracks  = 0;
		this.artists      = new ArrayList<Artist>();
		this.albums       = new ArrayList<Album>();
		this.tracks       = new ArrayList<Track>();
	}
	
	public int getVersion(){
		return this.version;
	}
	
	public String getQuery(){
		return this.query;
	}
	
	public String getSuggestion(){
		return this.suggestion;
	}
	
	public int getTotalArtists(){
		return this.totalArtists;
	}
	
	public int getTotalAlbums(){
		return this.totalAlbums;
	}
	
	public int getTotalTracks(){
		return this.totalTracks;
	}
	
	public List<Artist> getArtists(){
		return this.artists;
	}
	
	public List<Album> getAlbums(){
		return this.albums;
	}
	
	public List<Track> getTracks(){
		return this.tracks;
	}
	
	public static Result fromXMLElement(XMLElement resultElement, Store store){

		Result result = new Result();

		if(resultElement.hasChild("version")){
			result.version = Integer.parseInt(resultElement.getChildText("version"));
		}

    // todo only at search time?
		if(resultElement.hasChild("did-you-mean")){
			result.suggestion = resultElement.getChildText("did-you-mean");
		}
		
		// set result quantities
		if(resultElement.hasChild("total-artists")) {
      result.totalArtists = Integer.parseInt(resultElement.getChildText("total-artists"));
    }
		if(resultElement.hasChild("total-albums")) {
      result.totalAlbums  = Integer.parseInt(resultElement.getChildText("total-albums"));
    }
    if(resultElement.hasChild("total-tracks")){
      result.totalTracks  = Integer.parseInt(resultElement.getChildText("total-tracks"));
    }


		if(resultElement.hasChild("artists")){
			for(XMLElement artistElement : resultElement.getChild("artists").getChildren()){
				result.getArtists().add(Artist.fromXMLElement(artistElement, store));
			}
		}
		if(resultElement.hasChild("albums")){
			for(XMLElement albumElement : resultElement.getChild("albums").getChildren()){
				result.getAlbums().add(Album.fromXMLElement(albumElement, store));
			}
		}
		if(resultElement.hasChild("tracks")){
			for(XMLElement trackElement : resultElement.getChild("tracks").getChildren()){
        result.getTracks().add(Track.fromXMLElement(trackElement, store));
			}
		}

    return result;
		
	}

  @Override
  public boolean equals(Object o) {
    if (this == o) return true;
    if (o == null || getClass() != o.getClass()) return false;

    Result result = (Result) o;

    return query.equals(result.query);

  }

  @Override
  public int hashCode() {
    return query.hashCode();
  }
}
