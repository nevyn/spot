package se.despotify.client.protocol.command.media.playlist;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import se.despotify.client.protocol.PacketType;
import se.despotify.client.protocol.Protocol;
import se.despotify.client.protocol.channel.Channel;
import se.despotify.client.protocol.channel.ChannelCallback;
import se.despotify.client.protocol.command.ChecksumException;
import se.despotify.client.protocol.command.Command;
import se.despotify.domain.Store;
import se.despotify.domain.media.Playlist;
import se.despotify.exceptions.DespotifyException;
import se.despotify.util.XML;
import se.despotify.util.XMLElement;

import java.nio.ByteBuffer;
import java.nio.charset.Charset;

/**
 * input (plaintext):
 * 3500200000d34719 ba2533a497c77647 79108572c8020000 0007000000013ca1 [5? ???G??%3???vGy??r??????????<?]
 * 062401                                                              [?$?]
 * shn_encrypt(ctx=0x8ef490, buf=0xbfffdd60, len=35 [0x0023]) called from 0x000abc35
 * input (plaintext):
 * 3500200001000000 000000000000002a 6080835044020000 0005000000022108 [5? ????????????*`??PD?????????!?]
 * 0f7400                                                              [?t?]
 * shn_encrypt(ctx=0x8ef490, buf=0xbfffdd60, len=35 [0x0023]) called from 0x000abc35
 * input (plaintext):
 * 3500200002f9d56f b062619c842289a4 0520f41770020000 003c000000303438 [5? ????o?ba??"??? ??p????<???048]
 * 727d01                                                              [r}?]
 */
public class LoadPlaylist extends Command<Boolean> {

  private static Logger log = LoggerFactory.getLogger(LoadPlaylist.class);

  private Store store;
  private Playlist playlist;

  public LoadPlaylist(Store store, Playlist playlist) {
    this.store = store;
    this.playlist = playlist;
  }

  @Override
  public Boolean send(Protocol protocol) throws DespotifyException {
    byte[] data;


    /* Create channel callback */
    ChannelCallback callback = new ChannelCallback();

    /* Create channel and buffer. */
    Channel channel = new Channel("Playlist-Channel", Channel.Type.TYPE_PLAYLIST, callback);
    ByteBuffer buffer = ByteBuffer.allocate(2 + 16 + 1 + 4 + 4 + 4 + 1);

    /* Append channel id, playlist id and some bytes... */
    buffer.putShort((short) channel.getId());
    buffer.put(playlist.getUUID()); /// playlist UUID
    buffer.put((byte) 0x02); // playlist UUID type

    // todo if getTracks() == null..
    buffer.putInt(-1); // playlist history. -1: current. 0: changes since version 0, 1: since version 1, etc.

    buffer.putInt(0); // unknown
    buffer.putInt(-1); // checksum?
    buffer.put((byte) 0x01);
    buffer.flip();
    /* Register channel. */
    Channel.register(channel);

    /* Send packet. */
    protocol.sendPacket(PacketType.getPlaylist, buffer, "get playlist");

    /* Get data and inflate it. */
    data = callback.getData("get playlist response");

    if (data.length == 0) {
      throw new DespotifyException("Received an empty response");
    }

    /* Load XML. */
    String xml = "<?xml version=\"1.0\" encoding=\"utf-8\" ?><playlist>" +
        new String(data, Charset.forName("UTF-8")) +
        "</playlist>";
    XMLElement playlistElement = XML.load(xml);
    if (log.isDebugEnabled()) {
      log.debug(xml);
    }
    /* Create and return playlist. */
    Playlist.fromXMLElement(playlistElement, store, playlist);

    if (playlist.getTracks() != null && playlist.getChecksum() != playlist.calculateChecksum()) {
      throw new ChecksumException(playlist.getChecksum(), playlist.calculateChecksum());
    }

    return true;


  }
}
