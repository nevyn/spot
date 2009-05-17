package se.despotify;

import org.junit.Test;
import se.despotify.client.protocol.command.media.playlist.LoadUserPlaylists;
import se.despotify.client.protocol.command.media.playlist.LoadPlaylist;
import se.despotify.client.protocol.command.media.playlist.RemovePlaylistFromUser;
import se.despotify.domain.media.Playlist;

/**
 * not really a test. removes all playlists from user if they match despotify_[^_]+_[^_]+
 *
 * @since 2009-apr-28 03:26:50
 */
public class Clean extends DespotifyClientTest {

  @Test
  public void test() throws Exception {

    new LoadUserPlaylists(store, user).send(connection.getProtocol());

    System.out.println("loaded user playlists");

    for (Playlist playlist : user.getPlaylists()) {
      new LoadPlaylist(store, playlist).send(connection.getProtocol());

      System.out.println("loaded content of user playlist " + playlist.getName());
    }

    System.out.println("loaded content of user playlists");

    for (int i = user.getPlaylists().getItems().size() - 1; i > 0; i--) {
      Playlist playlist = user.getPlaylists().getItems().get(i);
      if (playlist.getName().startsWith("despotify_Test")) {
        new RemovePlaylistFromUser(store, user, playlist).send(connection.getProtocol());
      }
    }
  }

}
