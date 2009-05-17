package se.despotify.client.protocol.command.media.playlist;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import se.despotify.client.protocol.PacketType;
import se.despotify.client.protocol.Protocol;
import se.despotify.client.protocol.channel.Channel;
import se.despotify.client.protocol.channel.ChannelCallback;
import se.despotify.client.protocol.command.Command;
import se.despotify.domain.Store;
import se.despotify.domain.User;
import se.despotify.domain.media.PlaylistContainer;
import se.despotify.exceptions.DespotifyException;
import se.despotify.util.Hex;
import se.despotify.util.XML;
import se.despotify.util.XMLElement;

import java.nio.ByteBuffer;
import java.nio.charset.Charset;

/**
 * shn_encrypt(ctx=0x852490, buf=0xbfffde50, len=35 [0x0023]) called from 0x000abc35
 *  input (plaintext):
 *	3500200007000000 0000000000000000 0000000000000000 000e00000004970b [5? ?????????????????????????????]
 *	1c7f00                                                              [???]
 */
public class LoadUserPlaylists extends Command<Boolean> {

  private static Logger log = LoggerFactory.getLogger(LoadUserPlaylists.class);

  private Store store;
  private User user;

  public LoadUserPlaylists(Store store, User user) {
    this.store = store;
    this.user = user;
  }

  @Override
  public Boolean send(Protocol protocol) throws DespotifyException {

    ChannelCallback callback = new ChannelCallback();

    Channel channel = new Channel("Playlist-Channel", Channel.Type.TYPE_PLAYLIST, callback);
    ByteBuffer buffer  = ByteBuffer.allocate(2 + 16 + 1 + 4 + 4 + 4 + 1);

    buffer.putShort((short)channel.getId()); // channel id
    buffer.put(Hex.toBytes("00000000000000000000000000000000")); // uuid? not used
    buffer.put((byte)0x00); // unknown
    buffer.putInt(-1); // playlist history. -1: current. 0: changes since version 0, 1: since version 1, etc. 
    buffer.putInt(0);  // unknown
    buffer.putInt(-1); // unknown
    buffer.put((byte)0x00); // 00 = get playlist ids, 01 = do not get playlist ids?
    buffer.flip();

    Channel.register(channel);
    protocol.sendPacket(PacketType.getPlaylist, buffer, "request list of user playlists");
    byte[] data = callback.getData("user playlists response");

    if (data.length == 0) {
      throw new DespotifyException("received an empty response!");
    }

    String xml =
      "<?xml version=\"1.0\" encoding=\"utf-8\" ?><playlist>" +
      new String(data, Charset.forName("UTF-8")) +
      "</playlist>";

    if (log.isDebugEnabled()) {
      log.debug(xml);
    }

    XMLElement playlistElement = XML.load(xml);

    if (user.getPlaylists() == null) {
      user.setPlaylists(new PlaylistContainer());
    }
    PlaylistContainer.fromXMLElement(playlistElement, store, user.getPlaylists());

    if (playlistElement.hasChild("next-change")) {
      return true;
    } else {
      throw new RuntimeException("Unknown server response:\n" + xml);
    }


  }
}
