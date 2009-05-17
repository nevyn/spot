package se.despotify.client.protocol.command.media.playlist;

import org.junit.Test;
import se.despotify.DespotifyClientTest;
import se.despotify.client.protocol.command.media.LoadTracks;
import se.despotify.client.protocol.command.media.LoadArtist;
import se.despotify.domain.media.*;
import se.despotify.util.SpotifyURI;
import se.despotify.util.SpotifyURL;

/**
 * This test loads a playlist,
 * then the tracks of that playlist,
 * and then all artists of all tracks,
 * and makes sure everything is loaded the way it should.
 *
 * todo images
 *
 * @since 2009-apr-25 14:59:00
 */
public class TestStore extends DespotifyClientTest {


  @Test
  public void test() throws Exception {

    Playlist playlist;

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

    // load all tracks

    new LoadTracks(store, playlist.getTracks()).send(connection.getProtocol());

    // assert tracks

//    for (int i = 0; i < playlist.getTracks().size(); i++) {
//      MediaTestCaseGenerator.createEqualsTest(playlist.getTracks().get(i), "playlist.getTracks().get(" + i + ")");
//    }


      playlist.getTracks().get(0).accept(new VisitorAdapter() {
      @Override
      public void visit(Track track) {

        assertEquals("93f98ea75b4748f797668485a3d01bd0", track.getHexUUID());
        assertEquals("spotify:track:4vdV2Eua6RkUoUM51jdH56", track.getSpotifyURL());
        assertEquals("http://open.spotify.com/track/4vdV2Eua6RkUoUM51jdH56", track.getHttpURL());
        assertEquals("One", track.getTitle());
        assertEquals("d37dda0ea348147ce6b9b8cf0b4a5b98d3894ef9", track.getCover());
        assertEquals(1, track.getFiles().size());
        assertEquals("36fa172ca1a707ba71e79757f3014cc1a26fbbf6", track.getFiles().get(0));
        assertEquals(231200l, track.getLength().longValue());
        assertTrue(track.getPopularity() > 0f);
        assertEquals(20, track.getTrackNumber().intValue());
        assertEquals(2005, track.getYear().intValue());

        assertEquals("d00d9e7b82894fb8851a109c82568eb5", track.getArtist().getHexUUID());
        assertEquals("spotify:artist:6kACVPfCOnqzgfEF5ryl0x", track.getArtist().getSpotifyURL());
        assertEquals("http://open.spotify.com/artist/6kACVPfCOnqzgfEF5ryl0x", track.getArtist().getHttpURL());
        assertEquals("Johnny Cash", track.getArtist().getName());
        assertNull(track.getArtist().getPopularity());
        assertNull(track.getArtist().getPortrait());
        // TODO: track.getArtist().getSimilarArtists();

        assertEquals("spotify:album:05BIC4TZptbiQoF03QhojS", track.getAlbum().getSpotifyURL());
        assertEquals("http://open.spotify.com/album/05BIC4TZptbiQoF03QhojS", track.getAlbum().getHttpURL());
        assertEquals("The Legend Of Johnny Cash", track.getAlbum().getName());
        assertNull(track.getAlbum().getCover());
        assertEquals("02f8df4ad52d449caca8c6a25d2eca08", track.getAlbum().getHexUUID());
        assertNull(track.getAlbum().getPopularity());
      }
    });
    playlist.getTracks().get(1).accept(new VisitorAdapter() {
      @Override
      public void visit(Track track) {

        assertEquals("cf2cd530980e450d855977ba0a80ec6e", track.getHexUUID());
        assertEquals("spotify:track:6iVTOPCmpABvG9jDZ2JozY", track.getSpotifyURL());
        assertEquals("http://open.spotify.com/track/6iVTOPCmpABvG9jDZ2JozY", track.getHttpURL());
        assertEquals("Two", track.getTitle());
        assertEquals("0d66f558747f176c8ce787e375686ed83dd23da9", track.getCover());
        assertEquals(1, track.getFiles().size());
        assertEquals("ddc30e1090b43403cc0828db91300450a358a1a8", track.getFiles().get(0));
        assertEquals(158293l, track.getLength().longValue());
        assertTrue(track.getPopularity() > 0f);
        assertEquals(2, track.getTrackNumber().intValue());
        assertEquals(2007, track.getYear().intValue());

        assertEquals("4f9873e19e5a4b4096c216c98bcdb010", track.getArtist().getHexUUID());
        assertEquals("spotify:artist:2qc41rNTtdLK0tV3mJn2Pm", track.getArtist().getSpotifyURL());
        assertEquals("http://open.spotify.com/artist/2qc41rNTtdLK0tV3mJn2Pm", track.getArtist().getHttpURL());
        assertEquals("Ryan Adams", track.getArtist().getName());
        assertNull(track.getArtist().getPopularity());
        assertNull(track.getArtist().getPortrait());
        // TODO: track.getArtist().getSimilarArtists();

        assertEquals("spotify:album:2mLIJwfgNPGjpuKaN7njPm", track.getAlbum().getSpotifyURL());
        assertEquals("http://open.spotify.com/album/2mLIJwfgNPGjpuKaN7njPm", track.getAlbum().getHttpURL());
        assertEquals("Easy Tiger", track.getAlbum().getName());
        assertNull(track.getAlbum().getCover());
        assertEquals("4dc7cec0b8e441daaef85f46a915c7d4", track.getAlbum().getHexUUID());
        assertNull(track.getAlbum().getPopularity());
      }
    });
    playlist.getTracks().get(2).accept(new VisitorAdapter() {
      @Override
      public void visit(Track track) {

        assertEquals("fc1f1b5860f04a739971fcad9c1cd634", track.getHexUUID());
        assertEquals("spotify:track:7FKhuZtIPchBVNIhFnNL5W", track.getSpotifyURL());
        assertEquals("http://open.spotify.com/track/7FKhuZtIPchBVNIhFnNL5W", track.getHttpURL());
        assertEquals("Three", track.getTitle());
        assertEquals("243bf851b18ab38a303d24b4c361f9ba997ad423", track.getCover());
        assertEquals(1, track.getFiles().size());
        assertEquals("6186903f7ffa0e579954fa42c537cebc06ac7427", track.getFiles().get(0));
        assertEquals(229066l, track.getLength().longValue());
        assertTrue(track.getPopularity() > 0f);
        assertEquals(3, track.getTrackNumber().intValue());
        assertEquals(1994, track.getYear().intValue());

        assertEquals("db614c7060fc47baa7be732d88ae446d", track.getArtist().getHexUUID());
        assertEquals("spotify:artist:6FXMGgJwohJLUSr5nVlf9X", track.getArtist().getSpotifyURL());
        assertEquals("http://open.spotify.com/artist/6FXMGgJwohJLUSr5nVlf9X", track.getArtist().getHttpURL());
        assertEquals("Massive Attack", track.getArtist().getName());
        assertNull(track.getArtist().getPopularity());
        assertNull(track.getArtist().getPortrait());
        // TODO: track.getArtist().getSimilarArtists();

        assertEquals("spotify:album:5CnZjFfPDmxOX7KnWLLqpC", track.getAlbum().getSpotifyURL());
        assertEquals("http://open.spotify.com/album/5CnZjFfPDmxOX7KnWLLqpC", track.getAlbum().getHttpURL());
        assertEquals("Protection", track.getAlbum().getName());
        assertNull(track.getAlbum().getCover());
        assertEquals("b8a09d31b4994b79a01f966b86cb9394", track.getAlbum().getHexUUID());
        assertNull(track.getAlbum().getPopularity());
      }
    });
    playlist.getTracks().get(3).accept(new VisitorAdapter() {
      @Override
      public void visit(Track track) {

        assertEquals("7093f50c9ecf428eb780348c076f9f7f", track.getHexUUID());
        assertEquals("spotify:track:3qqKWUVfiLMrNPacFRzTzh", track.getSpotifyURL());
        assertEquals("http://open.spotify.com/track/3qqKWUVfiLMrNPacFRzTzh", track.getHttpURL());
        assertEquals("Four", track.getTitle());
        assertEquals("0b85aa8202d8f5a49006e721e34a72200904220a", track.getCover());
        assertEquals(1, track.getFiles().size());
        assertEquals("55473589cbccde7f9621fea833f38487f92f2892", track.getFiles().get(0));
        assertEquals(240226l, track.getLength().longValue());
        assertTrue(track.getPopularity() > 0f);
        assertEquals(3, track.getTrackNumber().intValue());
        assertEquals(1986, track.getYear().intValue());

        assertEquals("f4d5d82d09124feda0633a2671f8c81a", track.getArtist().getHexUUID());
        assertEquals("spotify:artist:7rZR0ugcLEhNrFYOrUtZii", track.getArtist().getSpotifyURL());
        assertEquals("http://open.spotify.com/artist/7rZR0ugcLEhNrFYOrUtZii", track.getArtist().getHttpURL());
        assertEquals("Miles Davis", track.getArtist().getName());
        assertNull(track.getArtist().getPopularity());
        assertNull(track.getArtist().getPortrait());
        // TODO: track.getArtist().getSimilarArtists();

        assertEquals("spotify:album:6eEhgZIrHftYRvgpAKJC2K", track.getAlbum().getSpotifyURL());
        assertEquals("http://open.spotify.com/album/6eEhgZIrHftYRvgpAKJC2K", track.getAlbum().getHttpURL());
        assertEquals("Miles Davis And The Jazz Giants", track.getAlbum().getName());
        assertNull(track.getAlbum().getCover());
        assertEquals("cce79af3bd864a799806a557877dda7a", track.getAlbum().getHexUUID());
        assertNull(track.getAlbum().getPopularity());
      }
    });
    playlist.getTracks().get(4).accept(new VisitorAdapter() {
      @Override
      public void visit(Track track) {

        assertEquals("48daf12f96f84793a526b579aa4d1f66", track.getHexUUID());
        assertEquals("spotify:track:2dtvgPd3vsotKXtGk4dWlg", track.getSpotifyURL());
        assertEquals("http://open.spotify.com/track/2dtvgPd3vsotKXtGk4dWlg", track.getHttpURL());
        assertEquals("Five", track.getTitle());
        assertEquals("24238c9ac14f1a10758a85ea66531b0d88b085f8", track.getCover());
        assertEquals(1, track.getFiles().size());
        assertEquals("534ba228b88d1d5e468bc865b33b755aae61e181", track.getFiles().get(0));
        assertEquals(385000l, track.getLength().longValue());
        assertTrue(track.getPopularity() > 0f);
        assertEquals(9, track.getTrackNumber().intValue());
        assertEquals(2007, track.getYear().intValue());

        assertEquals("f6150726a8e94c89a7cf336d3f72be9c", track.getArtist().getHexUUID());
        assertEquals("spotify:artist:7ulIMfVKiXh8ecEpAVHIAY", track.getArtist().getSpotifyURL());
        assertEquals("http://open.spotify.com/artist/7ulIMfVKiXh8ecEpAVHIAY", track.getArtist().getHttpURL());
        assertEquals("Electrelane", track.getArtist().getName());
        assertNull(track.getArtist().getPopularity());
        assertNull(track.getArtist().getPortrait());
        // TODO: track.getArtist().getSimilarArtists();

        assertEquals("spotify:album:3GETv5yNXeM0cnhq8XahWu", track.getAlbum().getSpotifyURL());
        assertEquals("http://open.spotify.com/album/3GETv5yNXeM0cnhq8XahWu", track.getAlbum().getHttpURL());
        assertEquals("No Shouts, No Calls", track.getAlbum().getName());
        assertNull(track.getAlbum().getCover());
        assertEquals("792d90d6e5c14679afd00e7ea28982ce", track.getAlbum().getHexUUID());
        assertNull(track.getAlbum().getPopularity());
      }
    });


    // load artists in tracks

    for (Track track : playlist.getTracks()) {
      new LoadArtist(store, track.getArtist()).send(connection.getProtocol());
    }

    // assert artists

//    for (int i = 0; i < playlist.getTracks().size(); i++) {
//      MediaTestCaseGenerator.createEqualsTest(playlist.getTracks().get(i).getArtist(), "playlist.getTracks().get(" + i + ").getArtist()");
//    }

    playlist.getTracks().get(0).getArtist().accept(new VisitorAdapter() {
      @Override
      public void visit(Artist artist) {
        assertEquals("d00d9e7b82894fb8851a109c82568eb5", artist.getHexUUID());
        assertEquals("spotify:artist:6kACVPfCOnqzgfEF5ryl0x", artist.getSpotifyURL());
        assertEquals("http://open.spotify.com/artist/6kACVPfCOnqzgfEF5ryl0x", artist.getHttpURL());
        assertEquals("Johnny Cash", artist.getName());
//        assertNull(artist.getPopularity());
//        assertNull(artist.getPortrait());
        // TODO: artist.getSimilarArtists();
      }
    });
    playlist.getTracks().get(1).getArtist().accept(new VisitorAdapter() {
      @Override
      public void visit(Artist artist) {
        assertEquals("4f9873e19e5a4b4096c216c98bcdb010", artist.getHexUUID());
        assertEquals("spotify:artist:2qc41rNTtdLK0tV3mJn2Pm", artist.getSpotifyURL());
        assertEquals("http://open.spotify.com/artist/2qc41rNTtdLK0tV3mJn2Pm", artist.getHttpURL());
        assertEquals("Ryan Adams", artist.getName());
//        assertNull(artist.getPopularity());
//        assertNull(artist.getPortrait());
        // TODO: artist.getSimilarArtists();
      }
    });
    playlist.getTracks().get(2).getArtist().accept(new VisitorAdapter() {
      @Override
      public void visit(Artist artist) {
        assertEquals("db614c7060fc47baa7be732d88ae446d", artist.getHexUUID());
        assertEquals("spotify:artist:6FXMGgJwohJLUSr5nVlf9X", artist.getSpotifyURL());
        assertEquals("http://open.spotify.com/artist/6FXMGgJwohJLUSr5nVlf9X", artist.getHttpURL());
        assertEquals("Massive Attack", artist.getName());
//        assertNull(artist.getPopularity());
//        assertNull(artist.getPortrait());
        // TODO: artist.getSimilarArtists();
      }
    });
    playlist.getTracks().get(3).getArtist().accept(new VisitorAdapter() {
      @Override
      public void visit(Artist artist) {
        assertEquals("f4d5d82d09124feda0633a2671f8c81a", artist.getHexUUID());
        assertEquals("spotify:artist:7rZR0ugcLEhNrFYOrUtZii", artist.getSpotifyURL());
        assertEquals("http://open.spotify.com/artist/7rZR0ugcLEhNrFYOrUtZii", artist.getHttpURL());
        assertEquals("Miles Davis", artist.getName());
//        assertNull(artist.getPopularity());
//        assertNull(artist.getPortrait());
        // TODO: artist.getSimilarArtists();
      }
    });
    playlist.getTracks().get(4).getArtist().accept(new VisitorAdapter() {
      @Override
      public void visit(Artist artist) {
        assertEquals("f6150726a8e94c89a7cf336d3f72be9c", artist.getHexUUID());
        assertEquals("spotify:artist:7ulIMfVKiXh8ecEpAVHIAY", artist.getSpotifyURL());
        assertEquals("http://open.spotify.com/artist/7ulIMfVKiXh8ecEpAVHIAY", artist.getHttpURL());
        assertEquals("Electrelane", artist.getName());
//        assertNull(artist.getPopularity());
//        assertNull(artist.getPortrait());
        // TODO: artist.getSimilarArtists();
      }
    });

  }

}