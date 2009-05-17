package se.despotify.domain.media;

/**
 * @since 2009-apr-25 15:52:17
 */
public class MediaTestCaseGenerator {

  public static void createEqualsTest(final Media media) throws Exception {
    createEqualsTest(media, "SpotifyURL.browse(\"" + media.getSpotifyURL() + "\", connection)");
  }

  public static void createEqualsTest(final Media media, final String objectName) throws Exception {
    media.accept(new VisitorAdapter() {
      @Override
      public void visit(Album album) {
        System.out.println("    "+objectName+".accept(new VisitorAdapter() {");
        System.out.println("      @Override");
        System.out.println("      public void visit(Album album) {");

        printAlbum(album, "album");

        System.out.println("");
        if (album.getTracks() == null) {
          System.out.println("        assertNull(album.getTracks());");
        } else {
          System.out.println("        assertEquals(" + album.getTracks().size() + ", album.getTracks().size());");
          System.out.println("        Track track;");

          for (int i = 0; i < album.getTracks().size(); i++) {
            System.out.println("");
            System.out.println("        track = album.getTracks().get(" + i + ");");
            printTrack(album.getTracks().get(i), "track");
            System.out.println("        assertTrue(track.getAlbum() == album);");

          }

          System.out.println("");

        }

        if (album.getArtist() == null) {
          System.out.println("        assertNull(album.getArtist());");
        } else {
          printArtist(album.getArtist(), "album.getArtist()");
        }

        System.out.println("      }");
        System.out.println("    });");

      }

      @Override
      public void visit(Artist artist) {
        System.out.println("    "+objectName+".accept(new VisitorAdapter() {");
        System.out.println("      @Override");
        System.out.println("      public void visit(Artist artist) {");

        printArtist(artist, "artist");

        System.out.println("      }");
        System.out.println("    });");

      }

      @Override
      public void visit(Playlist playlist) {
        System.out.println("");

/*
    Playlist playlist = (Playlist)SpotifyURL.browse("spotify:user:kent.finell:playlist:6wvPFkLGKOVl1v3qRJD6HX", connection);


*/
        System.out.println("    "+objectName+".accept(new VisitorAdapter() {");
        System.out.println("      @Override");
        System.out.println("      public void visit(Playlist playlist) {");
        System.out.println("        assertEquals(\"" + playlist.getName() + "\", playlist.getName());");
        System.out.println("        assertEquals(" + playlist.getRevision() + "l, playlist.getRevision().longValue());");
        System.out.println("        assertEquals(" + playlist.getChecksum() + "l,playlist.getChecksum().longValue());");
        System.out.println("        assertEquals(" + playlist.calculateChecksum() + "l, playlist.calculateChecksum());");
        System.out.println("        assertEquals(\"" + playlist.getAuthor() + "\", playlist.getAuthor());");
        System.out.println("        assert" + (playlist.isCollaborative() ? "True" : "False") + "(playlist.isCollaborative());");
        System.out.println("        assertEquals(\"" + playlist.getHexUUID() + "\", playlist.getHexUUID());");
        System.out.println("        assertEquals(" + playlist.getTracks().size() + ", playlist.getTracks().size());");
        System.out.println("        ");
        for (int i = 0; i < playlist.getTracks().size(); i++) {
          printTrack(playlist.getTracks().get(i), "playlist.getTracks().get(" + i + ")");
          System.out.println("        ");
        }

        System.out.println("        ");
        System.out.println("      }");
        System.out.println("    });");

      }

      @Override
      public void visit(Track track) {
        System.out.println("    "+objectName+".accept(new VisitorAdapter() {");
        System.out.println("      @Override");
        System.out.println("      public void visit(Track track) {");
        System.out.println("");

        printTrack(track, "track");

        System.out.println("");

        if (track.getArtist() == null) {
          System.out.println("        assertNull(track.getArtist());");
        } else {
          printArtist(track.getArtist(), "track.getArtist()");
        }

        System.out.println("");
        if (track.getAlbum() == null) {
          System.out.println("        assertNull(track.getAlbum());");
        } else {
          printAlbum(track.getAlbum(), "track.getAlbum()");
        }
        System.out.println("      }");
        System.out.println("    });");
      }
    });


  }

  public static void printAlbum(Album album, String prefix) {
    System.out.println("        assertEquals(\"" + album.getSpotifyURL() + "\", " + prefix + ".getSpotifyURL());");
    System.out.println("        assertEquals(\"" + album.getHttpURL() + "\", " + prefix + ".getHttpURL());");

    if (album.getName() == null) {
      System.out.println("        assertNull(" + prefix + ".getName());");
    } else {
      System.out.println("        assertEquals(\"" + album.getName() + "\", " + prefix + ".getName());");
    }

    if (album.getCover() == null) {
      System.out.println("        assertNull(" + prefix + ".getCover());");
    } else {
      System.out.println("        assertEquals(\"" + album.getCover() + "\", " + prefix + ".getCover());");
    }
    System.out.println("        assertEquals(\"" + album.getHexUUID() + "\", " + prefix + ".getHexUUID());");

    if (album.getPopularity() != null) {
      System.out.println("        assertEquals(" + album.getPopularity() + "f, track.getPopularity());");
    } else {
      System.out.println("        assertNull("+prefix+".getPopularity());");
    }
  }

  public static void printArtist(Artist artist, String prefix) {
    System.out.println("        assertEquals(\"" + artist.getHexUUID() + "\", " + prefix + ".getHexUUID());");
    System.out.println("        assertEquals(\"" + artist.getSpotifyURL() + "\", " + prefix + ".getSpotifyURL());");
    System.out.println("        assertEquals(\"" + artist.getHttpURL() + "\", " + prefix + ".getHttpURL());");

    System.out.println("        assertEquals(\"" + artist.getName() + "\", " + prefix + ".getName());");

    if (artist.getPopularity() == null) {
      System.out.println("        assertNull(" + prefix + ".getPopularity());");
    } else {
      System.out.println("        assertTrue(" + prefix + ".getPopularity() > 0f);");
    }

    if (artist.getPortrait() == null) {
      System.out.println("        assertNull(" + prefix + ".getPortrait());");
    } else {
      System.out.println("        assertEquals(\"" + artist.getPortrait() + "\", " + prefix + ".getPortrait());");
    }
    System.out.println("        // TODO: " + prefix + ".getSimilarArtists();");
  }

  public static void printTrack(Track track, String prefix) {
    System.out.println("        assertEquals(\"" + track.getHexUUID() + "\", " + prefix + ".getHexUUID());");
    System.out.println("        assertEquals(\"" + track.getSpotifyURL() + "\", " + prefix + ".getSpotifyURL());");
    System.out.println("        assertEquals(\"" + track.getHttpURL() + "\", " + prefix + ".getHttpURL());");

    if (track.getTitle() != null) {
      System.out.println("        assertEquals(\"" + track.getTitle() + "\", " + prefix + ".getTitle());");
    } else {
      System.out.println("        assertNull(" + prefix + ".getTitle());");

    }

    if (track.getCover() == null) {
      System.out.println("        assertNull(" + prefix + ".getCover());");
    } else {
      System.out.println("        assertEquals(\"" + track.getCover() + "\", " + prefix + ".getCover());");
    }
    if (track.getFiles() == null) {
      System.out.println("        assertNull("+prefix+".getFiles());");
    } else {
      System.out.println("        assertEquals(" + track.getFiles().size() + ", " + prefix + ".getFiles().size());");
      for (int i = 0; i < track.getFiles().size(); i++) {
        System.out.println("        assertEquals(\"" + track.getFiles().get(i) + "\", " + prefix + ".getFiles().get(" + i + "));");
      }
    }
    if (track.getLength() != null) {
      System.out.println("        assertEquals(" + track.getLength() + "l, " + prefix + ".getLength().longValue());");
    } else {
      System.out.println("        assertNull("+prefix+".getLength());");
    }

    if (track.getPopularity() != null) {
      System.out.println("        assertTrue(track.getPopularity() > 0f);");
    } else {
      System.out.println("        assertNull("+prefix+".getPopularity());");
    }

    if (track.getTrackNumber() != null) {
      System.out.println("        assertEquals(" + track.getTrackNumber() + ", " + prefix + ".getTrackNumber().intValue());");
    } else {
      System.out.println("        assertNull("+prefix+".getTrackNumber());");
    }

    if (track.getYear() == null) {
      System.out.println("        assertNull(" + prefix + ".getYear());");
    } else {
      System.out.println("        assertEquals(" + track.getYear() + ", " + prefix + ".getYear().intValue());");
    }
  }

}
