package se.despotify.client.protocol.command.media.playlist;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import se.despotify.client.protocol.Protocol;
import se.despotify.client.protocol.command.Command;
import se.despotify.domain.Store;
import se.despotify.domain.User;
import se.despotify.exceptions.DespotifyException;
import se.despotify.util.Hex;

import java.util.Random;

/**
 *
 * @since 2009-apr-24 06:23:30
 */
public class ReserveRandomPlaylistUUID extends Command<byte[]> {

  private static Logger log = LoggerFactory.getLogger(ReserveRandomPlaylistUUID.class);

  private Store store;
  private User user;
  private String playlistName;
  private boolean collaborative;

  public ReserveRandomPlaylistUUID(Store store, User user, String playlistName, boolean collaborative) {
    this.store = store;
    this.user = user;
    this.playlistName = playlistName;
    this.collaborative = collaborative;

  }

  @Override
  /**
   * @return uuid
   */
  public byte[] send(Protocol protocol) throws DespotifyException {
    int counter = 0; // avoid eternal looping

    while (true) {
      if (counter++ == 10) {
        throw new RuntimeException("Eternal loop?!");
      }

      // create new random id
      byte[] UUID = new byte[16];
      new Random().nextBytes(UUID);
      String hexId = Hex.toHex(UUID);

      log.info("requesting uuid " + hexId);

      if (new ReservePlaylistUUID(store, user, UUID, playlistName, collaborative).send(protocol)) {
        return UUID;
      }

    }
  }

}