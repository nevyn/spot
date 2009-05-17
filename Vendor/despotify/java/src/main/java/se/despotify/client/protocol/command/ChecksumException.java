package se.despotify.client.protocol.command;

import se.despotify.exceptions.DespotifyException;

/**
 * @since 2009-apr-25 16:00:56
 */
public class ChecksumException extends DespotifyException {

  public ChecksumException(String message) {
    super(message);
  }

  public ChecksumException(long received, long calculated) {
    super("received " + received + " but calculated " + calculated);
  }
   
}
