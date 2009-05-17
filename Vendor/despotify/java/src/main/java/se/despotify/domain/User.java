package se.despotify.domain;

import se.despotify.domain.media.PlaylistContainer;

/**
 *
 * @since 2009-apr-24 07:03:09
 */
public class User {

  private String name;
  private PlaylistContainer playlists = null;


  public String getName() {
    return name;
  }

  public void setName(String name) {
    this.name = name;
  }

  public PlaylistContainer getPlaylists() {
    return playlists;
  }

  public void setPlaylists(PlaylistContainer playlists) {
    this.playlists = playlists;
  }

}
