package se.despotify.util;

import se.despotify.Connection;
import se.despotify.client.protocol.command.media.LoadAlbum;
import se.despotify.client.protocol.command.media.LoadArtist;
import se.despotify.client.protocol.command.media.LoadTracks;
import se.despotify.client.protocol.command.media.playlist.LoadPlaylist;
import se.despotify.domain.Store;
import se.despotify.domain.media.*;
import se.despotify.exceptions.DespotifyException;

import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 */
public class SpotifyURL {


  public static final Pattern pattern = Pattern.compile("((http://open\\.spotify\\.com/)|(spotify:))(track|album|artist|(user[:/]+([^:/]+)[:/]playlist))[:/]+([A-Za-z0-9]+)");

  public static enum URLtype {
    spotifyURL, httpURL
  }

  public static interface Visitor<T> {
    public T track(URLtype type, String URI);
    public T album(URLtype type, String URI);
    public T artist(URLtype type, String URI);
    public T playlist(URLtype type, String user, String URI);
  }

  /**
   * Lexical macthing for Spotify URL parts.
   *
   * @param URL URL to be matched.
   * @param matcher Visitor to be triggered by this matching.
   * @param <T> Visitor return type.
   * @return Value as retuned by the executed matcher.
   */
  public static <T> T match(String URL, Visitor<T> matcher) {
    Matcher patternMatcher = pattern.matcher(URL);
    if (!patternMatcher.matches()) {
      throw new IllegalArgumentException("Not a valid URL: " + URL);
    }

    URLtype urlType = patternMatcher.group(2) != null ? URLtype.httpURL : URLtype.spotifyURL;

    if (patternMatcher.group(5) != null) {
      return matcher.playlist(urlType, patternMatcher.group(6), patternMatcher.group(7));
    } else if ("track".equals(patternMatcher.group(4))) {
      return matcher.track(urlType, patternMatcher.group(7));
    } else if ("album".equals(patternMatcher.group(4))) {
      return matcher.album(urlType, patternMatcher.group(7));
    } else if ("artist".equals(patternMatcher.group(4))) {
      return matcher.artist(urlType, patternMatcher.group(7));
    } else {
      throw new RuntimeException();
    }
    
  }

  /**
   * Browse a single instance of a domain object as represented by a Spotify URL.
   *
   * Use a {@link se.despotify.domain.media.Visitor visitor} on the {@link Visitable visitable} response rather than instanceof.
   *  
   * @param URL A spotify URL, "http://open.spotify.com/..." or "spotify:...".
   * @param connection service instance used to query for data.
   * @return  A visitable domain object representing parameter URL.
   */
  public static Visitable browse(String URL, final Store store, final Connection connection) {
    return match(URL, new Visitor<Visitable>(){
      public Visitable track(URLtype type, String URI) {
        Track track = store.getTrack(SpotifyURI.toHex(URI));
        try {
          new LoadTracks(store, track).send(connection.getProtocol());
        } catch (DespotifyException e) {
          throw new RuntimeException(e);
        }
        return track;
      }

      public Visitable album(URLtype type, String URI) {
        Album album = store.getAlbum(SpotifyURI.toHex(URI));
        try {
          new LoadAlbum(store, album).send(connection.getProtocol());
        } catch (DespotifyException e) {
          throw new RuntimeException(e);
        }
        return album;
      }

      public Visitable artist(URLtype type, String URI) {
        Artist artist = store.getArtist(SpotifyURI.toHex(URI));
        try {
          new LoadArtist(store, artist).send(connection.getProtocol());
        } catch (DespotifyException e) {
          throw new RuntimeException(e);
        }
        return artist;
      }

      public Visitable playlist(URLtype type, String user, String URI) {
        Playlist playlist = store.getPlaylist(SpotifyURI.toHex(URI));
        try {
          new LoadPlaylist(store, playlist).send(connection.getProtocol());
        } catch (DespotifyException e) {
          throw new RuntimeException(e);
        }
        return playlist;

      }
    });
  }


  /**
   * Transforms a spotify URL to a http URL and vice verse.
   *
   * SpotifyURL.match(URL, new URLtransformer());
   */
  public static class URLtransformer implements Visitor<String> {

    public String track(URLtype type, String URI) {
      return type == URLtype.spotifyURL ? "http://open.spotify.com/track/" + URI : "spotify:track:" + URI;
    }

    public String album(URLtype type, String URI) {
      return type == URLtype.spotifyURL ? "http://open.spotify.com/album/" + URI : "spotify:album:" + URI;
    }

    public String artist(URLtype type, String URI) {
      return type == URLtype.spotifyURL ? "http://open.spotify.com/artist/" + URI : "spotify:artist:" + URI;
    }

    public String playlist(URLtype type, String user, String URI) {
      return type == URLtype.spotifyURL ? "http://open.spotify.com/user/" + user + "/playlist/" + URI : "spotify:user:" + user + ":playlist:" + URI;
    }
  }

}
