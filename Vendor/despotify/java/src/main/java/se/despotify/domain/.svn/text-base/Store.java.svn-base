package se.despotify.domain;

import se.despotify.domain.media.*;
import se.despotify.util.Hex;


/**
 * @since 2009-apr-25 17:30:25
 */
public abstract class Store {

  public abstract Playlist getPlaylist(byte[] UUID);
  public abstract Album getAlbum(byte[] UUID);
  public abstract Artist getArtist(byte[] UUID);
  public abstract Track getTrack(byte[] UUID);
  public abstract Image getImage(byte[] UUID);


  public Image getImage(String hexUUID) {
    return getImage(Hex.toBytes(hexUUID));
  }

  public Playlist getPlaylist(String hexUUID) {
    return getPlaylist(Hex.toBytes(hexUUID));
  }

  public Album getAlbum(String hexUUID) {
    return getAlbum(Hex.toBytes(hexUUID));
  }

  public Artist getArtist(String hexUUID) {
    return getArtist(Hex.toBytes(hexUUID));
  }

  public Track getTrack(String hexUUID) {
    return getTrack(Hex.toBytes(hexUUID));
  }



}
