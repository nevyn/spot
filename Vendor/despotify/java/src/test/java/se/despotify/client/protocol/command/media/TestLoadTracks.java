package se.despotify.client.protocol.command.media;

import org.junit.Test;
import se.despotify.DespotifyClientTest;
import se.despotify.domain.media.Track;
import se.despotify.domain.media.VisitorAdapter;

/**
 * @since 2009-apr-25 16:26:54
 */
public class TestLoadTracks extends DespotifyClientTest {

  @Test
  public void test() throws Exception {

    new LoadTracks(store, defaultTracks).send(connection.getProtocol());

//    for (Track track : defaultTracks) {
//      MediaTestCaseGenerator.createEqualsTest(track, "track = store.getTrack(\"" + track.getHexUUID() + "\");\n" +
//          "    new LoadTracks(store, track).send(connection.getProtocol());\n" +
//          "    track");
//    }
//    System.out.flush();

    Track track;

    // generated tests

    track = store.getTrack("93f98ea75b4748f797668485a3d01bd0");
    new LoadTracks(store, track).send(connection.getProtocol());
    track.accept(new VisitorAdapter() {
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
    track = store.getTrack("cf2cd530980e450d855977ba0a80ec6e");
    new LoadTracks(store, track).send(connection.getProtocol());
    track.accept(new VisitorAdapter() {
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
    track = store.getTrack("fc1f1b5860f04a739971fcad9c1cd634");
    new LoadTracks(store, track).send(connection.getProtocol());
    track.accept(new VisitorAdapter() {
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
    track = store.getTrack("7093f50c9ecf428eb780348c076f9f7f");
    new LoadTracks(store, track).send(connection.getProtocol());
    track.accept(new VisitorAdapter() {
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
    track = store.getTrack("48daf12f96f84793a526b579aa4d1f66");
    new LoadTracks(store, track).send(connection.getProtocol());
    track.accept(new VisitorAdapter() {
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


    // end generated tests
  }

}
