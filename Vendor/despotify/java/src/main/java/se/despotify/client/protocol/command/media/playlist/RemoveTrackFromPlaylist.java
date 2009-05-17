package se.despotify.client.protocol.command.media.playlist;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import se.despotify.client.protocol.PacketType;
import se.despotify.client.protocol.Protocol;
import se.despotify.client.protocol.channel.Channel;
import se.despotify.client.protocol.channel.ChannelCallback;
import se.despotify.client.protocol.command.Command;
import se.despotify.client.protocol.command.ChecksumException;
import se.despotify.domain.Store;
import se.despotify.domain.User;
import se.despotify.domain.media.Playlist;
import se.despotify.domain.media.Track;
import se.despotify.exceptions.DespotifyException;
import se.despotify.util.XML;
import se.despotify.util.XMLElement;

import java.nio.ByteBuffer;
import java.nio.charset.Charset;
import java.util.Date;
import java.util.ArrayList;

/**
 * @since 2009-apr-26 23:16:55
 */
public class RemoveTrackFromPlaylist extends Command<Track> {

  private static Logger log = LoggerFactory.getLogger(RemoveTrackFromPlaylist.class);


  private Store store;
  private User user;
  private Playlist playlist;
  private int position;

  public RemoveTrackFromPlaylist(Store store, User user, Playlist playlist, int position) {
    this.store = store;
    this.user = user;
    this.playlist = playlist;
    this.position = position;
  }

  /*

   remove track 5,4,3,2,1 (and then empty) from playlist

shn_encrypt(ctx=0x852490, buf=0xbfffddc0, len=191 [0x00bf]) called from 0x000abc35
  input (plaintext):
	3600bc0000c6de2f ac7f3db84e57dd94 746b750bee020000 000200000005e22c [6??????/??=?NW??tku????????????,]
	27f200033c636861 6e67653e3c6f7073 3e3c64656c3e3c69 3e343c2f693e3c6b ['???<change><ops><del><i>4</i><k]
	3e313c2f6b3e3c2f 64656c3e3c2f6f70 733e3c74696d653e 3132343038353232 [>1</k></del></ops><time>12408522]
	37313c2f74696d65 3e3c757365723e6b 656e742e66696e65 6c6c3c2f75736572 [71</time><user>kent.finell</user]
	3e3c2f6368616e67 653e3c7665727369 6f6e3e3030303030 30303030332c3030 [></change><version>0000000003,00]
	3030303030303034 2c31393034343834 3330362c303c2f76 657273696f6e3e   [00000004,1904484306,0</version>]
readv(fd=5, iovec=0xb0122e18 {iov_base=0x81321c, iov_len=3000}, iovcnt=15) called from 0x000cc80f (thread 0xb0123000)
shn_decrypt(ctx=0x8523c0, buf=0xb0122e8c, len=3 [0x0003]) called from 0x000adef4
  output (plaintext):		090004                                                              [???]
shn_decrypt(ctx=0x8523c0, buf=0x81321f, len=4 [0x0004]) called from 0x000adf64
  output (plaintext):		00000000                                                            [????]
shn_decrypt(ctx=0x8523c0, buf=0xb0122e8c, len=3 [0x0003]) called from 0x000adef4
  output (plaintext):		090059                                                              [??Y]
shn_decrypt(ctx=0x8523c0, buf=0x81322a, len=89 [0x0059]) called from 0x000adf64
  output (plaintext):
	00003c636f6e6669 726d3e3c7269643e 383930323c2f7269 643e3c7665727369 [??<confirm><rid>8902</rid><versi]
	6f6e3e3030303030 30303030332c3030 3030303030303034 2c31393034343834 [on>0000000003,0000000004,1904484]
	3330362c303c2f76 657273696f6e3e3c 2f636f6e6669726d 3e               [306,0</version></confirm>]
shn_decrypt(ctx=0x8523c0, buf=0xb0122e8c, len=3 [0x0003]) called from 0x000adef4
  output (plaintext):		090002                                                              [???]
shn_decrypt(ctx=0x8523c0, buf=0x81328a, len=2 [0x0002]) called from 0x000adf64
  output (plaintext):		0000                                                                [??]
17:11:12.325 I [playlist] playlist ACK
shn_encrypt(ctx=0x852490, buf=0xbfffddc0, len=191 [0x00bf]) called from 0x000abc35
  input (plaintext):
	3600bc0000c6de2f ac7f3db84e57dd94 746b750bee020000 0003000000047184 [6??????/??=?NW??tku???????????q?]
	1fd200033c636861 6e67653e3c6f7073 3e3c64656c3e3c69 3e333c2f693e3c6b [????<change><ops><del><i>3</i><k]
	3e313c2f6b3e3c2f 64656c3e3c2f6f70 733e3c74696d653e 3132343038353232 [>1</k></del></ops><time>12408522]
	37323c2f74696d65 3e3c757365723e6b 656e742e66696e65 6c6c3c2f75736572 [72</time><user>kent.finell</user]
	3e3c2f6368616e67 653e3c7665727369 6f6e3e3030303030 30303030342c3030 [></change><version>0000000004,00]
	3030303030303033 2c32333339363431 3334392c303c2f76 657273696f6e3e   [00000003,2339641349,0</version>]
readv(fd=5, iovec=0xb0122e18 {iov_base=0x8c821c, iov_len=3000}, iovcnt=15) called from 0x000cc80f (thread 0xb0123000)
shn_decrypt(ctx=0x8523c0, buf=0xb0122e8c, len=3 [0x0003]) called from 0x000adef4
  output (plaintext):		090004                                                              [???]
shn_decrypt(ctx=0x8523c0, buf=0x8c821f, len=4 [0x0004]) called from 0x000adf64
  output (plaintext):		00000000                                                            [????]
shn_decrypt(ctx=0x8523c0, buf=0xb0122e8c, len=3 [0x0003]) called from 0x000adef4
  output (plaintext):		090059                                                              [??Y]
shn_decrypt(ctx=0x8523c0, buf=0x8c822a, len=89 [0x0059]) called from 0x000adf64
  output (plaintext):
	00003c636f6e6669 726d3e3c7269643e 383930333c2f7269 643e3c7665727369 [??<confirm><rid>8903</rid><versi]
	6f6e3e3030303030 30303030342c3030 3030303030303033 2c32333339363431 [on>0000000004,0000000003,2339641]
	3334392c303c2f76 657273696f6e3e3c 2f636f6e6669726d 3e               [349,0</version></confirm>]
shn_decrypt(ctx=0x8523c0, buf=0xb0122e8c, len=3 [0x0003]) called from 0x000adef4
  output (plaintext):		090002                                                              [???]
shn_decrypt(ctx=0x8523c0, buf=0x8c828a, len=2 [0x0002]) called from 0x000adf64
  output (plaintext):		0000                                                                [??]
17:11:13.078 I [playlist] playlist ACK
shn_encrypt(ctx=0x852490, buf=0xbfffddc0, len=191 [0x00bf]) called from 0x000abc35
  input (plaintext):
	3600bc0000c6de2f ac7f3db84e57dd94 746b750bee020000 0004000000038b74 [6??????/??=?NW??tku????????????t]
	180500033c636861 6e67653e3c6f7073 3e3c64656c3e3c69 3e323c2f693e3c6b [????<change><ops><del><i>2</i><k]
	3e313c2f6b3e3c2f 64656c3e3c2f6f70 733e3c74696d653e 3132343038353232 [>1</k></del></ops><time>12408522]
	37323c2f74696d65 3e3c757365723e6b 656e742e66696e65 6c6c3c2f75736572 [72</time><user>kent.finell</user]
	3e3c2f6368616e67 653e3c7665727369 6f6e3e3030303030 30303030352c3030 [></change><version>0000000005,00]
	3030303030303032 2c30383233323637 3331362c303c2f76 657273696f6e3e   [00000002,0823267316,0</version>]
readv(fd=5, iovec=0xb0122e18 {iov_base=0x81321c, iov_len=3000}, iovcnt=15) called from 0x000cc80f (thread 0xb0123000)
shn_decrypt(ctx=0x8523c0, buf=0xb0122e8c, len=3 [0x0003]) called from 0x000adef4
  output (plaintext):		090004                                                              [???]
shn_decrypt(ctx=0x8523c0, buf=0x81321f, len=4 [0x0004]) called from 0x000adf64
  output (plaintext):		00000000                                                            [????]
shn_decrypt(ctx=0x8523c0, buf=0xb0122e8c, len=3 [0x0003]) called from 0x000adef4
  output (plaintext):		090059                                                              [??Y]
shn_decrypt(ctx=0x8523c0, buf=0x81322a, len=89 [0x0059]) called from 0x000adf64
  output (plaintext):
	00003c636f6e6669 726d3e3c7269643e 383930343c2f7269 643e3c7665727369 [??<confirm><rid>8904</rid><versi]
	6f6e3e3030303030 30303030352c3030 3030303030303032 2c30383233323637 [on>0000000005,0000000002,0823267]
	3331362c303c2f76 657273696f6e3e3c 2f636f6e6669726d 3e               [316,0</version></confirm>]
shn_decrypt(ctx=0x8523c0, buf=0xb0122e8c, len=3 [0x0003]) called from 0x000adef4
  output (plaintext):		090002                                                              [???]
shn_decrypt(ctx=0x8523c0, buf=0x81328a, len=2 [0x0002]) called from 0x000adf64
  output (plaintext):		0000                                                                [??]
17:11:13.624 I [playlist] playlist ACK
shn_encrypt(ctx=0x852490, buf=0xbfffddc0, len=191 [0x00bf]) called from 0x000abc35
  input (plaintext):
	3600bc0000c6de2f ac7f3db84e57dd94 746b750bee020000 0005000000023112 [6??????/??=?NW??tku???????????1?]
	0ff400033c636861 6e67653e3c6f7073 3e3c64656c3e3c69 3e313c2f693e3c6b [????<change><ops><del><i>1</i><k]
	3e313c2f6b3e3c2f 64656c3e3c2f6f70 733e3c74696d653e 3132343038353232 [>1</k></del></ops><time>12408522]
	37333c2f74696d65 3e3c757365723e6b 656e742e66696e65 6c6c3c2f75736572 [73</time><user>kent.finell</user]
	3e3c2f6368616e67 653e3c7665727369 6f6e3e3030303030 30303030362c3030 [></change><version>0000000006,00]
	3030303030303031 2c31343631393133 3836342c303c2f76 657273696f6e3e   [00000001,1461913864,0</version>]
readv(fd=5, iovec=0xb0122e18 {iov_base=0x8c821c, iov_len=3000}, iovcnt=15) called from 0x000cc80f (thread 0xb0123000)
shn_decrypt(ctx=0x8523c0, buf=0xb0122e8c, len=3 [0x0003]) called from 0x000adef4
  output (plaintext):		090004                                                              [???]
shn_decrypt(ctx=0x8523c0, buf=0x8c821f, len=4 [0x0004]) called from 0x000adf64
  output (plaintext):		00000000                                                            [????]
shn_decrypt(ctx=0x8523c0, buf=0xb0122e8c, len=3 [0x0003]) called from 0x000adef4
  output (plaintext):		090059                                                              [??Y]
shn_decrypt(ctx=0x8523c0, buf=0x8c822a, len=89 [0x0059]) called from 0x000adf64
  output (plaintext):
	00003c636f6e6669 726d3e3c7269643e 383930353c2f7269 643e3c7665727369 [??<confirm><rid>8905</rid><versi]
	6f6e3e3030303030 30303030362c3030 3030303030303031 2c31343631393133 [on>0000000006,0000000001,1461913]
	3836342c303c2f76 657273696f6e3e3c 2f636f6e6669726d 3e               [864,0</version></confirm>]
shn_decrypt(ctx=0x8523c0, buf=0xb0122e8c, len=3 [0x0003]) called from 0x000adef4
  output (plaintext):		090002                                                              [???]
shn_decrypt(ctx=0x8523c0, buf=0x8c828a, len=2 [0x0002]) called from 0x000adf64
  output (plaintext):		0000                                                                [??]
17:11:14.277 I [playlist] playlist ACK
shn_encrypt(ctx=0x852490, buf=0xbfffddc0, len=191 [0x00bf]) called from 0x000abc35
  input (plaintext):
	3600bc0000c6de2f ac7f3db84e57dd94 746b750bee020000 0006000000015723 [6??????/??=?NW??tku???????????W#]
	090800033c636861 6e67653e3c6f7073 3e3c64656c3e3c69 3e303c2f693e3c6b [????<change><ops><del><i>0</i><k]
	3e313c2f6b3e3c2f 64656c3e3c2f6f70 733e3c74696d653e 3132343038353232 [>1</k></del></ops><time>12408522]
	37343c2f74696d65 3e3c757365723e6b 656e742e66696e65 6c6c3c2f75736572 [74</time><user>kent.finell</user]
	3e3c2f6368616e67 653e3c7665727369 6f6e3e3030303030 30303030372c3030 [></change><version>0000000007,00]
	3030303030303030 2c30303030303030 3030312c303c2f76 657273696f6e3e   [00000000,0000000001,0</version>]
readv(fd=5, iovec=0xb0122e18 {iov_base=0x81321c, iov_len=3000}, iovcnt=15) called from 0x000cc80f (thread 0xb0123000)
shn_decrypt(ctx=0x8523c0, buf=0xb0122e8c, len=3 [0x0003]) called from 0x000adef4
  output (plaintext):		090004                                                              [???]
shn_decrypt(ctx=0x8523c0, buf=0x81321f, len=4 [0x0004]) called from 0x000adf64
  output (plaintext):		00000000                                                            [????]
shn_decrypt(ctx=0x8523c0, buf=0xb0122e8c, len=3 [0x0003]) called from 0x000adef4
  output (plaintext):		090059                                                              [??Y]
shn_decrypt(ctx=0x8523c0, buf=0x81322a, len=89 [0x0059]) called from 0x000adf64
  output (plaintext):
	00003c636f6e6669 726d3e3c7269643e 383930363c2f7269 643e3c7665727369 [??<confirm><rid>8906</rid><versi]
	6f6e3e3030303030 30303030372c3030 3030303030303030 2c30303030303030 [on>0000000007,0000000000,0000000]
	3030312c303c2f76 657273696f6e3e3c 2f636f6e6669726d 3e               [001,0</version></confirm>]
shn_decrypt(ctx=0x8523c0, buf=0xb0122e8c, len=3 [0x0003]) called from 0x000adef4
  output (plaintext):		090002                                                              [???]
shn_decrypt(ctx=0x8523c0, buf=0x81328a, len=2 [0x0002]) called from 0x000adf64
  output (plaintext):		0000                                                                [??]
17:11:14.962 I [playlist] playlist ACK


   */

  /**
   * @param protocol
   * @return removed track removed from playlist
   * @throws se.despotify.exceptions.DespotifyException
   */
  @Override
  public Track send(Protocol protocol) throws DespotifyException {

    if (!playlist.isCollaborative() && !playlist.getAuthor().equals(user.getName())) {
      throw new DespotifyException("Playlist must be collaborative or owned by the current user!");
    }

    if (user.getPlaylists() == null) {
      new LoadUserPlaylists(store, user).send(protocol);
    }

    if (playlist.getTracks() == null) {
      playlist.setTracks(new ArrayList<Track>());
    }


    long previousChecksum = playlist.calculateChecksum();

    Track track = playlist.getTracks().remove(position - 1);

    playlist.setChecksum(playlist.calculateChecksum());

    String xml = String.format(
        "<change><ops><del><i>%s</i><k>%s</k></del></ops><time>%d</time><user>%s</user></change>" +
            "<version>%010d,%010d,%010d,%d</version>",
        playlist.getTracks().size(), // todo uncertain
        1, // unknown <k>
        new Date().getTime() / 1000,
        user.getName(),
        playlist.getRevision() + 1,
        playlist.getTracks().size(),
        playlist.getChecksum(),
        playlist.isCollaborative() ? 1 : 0
    );

    /* Create channel callback */
    ChannelCallback callback = new ChannelCallback();

    Channel channel = new Channel("Change-Playlist-Channel", Channel.Type.TYPE_PLAYLIST, callback);
    byte[] xmlBytes = xml.getBytes();
    ByteBuffer buffer = ByteBuffer.allocate(2 + 16 + 1 + 4 + 4 + 4 + 1 + 1 + xmlBytes.length);

    buffer.putShort((short) channel.getId());
    buffer.put(playlist.getUUID());
    buffer.put((byte) 0x02); // track UUID type tag

    buffer.putInt(playlist.getRevision().intValue());
    buffer.putInt(position); // uncertain 
    buffer.putInt((int)previousChecksum); // -1 only seen when creating new playlist.
    buffer.put((byte) (playlist.isCollaborative() ? 0x01 : 0x00));
    buffer.put((byte) 0x03); // unknown
    buffer.put(xmlBytes);
    buffer.flip();

    /* Register channel. */
    Channel.register(channel);

    /* Send packet. */
    protocol.sendPacket(PacketType.changePlaylist, buffer, "remove track from playlist");

    /* Get response. */
    byte[] data = callback.getData("remove track from playlist ack");

    xml = "<?xml version=\"1.0\" encoding=\"utf-8\" ?>\n<playlist>\n" +
        new String(data, Charset.forName("UTF-8")) +
        "\n</playlist>";
    if (log.isDebugEnabled()) {
      log.debug(xml);
    }
    XMLElement response = XML.load(xml);

    if (response.hasChild("confirm")) {
      // <version>0000000002,0000000001,1326385279,0</version>
      String[] versionTagValues = response.getChild("confirm").getChildText("version").split(",", 4);

      playlist.setRevision(Long.parseLong(versionTagValues[0]));
      playlist.setChecksum(Long.parseLong(versionTagValues[2]));

      if (playlist.size() != Long.parseLong(versionTagValues[1])) {
        throw new RuntimeException("Size mismatch");
      }
      if(playlist.getChecksum() != playlist.calculateChecksum()) {
        throw new ChecksumException(playlist.getChecksum(), playlist.calculateChecksum());
      }
      if (playlist.isCollaborative() != (Integer.parseInt(versionTagValues[3]) == 1)) {
        throw new RuntimeException();
      }

      return track;
    } else {
      playlist.getTracks().add(position, track);
      throw new RuntimeException("Unknown server response:\n" + xml);
    }

    
  }
}
