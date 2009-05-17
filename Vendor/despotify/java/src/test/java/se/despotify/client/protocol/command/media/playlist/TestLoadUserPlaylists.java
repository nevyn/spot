package se.despotify.client.protocol.command.media.playlist;

import org.junit.Test;
import se.despotify.DespotifyClientTest;
import se.despotify.domain.media.Playlist;
import se.despotify.domain.media.PlaylistContainer;

/**
 *
 * @since 2009-apr-22 03:00:06
 */
public class TestLoadUserPlaylists extends DespotifyClientTest {

  @Test
  public void testGetPlaylists() throws Exception {

    new LoadUserPlaylists(store, user).send(connection.getProtocol());
    PlaylistContainer playlists  = user.getPlaylists();
    assertNotNull(playlists);
    assertEquals(username, playlists.getAuthor());
    for (Playlist playlist : playlists) {      
      assertEquals(16, playlist.getUUID().length);
      testGetPlaylist(playlist);
    }


  }


  private void testGetPlaylist(Playlist playlist) throws Exception {


    assertNull(playlist.getName());

    System.out.println("asserting playlist " + playlist.toString());

    new LoadPlaylist(store, playlist).send(connection.getProtocol());

    assertNotNull(playlist.getName());

    System.err.println(playlist.getName() + "\t" + playlist.getSpotifyURL());

    assertNotNull(playlist);
    assertNotNull(playlist.getUUID());
    assertNotNull(playlist.getName());
    assertNotNull(playlist.getAuthor());
    assertNotNull(playlist.isCollaborative());
    assertNotNull(playlist.getChecksum());

  }




}
