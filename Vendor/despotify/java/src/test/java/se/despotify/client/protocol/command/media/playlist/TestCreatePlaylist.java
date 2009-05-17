package se.despotify.client.protocol.command.media.playlist;

import org.junit.Test;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import se.despotify.DespotifyClientTest;
import se.despotify.domain.MemoryStore;
import se.despotify.domain.media.Playlist;
import se.despotify.util.Hex;
import se.despotify.util.SpotifyURI;

import java.util.Random;

/**
 *
 * @since 2009-apr-22 03:00:06
 */
public class TestCreatePlaylist extends DespotifyClientTest {

  private static final Logger log = LoggerFactory.getLogger(TestCreatePlaylist.class);

  @Test
  public void testCreatePlaylist() throws Exception {

    String playlistName = randomPlaylistName();
    
    log.info("\n\n\n\n\n\n\n           create playlist named "+playlistName+"\n\n\n\n\n\n\n\n\n");

    Playlist originalPlaylist = new CreatePlaylist(new MemoryStore(), user, playlistName, false).send(connection.getProtocol());


    log.info("\n\n\n\n\n\n\n           load playlist with UUID "+Hex.toHex(originalPlaylist.getUUID())+"\n\n             spotify:user:"+ username + ":playlist:" + SpotifyURI.toURI(Hex.toHex(originalPlaylist.getUUID())) +"\n\n\n\n\n\n\n\n\n");

    // brand new store to make sure we dont pick something up from the cache.
    MemoryStore store = new MemoryStore();
    Playlist loadedPlaylist = store.getPlaylist(originalPlaylist.getUUID());
    new LoadPlaylist(store, loadedPlaylist).send(connection.getProtocol());

    assertTrue("different stores means different instances", loadedPlaylist != originalPlaylist);   
    assertEquals(loadedPlaylist.getChecksum().longValue(), loadedPlaylist.calculateChecksum());
    assertEquals(originalPlaylist.getHexUUID(), loadedPlaylist.getHexUUID());
    // todo assert the rest

  }



}