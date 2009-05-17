package se.despotify.client.protocol.command.media.playlist;

import se.despotify.DespotifyClientTest;
import se.despotify.domain.media.Playlist;
import se.despotify.util.Hex;
import org.junit.Test;

import java.util.Random;

/**
 * @since 2009-apr-28 01:59:33
 */
public class TestRemovePlaylist extends DespotifyClientTest {    

  @Test
  public void test() throws Exception {

    String playlistName = randomPlaylistName();

    new LoadUserPlaylists(store, user).send(connection.getProtocol());
    int originalSize = user.getPlaylists().getItems().size();

    Playlist playlist = new CreatePlaylist(store, user, playlistName, false).send(connection.getProtocol());
    assertEquals(originalSize + 1, user.getPlaylists().getItems().size());
    assertTrue(user.getPlaylists().getItems().contains(playlist));

    new RemovePlaylistFromUser(store, user, playlist).send(connection.getProtocol());
    assertEquals(originalSize, user.getPlaylists().getItems().size());
    assertFalse(user.getPlaylists().getItems().contains(playlist));

    reset();

    new LoadUserPlaylists(store, user).send(connection.getProtocol());
    assertEquals(originalSize, user.getPlaylists().getItems().size());
    for (Playlist playlist2 : user.getPlaylists()) {
      assertNotSame(playlist.getUUID(), playlist2.getUUID());
    }
    

    // todo can we still load it?

  }


}
