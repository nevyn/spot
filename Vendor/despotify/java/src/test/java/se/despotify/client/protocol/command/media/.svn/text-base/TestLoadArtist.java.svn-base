package se.despotify.client.protocol.command.media;

import org.junit.Test;
import se.despotify.DespotifyClientTest;
import se.despotify.domain.MemoryStore;
import se.despotify.domain.media.Artist;
import se.despotify.domain.media.VisitorAdapter;

/**
 * @since 2009-apr-25 18:28:29
 */
public class TestLoadArtist extends DespotifyClientTest {

  @Test
  public void test() throws Exception {

    for (Artist artist : defaultArtists) {
      new LoadArtist(store, artist).send(connection.getProtocol());
    }

//    for (Artist artist : defaultArtists) {
//      MediaTestCaseGenerator.createEqualsTest(artist, "artist = store.getArtist(\"" + artist.getHexUUID() + "\");\n" +
//          "    new LoadArtist(store, artist).send(connection.getProtocol());\n" +
//          "    artist");
//    }
//    System.out.flush();
    

    MemoryStore store = new MemoryStore();

    Artist artist;

    // generated tests

    artist = store.getArtist("d00d9e7b82894fb8851a109c82568eb5");
    new LoadArtist(store, artist).send(connection.getProtocol());
    artist.accept(new VisitorAdapter() {
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
    artist = store.getArtist("4f9873e19e5a4b4096c216c98bcdb010");
    new LoadArtist(store, artist).send(connection.getProtocol());
    artist.accept(new VisitorAdapter() {
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
    artist = store.getArtist("db614c7060fc47baa7be732d88ae446d");
    new LoadArtist(store, artist).send(connection.getProtocol());
    artist.accept(new VisitorAdapter() {
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
    artist = store.getArtist("f4d5d82d09124feda0633a2671f8c81a");
    new LoadArtist(store, artist).send(connection.getProtocol());
    artist.accept(new VisitorAdapter() {
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
    artist = store.getArtist("f6150726a8e94c89a7cf336d3f72be9c");
    new LoadArtist(store, artist).send(connection.getProtocol());
    artist.accept(new VisitorAdapter() {
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


    // generated tests stops
  }


}