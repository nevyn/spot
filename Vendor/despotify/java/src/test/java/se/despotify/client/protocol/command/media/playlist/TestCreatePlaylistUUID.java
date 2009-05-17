package se.despotify.client.protocol.command.media.playlist;

import org.junit.Test;
import se.despotify.DespotifyClientTest;
import se.despotify.util.Hex;

import java.util.Random;

/**
 * @since 2009-apr-24 09:03:13
 */
public class TestCreatePlaylistUUID extends DespotifyClientTest {

  @Test
  public void test() throws Exception {

    String playlistName = randomPlaylistName();
    

    byte[] UUID = new ReserveRandomPlaylistUUID(store, user, playlistName, false).send(connection.getProtocol());
    assertNotNull(UUID);
    assertEquals(16, UUID.length);
    
  }

}
