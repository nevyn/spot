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
import se.despotify.domain.media.Playlist;
import se.despotify.domain.media.PlaylistContainer;
import se.despotify.exceptions.DespotifyException;
import se.despotify.util.Hex;
import se.despotify.util.XML;
import se.despotify.util.XMLElement;

import java.nio.ByteBuffer;
import java.nio.charset.Charset;
import java.util.Date;

/**
 * @since 2009-apr-26 23:53:40
 */
public class RemovePlaylistFromUser extends Command<Boolean> {

  private static Logger log = LoggerFactory.getLogger(RemovePlaylistFromUser.class);

  private Store store;
  private User user;
  private Playlist playlist;

  public RemovePlaylistFromUser(Store store, User user, Playlist playlist) {
    this.store = store;
    this.user = user;
    this.playlist = playlist;
  }

  @Override
  public Boolean send(Protocol protocol) throws DespotifyException {

    if (user.getPlaylists() == null) {
      log.warn("user playlists not loaded yet! should it be? loading..");
      new LoadUserPlaylists(store, user).send(protocol);
    }

    int position = user.getPlaylists().getItems().indexOf(playlist);
    if (position == -1) {
      throw new RuntimeException("playlist is not available in user playlists");
    }
    if (playlist != user.getPlaylists().getItems().remove(position)) {
      throw new RuntimeException();
    }

    // todo probably don't destoy collaborative that is not owned by user? or?

    if (!sendDelete(protocol, position)) {
      throw new DespotifyException();
    }
    if (!sendDestroy(protocol, position)) {
      throw new DespotifyException();
    }
    return true;
  }

  /*

   create and delete playlist number 4.

shn_encrypt(ctx=0x1b6f5c, buf=0xbfffea1f, len=17 [0x0011]) called from 0x0007e635
  input (plaintext):
	0000000000000000 0000000000000000 00                                [?????????????????]
shn_encrypt(ctx=0x8f0e90, buf=0xbfffdda0, len=204 [0x00cc]) called from 0x000abc35
  input (plaintext):
	3600c9000068e092 0f76e14fdd483228 48bca7ab7d020000 000000000000ffff [6????h???v?O?H2(H???}???????????]
	ffff01033c69642d 69732d756e697175 652f3e3c6368616e 67653e3c6f70733e [????<id-is-unique/><change><ops>]
	3c6372656174652f 3e3c6e616d653e61 73643c2f6e616d65 3e3c2f6f70733e3c [<create/><name>asd</name></ops><]
	74696d653e313234 303838313339303c 2f74696d653e3c75 7365723e6b656e74 [time>1240881390</time><user>kent]
	2e66696e656c6c3c 2f757365723e3c2f 6368616e67653e3c 76657273696f6e3e [.finell</user></change><version>]
	3030303030303030 30312c3030303030 30303030302c3030 3030303030303031 [0000000001,0000000000,0000000001]
	2c303c2f76657273 696f6e3e                                           [,0</version>]
readv(fd=5, iovec=0xb0122e18 {iov_base=0x813e1c, iov_len=3000}, iovcnt=15) called from 0x000cc80f (thread 0xb0123000)
shn_decrypt(ctx=0x8f0dc0, buf=0xb0122e8c, len=3 [0x0003]) called from 0x000adef4
  output (plaintext):		090004                                                              [???]
shn_decrypt(ctx=0x8f0dc0, buf=0x813e1f, len=4 [0x0004]) called from 0x000adf64
  output (plaintext):		00000000                                                            [????]
shn_decrypt(ctx=0x8f0dc0, buf=0xb0122e8c, len=3 [0x0003]) called from 0x000adef4
  output (plaintext):		09005b                                                              [??[]
shn_decrypt(ctx=0x8f0dc0, buf=0x813e2a, len=91 [0x005b]) called from 0x000adf64
  output (plaintext):
	00003c636f6e6669 726d3e3c7269643e 3132383635313c2f 7269643e3c766572 [??<confirm><rid>128651</rid><ver]
	73696f6e3e303030 303030303030312c 3030303030303030 30302c3030303030 [sion>0000000001,0000000000,00000]
	30303030312c303c 2f76657273696f6e 3e3c2f636f6e6669 726d3e           [00001,0</version></confirm>]
shn_decrypt(ctx=0x8f0dc0, buf=0xb0122e8c, len=3 [0x0003]) called from 0x000adef4
  output (plaintext):		090002                                                              [???]
shn_decrypt(ctx=0x8f0dc0, buf=0x813e8c, len=2 [0x0002]) called from 0x000adf64
  output (plaintext):		0000                                                                [??]
01:16:36.029 I [playlist] playlist ACK
shn_encrypt(ctx=0x8f0e90, buf=0xbfffddc0, len=232 [0x00e8]) called from 0x000abc35
  input (plaintext):
	3600e50000000000 0000000000000000 0000000000000000 002200000003a452 [6????????????????????????"?????R]
	183a00033c636861 6e67653e3c6f7073 3e3c6164643e3c69 3e333c2f693e3c69 [?:??<change><ops><add><i>3</i><i]
	74656d733e363865 3039323066373665 3134666464343833 3232383438626361 [tems>68e0920f76e14fdd48322848bca]
	376162376430323c 2f6974656d733e3c 2f6164643e3c2f6f 70733e3c74696d65 [7ab7d02</items></add></ops><time]
	3e31323430383831 3339303c2f74696d 653e3c757365723e 6b656e742e66696e [>1240881390</time><user>kent.fin]
	656c6c3c2f757365 723e3c2f6368616e 67653e3c76657273 696f6e3e30303030 [ell</user></change><version>0000]
	3030303033352c30 3030303030303030 342c323333363735 393833372c303c2f [000035,0000000004,2336759837,0</]
	76657273696f6e3e                                                    [version>]
readv(fd=5, iovec=0xb0122e18 {iov_base=0x8c8a1c, iov_len=3000}, iovcnt=15) called from 0x000cc80f (thread 0xb0123000)
shn_decrypt(ctx=0x8f0dc0, buf=0xb0122e8c, len=3 [0x0003]) called from 0x000adef4
  output (plaintext):		090004                                                              [???]
shn_decrypt(ctx=0x8f0dc0, buf=0x8c8a1f, len=4 [0x0004]) called from 0x000adf64
  output (plaintext):		00000000                                                            [????]
shn_decrypt(ctx=0x8f0dc0, buf=0xb0122e8c, len=3 [0x0003]) called from 0x000adef4
  output (plaintext):		09005b                                                              [??[]
shn_decrypt(ctx=0x8f0dc0, buf=0x8c8a2a, len=91 [0x005b]) called from 0x000adf64
  output (plaintext):
	00003c636f6e6669 726d3e3c7269643e 3131393030343c2f 7269643e3c766572 [??<confirm><rid>119004</rid><ver]
	73696f6e3e303030 303030303033352c 3030303030303030 30342c3233333637 [sion>0000000035,0000000004,23367]
	35393833372c303c 2f76657273696f6e 3e3c2f636f6e6669 726d3e           [59837,0</version></confirm>]
shn_decrypt(ctx=0x8f0dc0, buf=0xb0122e8c, len=3 [0x0003]) called from 0x000adef4
  output (plaintext):		090002                                                              [???]
shn_decrypt(ctx=0x8f0dc0, buf=0x8c8a8c, len=2 [0x0002]) called from 0x000adf64
  output (plaintext):		0000                                                                [??]
01:16:36.187 I [playlist] playlist ACK
shn_encrypt(ctx=0x8f0e90, buf=0xb0122aa0, len=53 [0x0035]) called from 0x000abc35
  input (plaintext):
	4800323430093109 6172746973740931 3439393909623065 6138316333386263 [H?240?1?artist?14999?b0ea81c38bc]
	3834356562623437 3761346330356236 3064613031                        [845ebb477a4c05b60da01]
shn_encrypt(ctx=0x8f0e90, buf=0xb0122aa0, len=56 [0x0038]) called from 0x000abc35
  input (plaintext):
	4800353430093109 706c61796c697374 0931393233093638 6530393230663736 [H?540?1?playlist?1923?68e0920f76]
	6531346664643438 3332323834386263 6137616237643032                  [e14fdd48322848bca7ab7d02]
shn_encrypt(ctx=0x8f0e90, buf=0xbfffd4d0, len=191 [0x00bf]) called from 0x000abc35
  input (plaintext):
	3600bc0001000000 0000000000000000 0000000000000000 0023000000048b48 [6????????????????????????#?????H]
	201d00033c636861 6e67653e3c6f7073 3e3c64656c3e3c69 3e333c2f693e3c6b [ ???<change><ops><del><i>3</i><k]
	3e313c2f6b3e3c2f 64656c3e3c2f6f70 733e3c74696d653e 3132343038383133 [>1</k></del></ops><time>12408813]
	39343c2f74696d65 3e3c757365723e6b 656e742e66696e65 6c6c3c2f75736572 [94</time><user>kent.finell</user]
	3e3c2f6368616e67 653e3c7665727369 6f6e3e3030303030 30303033362c3030 [></change><version>0000000036,00]
	3030303030303033 2c32373536383433 3537382c303c2f76 657273696f6e3e   [00000003,2756843578,0</version>]
shn_encrypt(ctx=0x8f0e90, buf=0xbfffd4e0, len=174 [0x00ae]) called from 0x000abc35
  input (plaintext):
	3600ab000268e092 0f76e14fdd483228 48bca7ab7d020000 0001000000000000 [6????h???v?O?H2(H???}???????????]
	000100033c636861 6e67653e3c6f7073 3e3c64657374726f 792f3e3c2f6f7073 [????<change><ops><destroy/></ops]
	3e3c74696d653e31 3234303838313339 343c2f74696d653e 3c757365723e6b65 [><time>1240881394</time><user>ke]
	6e742e66696e656c 6c3c2f757365723e 3c2f6368616e6765 3e3c76657273696f [nt.finell</user></change><versio]
	6e3e303030303030 303030322c303030 303030303030302c 3030303030303030 [n>0000000002,0000000000,00000000]
	30312c303c2f7665 7273696f6e3e                                       [01,0</version>]
readv(fd=5, iovec=0xb0122e18 {iov_base=0x813e1c, iov_len=3000}, iovcnt=15) called from 0x000cc80f (thread 0xb0123000)
shn_decrypt(ctx=0x8f0dc0, buf=0xb0122e8c, len=3 [0x0003]) called from 0x000adef4
  output (plaintext):		090004                                                              [???]
shn_decrypt(ctx=0x8f0dc0, buf=0x813e1f, len=4 [0x0004]) called from 0x000adf64
  output (plaintext):		00020000                                                            [????]
shn_decrypt(ctx=0x8f0dc0, buf=0xb0122e8c, len=3 [0x0003]) called from 0x000adef4
  output (plaintext):		09005b                                                              [??[]
shn_decrypt(ctx=0x8f0dc0, buf=0x813e2a, len=91 [0x005b]) called from 0x000adf64
  output (plaintext):
	00023c636f6e6669 726d3e3c7269643e 3132383635323c2f 7269643e3c766572 [??<confirm><rid>128652</rid><ver]
	73696f6e3e303030 303030303030322c 3030303030303030 30302c3030303030 [sion>0000000002,0000000000,00000]
	30303030312c303c 2f76657273696f6e 3e3c2f636f6e6669 726d3e           [00001,0</version></confirm>]
shn_decrypt(ctx=0x8f0dc0, buf=0xb0122e8c, len=3 [0x0003]) called from 0x000adef4
  output (plaintext):		090002                                                              [???]
shn_decrypt(ctx=0x8f0dc0, buf=0x813e8c, len=2 [0x0002]) called from 0x000adf64
  output (plaintext):		0002                                                                [??]
readv(fd=5, iovec=0xb0122e18 {iov_base=0x8c8a1c, iov_len=3000}, iovcnt=15) called from 0x000cc80f (thread 0xb0123000)
shn_decrypt(ctx=0x8f0dc0, buf=0xb0122e8c, len=3 [0x0003]) called from 0x000adef4
  output (plaintext):		090004                                                              [???]
shn_decrypt(ctx=0x8f0dc0, buf=0x8c8a1f, len=4 [0x0004]) called from 0x000adf64
  output (plaintext):		00010000                                                            [????]
shn_decrypt(ctx=0x8f0dc0, buf=0xb0122e8c, len=3 [0x0003]) called from 0x000adef4
  output (plaintext):		09005b                                                              [??[]
shn_decrypt(ctx=0x8f0dc0, buf=0x8c8a2a, len=91 [0x005b]) called from 0x000adf64
  output (plaintext):
	00013c636f6e6669 726d3e3c7269643e 3131393030353c2f 7269643e3c766572 [??<confirm><rid>119005</rid><ver]
	73696f6e3e303030 303030303033362c 3030303030303030 30332c3237353638 [sion>0000000036,0000000003,27568]
	34333537382c303c 2f76657273696f6e 3e3c2f636f6e6669 726d3e           [43578,0</version></confirm>]
shn_decrypt(ctx=0x8f0dc0, buf=0xb0122e8c, len=3 [0x0003]) called from 0x000adef4
  output (plaintext):		090002                                                              [???]
shn_decrypt(ctx=0x8f0dc0, buf=0x8c8a8c, len=2 [0x0002]) called from 0x000adf64
  output (plaintext):		0001                                                                [??]
01:16:39.272 I [playlist] playlist ACK


  */

  /**
   * @param protocol
   * @return
   * @throws se.despotify.exceptions.DespotifyException
   */
  public boolean sendDelete(Protocol protocol, int position) throws DespotifyException {

    ChannelCallback callback = new ChannelCallback();

    /* Create channel and buffer. */
    Channel channel = new Channel("Create-Playlist-Channel", Channel.Type.TYPE_PLAYLIST, callback);

    PlaylistContainer playlists = user.getPlaylists();

    String xml = String.format
        ("<change><ops><del><i>%s</i><k>%s</k></del></ops><time>%s</time><user>%s</user></change>" +
            "<version>%010d,%010d,%010d,%d</version>",
            // change
            position,
            1, // unknown
            new Date().getTime() / 1000,
            user.getName(),
            // version
            playlists.getRevision() + 1,
            playlists.getItems().size(),
            playlists.getChecksum(),
            playlist.isCollaborative() ? 1 : 0
        );

    byte[] xmlBytes = xml.getBytes();
    ByteBuffer buffer = ByteBuffer.allocate(2 + 16 + 1 + 4 + 4 + 4 + 1 + 1 + xmlBytes.length);

    buffer.putShort((short) channel.getId());
    buffer.put(Hex.toBytes("00000000000000000000000000000000")); // UUID? not used
    buffer.put((byte) 0x00); // type? not used
    buffer.putInt((int) playlists.getRevision());
    buffer.putInt(playlists.getItems().size() + 1);
    buffer.putInt((int) playlists.getChecksum());

    buffer.put((byte) (playlist.isCollaborative() ? 0x01 : 0x00));
    buffer.put((byte) 0x03); // unknown
    buffer.put(xmlBytes);
    buffer.flip();

    /* Register channel. */
    Channel.register(channel);

    /* Send packet. */
    protocol.sendPacket(PacketType.changePlaylist, buffer, "remove playlist from user");

    return true;

  }

  public Boolean sendDestroy(Protocol protocol, int position) throws DespotifyException {


    ChannelCallback callback = new ChannelCallback();

    /* Create channel and buffer. */
    Channel channel = new Channel("Create-Playlist-Channel", Channel.Type.TYPE_PLAYLIST, callback);

    PlaylistContainer playlists = user.getPlaylists();


    String xml = String.format
        ("<change><ops><destroy/></ops><time>%s</time><user>%s</user></change>" +
            "<version>%010d,%010d,%010d,%d</version>",
            new Date().getTime() / 1000,
            user.getName(),
            // version
            playlist.getRevision() + 1,
            playlist.getTracks().size(),
            playlist.getChecksum(),
            playlist.isCollaborative() ? 1 : 0
        );

    byte[] xmlBytes = xml.getBytes();
    ByteBuffer buffer = ByteBuffer.allocate(2 + 16 + 1 + 4 + 4 + 4 + 1 + 1 + xmlBytes.length);

    //  3600bd00000000 000000000000000000 000000000000 00000426 0000001a a63f [6????????????????????????&??????]
    //  d3a7 00 03 3c636861 6e67653e3c6f7073 3e3c64656c3e3c69 3e32313c2f693e3c [????<change><ops><del><i>21</i><]


    buffer.putShort((short) channel.getId());
    buffer.put(playlist.getUUID());
    buffer.put((byte) 0x02); // playlist type UUID tag
    buffer.putInt((int) playlist.getRevision().longValue());
    buffer.putInt(playlist.getTracks().size());
    buffer.putInt((int) playlists.getChecksum());

    buffer.put((byte) (playlist.isCollaborative() ? 0x01 : 0x00));
    buffer.put((byte) 0x03); // unknown
    buffer.put(xmlBytes);
    buffer.flip();

    /* Register channel. */
    Channel.register(channel);

    /* Send packet. */
    protocol.sendPacket(PacketType.changePlaylist, buffer, "destroy playlist");

    /* Get response. */
    byte[] data = callback.getData("destroy playlist response");

    xml = "<?xml version=\"1.0\" encoding=\"utf-8\" ?>\n<playlists>\n" +
        new String(data, Charset.forName("UTF-8")) +
        "\n</playlists>";

    if (log.isDebugEnabled()) {
      log.debug(xml);
    }
    XMLElement response = XML.load(xml);

    Playlist.fromXMLElement(response, store, playlist);

    if (response.hasChild("next-change")) {
      return true;
    } else {
      playlists.getItems().add(position - 1, playlist);
      throw new RuntimeException("Unknown server response:\n" + xml);
    }
  }
}
