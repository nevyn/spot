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
import se.despotify.exceptions.DespotifyException;
import se.despotify.util.Hex;
import se.despotify.util.XML;
import se.despotify.util.XMLElement;

import java.nio.ByteBuffer;
import java.nio.charset.Charset;
import java.util.Date;

/**
 *
 * 	3600cd0000566796 2d4c1764d12cd68b 86a4394916020000 000000000000ffff [6????Vg?-L?d?,????9I????????????]
 *	ffff01033c69642d 69732d756e697175 652f3e3c6368616e 67653e3c6f70733e [????<id-is-unique/><change><ops>]
 *	3c6372656174652f 3e3c6e616d653e6a 6f74696679313c2f 6e616d653e3c2f6f [<create/><name>jotify1</name></o]
 *	70733e3c74696d65 3e31323430353335 3031373c2f74696d 653e3c757365723e [ps><time>1240535017</time><user>]
 *	6b656e742e66696e 656c6c3c2f757365 723e3c2f6368616e 67653e3c76657273 [kent.finell</user></change><vers]
 *	696f6e3e30303030 3030303030312c30 3030303030303030 302c303030303030 [ion>0000000001,0000000000,000000]
 *	303030312c303c2f 76657273696f6e3e                                   [0001,0</version>]
 *readv(fd=5, iovec=0xb0122e18 {iov_base=0x81321c, iov_len=3000}, iovcnt=15) called from 0x000cc80f (thread 0xb0123000)
 *shn_decrypt(ctx=0x9217c0, buf=0xb0122e8c, len=3 [0x0003]) called from 0x000adef4
 *  output (plaintext):		090004                                                              [???]
 *shn_decrypt(ctx=0x9217c0, buf=0x81321f, len=4 [0x0004]) called from 0x000adf64
 *  output (plaintext):		00000000                                                            [????]
 *shn_decrypt(ctx=0x9217c0, buf=0xb0122e8c, len=3 [0x0003]) called from 0x000adef4
 *  output (plaintext):		09005a                                                              [??Z]
 *shn_decrypt(ctx=0x9217c0, buf=0x81322a, len=90 [0x005a]) called from 0x000adf64
 *  output (plaintext):
 *	00003c636f6e6669 726d3e3c7269643e 33353236393c2f72 69643e3c76657273 [??<confirm><rid>35269</rid><vers]
 *	696f6e3e30303030 3030303030312c30 3030303030303030 302c303030303030 [ion>0000000001,0000000000,000000]
 *	303030312c303c2f 76657273696f6e3e 3c2f636f6e666972 6d3e             [0001,0</version></confirm>]
 *
 */
public class ReservePlaylistUUID extends Command<Boolean> {

  private static Logger log = LoggerFactory.getLogger(ReservePlaylistUUID.class);

  private Store store;
  private User user;
  private byte[] requestedPlaylistUUID;
  private String playlistName;
  private boolean collaborative;

  public ReservePlaylistUUID(Store store, User user, byte[] requestedPlaylistUUID, String playlistName, boolean collaborative) {
    this.store = store;
    this.user = user;
    this.requestedPlaylistUUID = requestedPlaylistUUID;
    this.playlistName = playlistName;
    this.collaborative = collaborative;

  }

  @Override
  /**
   * @return uuid
   */
  public Boolean send(Protocol protocol) throws DespotifyException {

    if (user.getPlaylists() == null) {
      log.warn("user playlists not loaded yet! should it be? loading..");
      new LoadUserPlaylists(store, user).send(protocol);
    }
    

    String xml = String.format(
        "<id-is-unique/><change><ops><create/><name>%s</name></ops><time>%d</time><user>%s</user></change>" +
            "<version>0000000001,0000000000,0000000001,%s</version>",
        playlistName,
        new Date().getTime() / 1000,
        protocol.getSession().getUsername(),
        collaborative ? 1 : 0
    );

    /* Create channel callback */
    ChannelCallback callback = new ChannelCallback();


    /* Create channel and buffer. */
    Channel channel = new Channel("Create-Playlist-Channel", Channel.Type.TYPE_PLAYLIST, callback);
    byte[] xmlBytes = xml.getBytes();
    ByteBuffer buffer = ByteBuffer.allocate(2 + 17 + 4 + 4 + 4 + 1 + 1 + xmlBytes.length);

    /* Append channel id, playlist id and some bytes... */
    buffer.putShort((short) channel.getId());
    buffer.put(requestedPlaylistUUID);
    buffer.put((byte) 0x02); // uuid playlist marker?
    buffer.putInt(0); // playlist revision?
    buffer.putInt(0); // playlist tracks size?
    buffer.putInt(-1); // playlist checksum? -1 when create uuid
    buffer.put((byte) 0x01); // normally means collaborate, not sure whats with this here
    buffer.put((byte) 0x03); // unknown
    buffer.put(xmlBytes);
    buffer.flip();

    /* Register channel. */
    Channel.register(channel);

    /* Send packet. */
    protocol.sendPacket(PacketType.changePlaylist, buffer, "create playlist UUID");

    /* Get response. */
    byte[] data = callback.getData("create playlist uuid reponse");

    xml = "<?xml version=\"1.0\" encoding=\"utf-8\" ?>\n<playlist>\n" +
        new String(data, Charset.forName("UTF-8")) +
        "\n</playlist>";

    if (log.isDebugEnabled()) {
      log.debug(xml);
    }

    XMLElement reponseElement = XML.load(xml);

    if (reponseElement.hasChild("confirm")) {
      return true;
    } else {
      log.warn("Invalid response when requesting UUID " + Hex.toHex(requestedPlaylistUUID) + ":\n" + xml);
      return false;
    }

  }


}