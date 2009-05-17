package se.despotify.domain;

import se.despotify.domain.media.*;
import se.despotify.util.Hex;

import java.util.HashMap;
import java.util.Map;

/**
 * @since 2009-apr-25 17:41:41
 */
public class MemoryStore extends Store {

  public Map<String, Playlist> playlists = new HashMap<String, Playlist>();
  public Map<String, Album> albums = new HashMap<String, Album>();
  public Map<String, Artist> artists = new HashMap<String, Artist>();
  public Map<String, Track> tracks = new HashMap<String, Track>();
  public Map<String, Image> images = new HashMap<String, Image>();


  @Override
  public Playlist getPlaylist(byte[] UUID) {
    String hexUUID = Hex.toHex(UUID);
    Playlist playlist = playlists.get(hexUUID);
    if (playlist == null) {
      playlists.put(hexUUID, playlist = new Playlist(UUID));
    }
    return playlist;
  }

  @Override
  public Album getAlbum(byte[] UUID) {
    String hexUUID = Hex.toHex(UUID);

    Album album = albums.get(hexUUID);
    if (album == null) {
      albums.put(hexUUID, album = new Album(UUID));
    }
    return album;
  }

  @Override
  public Artist getArtist(byte[] UUID) {
    String hexUUID = Hex.toHex(UUID);

    Artist artist = artists.get(hexUUID);
    if (artist == null) {
      artists.put(hexUUID, artist = new Artist(UUID));
    }
    return artist;
  }

  @Override
  public Track getTrack(byte[] UUID) {
    String hexUUID = Hex.toHex(UUID);

    Track track = tracks.get(hexUUID);
    if (track == null) {
      tracks.put(hexUUID, track = new Track(UUID));
    }
    return track;
  }


  @Override
  public Image getImage(byte[] UUID) {
    String hexUUID = Hex.toHex(UUID);
    Image image = images.get(hexUUID);
    if (image == null) {
      images.put(hexUUID, image = new Image(UUID));
    }
    return image;
  }

  @Override
  public Playlist getPlaylist(String hexUUID) {
    Playlist playlist = playlists.get(hexUUID);
    if (playlist == null) {
      playlists.put(hexUUID, playlist = new Playlist(hexUUID));
    }
    return playlist;

  }

  @Override
  public Album getAlbum(String hexUUID) {
    Album album = albums.get(hexUUID);
    if (album == null) {
      albums.put(hexUUID, album = new Album(hexUUID));
    }
    return album;

  }

  @Override
  public Artist getArtist(String hexUUID) {
    Artist artist = artists.get(hexUUID);
    if (artist == null) {
      artists.put(hexUUID, artist = new Artist(hexUUID));
    }
    return artist;

  }

  @Override
  public Track getTrack(String hexUUID) {
    Track track = tracks.get(hexUUID);
    if (track == null) {
      tracks.put(hexUUID, track = new Track(hexUUID));
    }
    return track;

  }

  @Override
   public Image getImage(String hexUUID) {
     Image image = images.get(hexUUID);
     if (image == null) {
       images.put(hexUUID, image = new Image(hexUUID));
     }
     return image;

   }

}