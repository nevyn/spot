package se.despotify.client.protocol.command;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import se.despotify.client.protocol.Protocol;
import se.despotify.exceptions.DespotifyException;

/**
 *
 * @since 2009-apr-24 02:47:36
 */
public abstract class Command<T> {

  private static Logger log = LoggerFactory.getLogger(Command.class);


  public abstract T send(Protocol protocol) throws DespotifyException;

}
