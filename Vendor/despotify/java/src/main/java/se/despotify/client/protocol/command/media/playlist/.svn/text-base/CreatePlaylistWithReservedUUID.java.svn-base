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
import se.despotify.domain.media.PlaylistContainer;
import se.despotify.domain.media.Track;
import se.despotify.exceptions.DespotifyException;
import se.despotify.util.Hex;
import se.despotify.util.XML;
import se.despotify.util.XMLElement;

import java.nio.ByteBuffer;
import java.nio.charset.Charset;
import java.util.Date;
import java.util.ArrayList;

/**
 * despotify out
 * <p/>
 * head   chn  hex                             t  rev?     pos?     chksum?  ?
 * |    |                               |  |        |        |        |
 * 3600e5 0000 0000000000000000000000000000000000 00000005 00000000 00000001 00
 * <p/>
 * spotify  out
 * <p/>
 * |    |                               |  |        |        |
 * 3600e5 0000 0000000000000000000000000000000000 00000006 00000001 3d2b066a 00  (1)
 * <p/>
 * 3600e5 0000 0000000000000000000000000000000000 00000007 00000002 dca00bb1 00  (2)
 * <p/>
 * 3600e5 0000 0000000000000000000000000000000000 0000000d 00000003 f17b1436 00  (3)
 * <p/>
 * 3600e6 0000 0000000000000000000000000000000000 0000004e 00000016 64b7b279 00  (23)
 * <p/>
 * <p/>
 * <p/>
 * <p/>
 * <p/>
 * create 1:
 * <p/>
 * 3600e50000000000 0000000000000000 0000000000000000 0006000000013d2b [6?????????????????????????????=+]
 * 066a00033c636861 6e67653e3c6f7073 3e3c6164643e3c69 3e313c2f693e3c69 [?j??<change><ops><add><i>1</i><i]
 * 74656d733e666435 3131393362333934 3239383133303032 3838353061316137 [tems>fd51193b394298130028850a1a7]
 * 326262376630323c 2f6974656d733e3c 2f6164643e3c2f6f 70733e3c74696d65 [2bb7f02</items></add></ops><time]
 * 3e31323430353335 3130353c2f74696d 653e3c757365723e 6b656e742e66696e [>1240535105</time><user>kent.fin]
 * 656c6c3c2f757365 723e3c2f6368616e 67653e3c76657273 696f6e3e30303030 [ell</user></change><version>0000]
 * 3030303030372c30 3030303030303030 322c333730313437 363237332c303c2f [000007,0000000002,3701476273,0</]
 * 76657273696f6e3e                                                    [version>]
 * <p/>
 * create 2:
 * <p/>
 * 3600e50000000000 0000000000000000 0000000000000000 000700000002dca0 [6???????????????????????????????]
 * 0bb100033c636861 6e67653e3c6f7073 3e3c6164643e3c69 3e323c2f693e3c69 [????<change><ops><add><i>2</i><i]
 * 74656d733e353731 3065363663646538 6133356266613832 3464353666383566 [tems>5710e66cde8a35bfa824d56f85f]
 * 646162333130323c 2f6974656d733e3c 2f6164643e3c2f6f 70733e3c74696d65 [dab3102</items></add></ops><time]
 * 3e31323430353335 3134383c2f74696d 653e3c757365723e 6b656e742e66696e [>1240535148</time><user>kent.fin]
 * 656c6c3c2f757365 723e3c2f6368616e 67653e3c76657273 696f6e3e30303030 [ell</user></change><version>0000]
 * 3030303030382c30 3030303030303030 332c343035313337 353135382c303c2f [000008,0000000003,4051375158,0</]
 * 76657273696f6e3e                                                    [version>]
 * <p/>
 * deleted and unded deletion of pos 1, then sent create 3:
 * <p/>
 * 3600e50000000000 0000000000000000 0000000000000000 000d00000003f17b [6??????????????????????????????{]
 * 143600033c636861 6e67653e3c6f7073 3e3c6164643e3c69 3e333c2f693e3c69 [?6??<change><ops><add><i>3</i><i]
 * 74656d733e363961 6533356665386434 3665353638353232 6333626461323565 [tems>69ae35fe8d46e568522c3bda25e]
 * 356532356530323c 2f6974656d733e3c 2f6164643e3c2f6f 70733e3c74696d65 [5e25e02</items></add></ops><time]
 * 3e31323430353336 3534353c2f74696d 653e3c757365723e 6b656e742e66696e [>1240536545</time><user>kent.fin]
 * 656c6c3c2f757365 723e3c2f6368616e 67653e3c76657273 696f6e3e30303030 [ell</user></change><version>0000]
 * 3030303031342c30 3030303030303030 342c323533343038 373830372c303c2f [000014,0000000004,2534087807,0</]
 * 76657273696f6e3e                                                    [version>]
 * <p/>
 *
 * @since 2009-apr-24 02:47:16
 */
public class CreatePlaylistWithReservedUUID extends Command<Boolean> {

  private static Logger log = LoggerFactory.getLogger(CreatePlaylistWithReservedUUID.class);

  private Store store;
  private Playlist playlist;
  private User user;

  public CreatePlaylistWithReservedUUID(Store store, User user, Playlist playlist) {
    this.store = store;
    this.playlist = playlist;
    this.user = user;
  }


  @Override
  public Boolean send(Protocol protocol) throws DespotifyException {


    if (playlist.isCollaborative() == null) {
      playlist.setCollaborative(false);
    }

    ChannelCallback callback = new ChannelCallback();

    /* Create channel and buffer. */
    Channel channel = new Channel("Create-Playlist-Channel", Channel.Type.TYPE_PLAYLIST, callback);

    if (user.getPlaylists() == null) {
      log.warn("user playlists not loaded yet! should it be? loading..");
      new LoadUserPlaylists(store, user).send(protocol);
    }
    PlaylistContainer playlists = user.getPlaylists();

    playlists.getItems().add(playlist);

    int position = playlists.getItems().size() - 1;

    String xml = String.format
        ("<change><ops><add><i>%s</i><items>%s</items></add></ops><time>%s</time><user>%s</user></change>" +
            "<version>%010d,%010d,%010d,%d</version>",
            // change
            position,
            Hex.toHex(playlist.getUUID()) + "02",
            new Date().getTime() / 1000,
            user.getName(),
            // version
            playlists.getRevision() + 1,         // new revision of user playlists
            playlists.getItems().size(),         // new size of user playlists
            playlists.calculateChecksum(),       // new checksum of user playlists
            playlist.isCollaborative() ? 1 : 0
        );

    byte[] xmlBytes = xml.getBytes();
    ByteBuffer buffer = ByteBuffer.allocate(2 + 16 + 1 + 4 + 4 + 4 + 1 + 1 + xmlBytes.length);

    buffer.putShort((short) channel.getId());
    buffer.put(Hex.toBytes("00000000000000000000000000000000")); // UUID? not used
    buffer.put((byte) 0x00); // type? not used
    buffer.putInt((int) playlists.getRevision()); // previous revision of user playlists
    buffer.putInt(position);
    buffer.putInt((int) playlists.getChecksum()); // previous checksum of user playlists

    buffer.put((byte) (playlist.isCollaborative() ? 0x01 : 0x00));
    buffer.put((byte) 0x03); // unknown
    buffer.put(xmlBytes);
    buffer.flip();

    /* Register channel. */
    Channel.register(channel);

    /* Send packet. */
    protocol.sendPacket(PacketType.changePlaylist, buffer, "create playlist");

    /* Get response. */
    byte[] data = callback.getData("create playlist response");

    xml = "<?xml version=\"1.0\" encoding=\"utf-8\" ?>\n<playlists>\n" +
        new String(data, Charset.forName("UTF-8")) +
        "\n</playlists>";

    if (log.isDebugEnabled()) {
      log.debug(xml);
    }
    XMLElement response = XML.load(xml);

    final XMLElement versionParentElement;
    if (response.hasChild("confirm")) {
      versionParentElement = response.getChild("confirm");
    } else if (response.hasChild("")) {
      versionParentElement = response;
    } else {
      throw new RuntimeException("Unknown server response:\n" + xml);
    }

    // <version>0000000007,0000000002,3701476273,0</version>
    String[] versionTagValues = versionParentElement.getChildText("version").split(",", 4);

    playlists.setRevision(Long.parseLong(versionTagValues[0]));
    playlists.setChecksum(Long.parseLong(versionTagValues[2]));

    if (playlists.getItems().size() != Long.parseLong(versionTagValues[1])) {
      throw new RuntimeException("Size missmatch");
    }

    if (playlists.calculateChecksum() != playlists.getChecksum()) {
      throw new ChecksumException(playlists.calculateChecksum(), playlists.getChecksum());
    }
    if (playlist.isCollaborative() != (Integer.parseInt(versionTagValues[3]) == 1)) {
      throw new RuntimeException("Collaborative flag missmatch");
    }

    playlist.setRevision(1l);
    playlist.setTracks(new ArrayList<Track>());
    playlist.setChecksum(1l);

    return true;
  }
}
