package se.despotify.client.protocol.command.media.playlist;

import org.junit.Test;
import se.despotify.DespotifyClientTest;
import se.despotify.domain.media.Playlist;
import se.despotify.util.SpotifyURI;
import se.despotify.util.SpotifyURL;

/**
 * @since 2009-apr-25 14:59:00
 */
public class TestLoadPlaylist extends DespotifyClientTest {


  @Test
  public void test() throws Exception {

    Playlist playlist;

    try {
      // this playlist contains a bad checksum
      playlist = (Playlist) SpotifyURL.browse("spotify:user:kent.finell:playlist:6Odybr7gR4L9LwO8dBgBwS", store, connection);
      fail("Bad checksum in playlist, should not be valid.");
    } catch (Exception e) {
      e.printStackTrace();
    }


//    MediaTestCaseGenerator.createEqualsTest((Playlist)SpotifyURL.browse("spotify:user:kent.finell:playlist:6wvPFkLGKOVl1v3qRJD6HX", connection));

    playlist = store.getPlaylist(SpotifyURI.toHex("6wvPFkLGKOVl1v3qRJD6HX"));
    new LoadPlaylist(store, playlist).send(connection.getProtocol());

    assertEquals("despotify apriori", playlist.getName());   
    assertEquals(7l, playlist.getRevision().longValue());
    assertEquals(3794544626l, playlist.getChecksum().longValue());
    assertEquals(3794544626l, playlist.calculateChecksum());
    assertEquals("kent.finell", playlist.getAuthor());
    assertFalse(playlist.isCollaborative());
    assertEquals("d65f21be4a744a88ea67d8a83c7a2eb5", playlist.getHexUUID());
    assertEquals(5, playlist.getTracks().size());

    assertEquals("93f98ea75b4748f797668485a3d01bd0", playlist.getTracks().get(0).getHexUUID());
    assertEquals("spotify:track:4vdV2Eua6RkUoUM51jdH56", playlist.getTracks().get(0).getSpotifyURL());
    assertEquals("http://open.spotify.com/track/4vdV2Eua6RkUoUM51jdH56", playlist.getTracks().get(0).getHttpURL());
    assertNull(playlist.getTracks().get(0).getTitle());
    assertNull(playlist.getTracks().get(0).getCover());
    assertNull(playlist.getTracks().get(0).getFiles());
    assertNull(playlist.getTracks().get(0).getLength());
    assertNull(playlist.getTracks().get(0).getPopularity());
    assertNull(playlist.getTracks().get(0).getTrackNumber());
    assertNull(playlist.getTracks().get(0).getYear());

    assertEquals("cf2cd530980e450d855977ba0a80ec6e", playlist.getTracks().get(1).getHexUUID());
    assertEquals("spotify:track:6iVTOPCmpABvG9jDZ2JozY", playlist.getTracks().get(1).getSpotifyURL());
    assertEquals("http://open.spotify.com/track/6iVTOPCmpABvG9jDZ2JozY", playlist.getTracks().get(1).getHttpURL());
    assertNull(playlist.getTracks().get(1).getTitle());
    assertNull(playlist.getTracks().get(1).getCover());
    assertNull(playlist.getTracks().get(1).getFiles());
    assertNull(playlist.getTracks().get(1).getLength());
    assertNull(playlist.getTracks().get(1).getPopularity());
    assertNull(playlist.getTracks().get(1).getTrackNumber());
    assertNull(playlist.getTracks().get(1).getYear());

    assertEquals("fc1f1b5860f04a739971fcad9c1cd634", playlist.getTracks().get(2).getHexUUID());
    assertEquals("spotify:track:7FKhuZtIPchBVNIhFnNL5W", playlist.getTracks().get(2).getSpotifyURL());
    assertEquals("http://open.spotify.com/track/7FKhuZtIPchBVNIhFnNL5W", playlist.getTracks().get(2).getHttpURL());
    assertNull(playlist.getTracks().get(2).getTitle());
    assertNull(playlist.getTracks().get(2).getCover());
    assertNull(playlist.getTracks().get(2).getFiles());
    assertNull(playlist.getTracks().get(2).getLength());
    assertNull(playlist.getTracks().get(2).getPopularity());
    assertNull(playlist.getTracks().get(2).getTrackNumber());
    assertNull(playlist.getTracks().get(2).getYear());

    assertEquals("7093f50c9ecf428eb780348c076f9f7f", playlist.getTracks().get(3).getHexUUID());
    assertEquals("spotify:track:3qqKWUVfiLMrNPacFRzTzh", playlist.getTracks().get(3).getSpotifyURL());
    assertEquals("http://open.spotify.com/track/3qqKWUVfiLMrNPacFRzTzh", playlist.getTracks().get(3).getHttpURL());
    assertNull(playlist.getTracks().get(3).getTitle());
    assertNull(playlist.getTracks().get(3).getCover());
    assertNull(playlist.getTracks().get(3).getFiles());
    assertNull(playlist.getTracks().get(3).getLength());
    assertNull(playlist.getTracks().get(3).getPopularity());
    assertNull(playlist.getTracks().get(3).getTrackNumber());
    assertNull(playlist.getTracks().get(3).getYear());

    assertEquals("48daf12f96f84793a526b579aa4d1f66", playlist.getTracks().get(4).getHexUUID());
    assertEquals("spotify:track:2dtvgPd3vsotKXtGk4dWlg", playlist.getTracks().get(4).getSpotifyURL());
    assertEquals("http://open.spotify.com/track/2dtvgPd3vsotKXtGk4dWlg", playlist.getTracks().get(4).getHttpURL());
    assertNull(playlist.getTracks().get(4).getTitle());
    assertNull(playlist.getTracks().get(4).getCover());
    assertNull(playlist.getTracks().get(4).getFiles());
    assertNull(playlist.getTracks().get(4).getLength());
    assertNull(playlist.getTracks().get(4).getPopularity());
    assertNull(playlist.getTracks().get(4).getTrackNumber());
    assertNull(playlist.getTracks().get(4).getYear());


  }

}
