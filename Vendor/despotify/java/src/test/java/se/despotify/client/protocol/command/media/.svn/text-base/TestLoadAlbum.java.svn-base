package se.despotify.client.protocol.command.media;

import org.junit.Test;
import se.despotify.DespotifyClientTest;
import se.despotify.domain.media.Album;
import se.despotify.domain.media.VisitorAdapter;

/**
 * @since 2009-apr-25 18:28:29
 */
public class TestLoadAlbum extends DespotifyClientTest {

  @Test
  public void test() throws Exception {

    for (Album album : defaultAlbums) {
      new LoadAlbum(store, album).send(connection.getProtocol());
    }

//    for (Album album : defaultAlbums) {
//      MediaTestCaseGenerator.createEqualsTest(album, "album = store.getAlbum(\""+album.getHexUUID()+"\");\n" +
//          "    new LoadAlbum(store, album).send(connection.getProtocol());\n" +
//          "    album");
//    }

    Album album;

    // generated tests follows

    album = store.getAlbum("02f8df4ad52d449caca8c6a25d2eca08");
    new LoadAlbum(store, album).send(connection.getProtocol());
    album.accept(new VisitorAdapter() {
      @Override
      public void visit(Album album) {
        assertEquals("spotify:album:05BIC4TZptbiQoF03QhojS", album.getSpotifyURL());
        assertEquals("http://open.spotify.com/album/05BIC4TZptbiQoF03QhojS", album.getHttpURL());
        assertNull(album.getName());
        assertNull(album.getCover());
        assertEquals("02f8df4ad52d449caca8c6a25d2eca08", album.getHexUUID());
        assertNull(album.getPopularity());

        assertNull(album.getTracks());
        assertNull(album.getArtist());
      }
    });
    album = store.getAlbum("4dc7cec0b8e441daaef85f46a915c7d4");
    new LoadAlbum(store, album).send(connection.getProtocol());
    album.accept(new VisitorAdapter() {
      @Override
      public void visit(Album album) {
        assertEquals("spotify:album:2mLIJwfgNPGjpuKaN7njPm", album.getSpotifyURL());
        assertEquals("http://open.spotify.com/album/2mLIJwfgNPGjpuKaN7njPm", album.getHttpURL());
        assertNull(album.getName());
        assertNull(album.getCover());
        assertEquals("4dc7cec0b8e441daaef85f46a915c7d4", album.getHexUUID());
        assertNull(album.getPopularity());

        assertNull(album.getTracks());
        assertNull(album.getArtist());
      }
    });
    album = store.getAlbum("b8a09d31b4994b79a01f966b86cb9394");
    new LoadAlbum(store, album).send(connection.getProtocol());
    album.accept(new VisitorAdapter() {
      @Override
      public void visit(Album album) {
        assertEquals("spotify:album:5CnZjFfPDmxOX7KnWLLqpC", album.getSpotifyURL());
        assertEquals("http://open.spotify.com/album/5CnZjFfPDmxOX7KnWLLqpC", album.getHttpURL());
        assertNull(album.getName());
        assertNull(album.getCover());
        assertEquals("b8a09d31b4994b79a01f966b86cb9394", album.getHexUUID());
        assertNull(album.getPopularity());

        assertNull(album.getTracks());
        assertNull(album.getArtist());
      }
    });
    album = store.getAlbum("cce79af3bd864a799806a557877dda7a");
    new LoadAlbum(store, album).send(connection.getProtocol());
    album.accept(new VisitorAdapter() {
      @Override
      public void visit(Album album) {
        assertEquals("spotify:album:6eEhgZIrHftYRvgpAKJC2K", album.getSpotifyURL());
        assertEquals("http://open.spotify.com/album/6eEhgZIrHftYRvgpAKJC2K", album.getHttpURL());
        assertNull(album.getName());
        assertNull(album.getCover());
        assertEquals("cce79af3bd864a799806a557877dda7a", album.getHexUUID());
        assertNull(album.getPopularity());

        assertNull(album.getTracks());
        assertNull(album.getArtist());
      }
    });
    album = store.getAlbum("792d90d6e5c14679afd00e7ea28982ce");
    new LoadAlbum(store, album).send(connection.getProtocol());
    album.accept(new VisitorAdapter() {
      @Override
      public void visit(Album album) {
        assertEquals("spotify:album:3GETv5yNXeM0cnhq8XahWu", album.getSpotifyURL());
        assertEquals("http://open.spotify.com/album/3GETv5yNXeM0cnhq8XahWu", album.getHttpURL());
        assertNull(album.getName());
        assertNull(album.getCover());
        assertEquals("792d90d6e5c14679afd00e7ea28982ce", album.getHexUUID());
        assertNull(album.getPopularity());

        assertNull(album.getTracks());
        assertNull(album.getArtist());
      }
    });




    // end generated tests
  }


}
