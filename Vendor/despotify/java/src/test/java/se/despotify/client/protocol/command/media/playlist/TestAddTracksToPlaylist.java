package se.despotify.client.protocol.command.media.playlist;

import org.junit.Test;
import se.despotify.DespotifyClientTest;
import se.despotify.domain.media.Playlist;

import java.util.Random;

/**
 * @since 2009-apr-23 09:56:01
 */
public class TestAddTracksToPlaylist extends DespotifyClientTest {

  @Test
  public void testAddTracksToPlaylist() throws Exception {

    String playlistName = randomPlaylistName();


    new LoadUserPlaylists(store, user).send(connection.getProtocol());
    int playlistsFromStart = user.getPlaylists().getItems().size();

    Playlist playlist = new CreatePlaylist(store, user, playlistName, false).send(connection.getProtocol());

    assertEquals(playlistsFromStart + 1, user.getPlaylists().getItems().size());

    long[] checksums = new long[]{
        1461913864l,
        823267316l,
        2339641349l,
        1904484306l,
        3794544626l,
    };

    for (int i = 0; i < checksums.length; i++) {
      log.info("\n\n\n\n\n\n\n           ADD TRACK " + i + "\n\n\n\n\n\n\n\n\n");
      new AddTrackToPlaylist(store, user, playlist, defaultTracks[i], null).send(connection.getProtocol());
      assertEquals(checksums[i], playlist.calculateChecksum());
      assertEquals(checksums[i], playlist.getChecksum().longValue());
      assertEquals(i + 1, playlist.getTracks().size());
      assertEquals(defaultTracks[i], playlist.getTracks().get(i));

      // todo get list using alternative connection and assert the same

    }

    for (int i = checksums.length; i > 1; i--) {
      log.info("\n\n\n\n\n\n\n           REMOVE TRACK " + i + "\n\n\n\n\n\n\n\n\n");
      new RemoveTrackFromPlaylist(store, user, playlist, i).send(connection.getProtocol());
      assertEquals(checksums[i - 2], playlist.calculateChecksum());
      assertEquals(checksums[i - 2], playlist.getChecksum().longValue());
      assertEquals(i - 1, playlist.getTracks().size());

      // todo get list using alternative connection and assert the same

    }

    assertTrue(new RemovePlaylistFromUser(store, user, playlist).send(connection.getProtocol()));

    assertEquals(playlistsFromStart, user.getPlaylists().getItems().size());

  }
}

//