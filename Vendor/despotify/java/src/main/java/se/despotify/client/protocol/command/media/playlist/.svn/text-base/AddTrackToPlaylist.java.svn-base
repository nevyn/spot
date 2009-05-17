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


public class AddTrackToPlaylist extends Command<Boolean> {

  private static Logger log = LoggerFactory.getLogger(AddTrackToPlaylist.class);

  private Store store;
  private User user;
  private Playlist playlist;
  private Track track;
  private Integer position;

  /**
   * @param store
   * @param user
   * @param playlist a fresh playlist containing all tracks already available (for checksum)
   * @param track track to add to playlist
   * @param position null for next new position in playlist
   */
  public AddTrackToPlaylist(Store store, User user, Playlist playlist, Track track, Integer position) {
    this.store = store;
    this.user = user;
    this.playlist = playlist;
    this.track = track;
    this.position = position;
  }


  @Override
  public Boolean send(Protocol protocol) throws DespotifyException {

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

    if (position != null && position != playlist.getTracks().size()) {
      throw new IllegalArgumentException("position not implemented!");
    }
    
    if (position == null) {
      position = playlist.size();
    }
    playlist.getTracks().add(position, track);

    playlist.setChecksum(playlist.calculateChecksum());

    String xml = String.format(
        "<change><ops><add><i>%s</i><items>%s</items></add></ops><time>%d</time><user>%s</user></change>" +
            "<version>%010d,%010d,%010d,%d</version>",
        position,
        track.getHexUUID() + "01", // hex uuid tag
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

    /* Append channel id, playlist id and some bytes... */
    buffer.putShort((short) channel.getId());
    buffer.put(playlist.getUUID());
    buffer.put((byte) 0x02); // track UUID type tag

    buffer.putInt(playlist.getRevision().intValue());
    buffer.putInt(playlist.getTracks().size() - 1);
    buffer.putInt((int)previousChecksum); // -1 only seen when creating new playlist.
    buffer.put((byte) (playlist.isCollaborative() ? 0x01 : 0x00));
    buffer.put((byte) 0x03); // unknown
    buffer.put(xmlBytes);
    buffer.flip();

    /* Register channel. */
    Channel.register(channel);

    /* Send packet. */
    protocol.sendPacket(PacketType.changePlaylist, buffer, "add track to playlist");

    /* Get response. */
    byte[] data = callback.getData("add track to playlist, updated playlist response");

    xml = "<?xml version=\"1.0\" encoding=\"utf-8\" ?>\n<playlist>\n" +
        new String(data, Charset.forName("UTF-8")) +
        "\n</playlist>";
    log.debug(xml);
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
      if(playlist.isCollaborative() != (Integer.parseInt(versionTagValues[3]) == 1)) {
        throw new RuntimeException(); 
      }

      return true;
    } else {
      playlist.getTracks().remove(position.intValue());
      throw new RuntimeException("Unknown server response:\n" + xml);
    }

  }
}
