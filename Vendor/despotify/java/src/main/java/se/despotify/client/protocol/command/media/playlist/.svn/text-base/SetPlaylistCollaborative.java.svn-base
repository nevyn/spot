package se.despotify.client.protocol.command.media.playlist;

import se.despotify.client.protocol.command.Command;
import se.despotify.client.protocol.Protocol;
import se.despotify.client.protocol.PacketType;
import se.despotify.client.protocol.channel.ChannelCallback;
import se.despotify.client.protocol.channel.Channel;
import se.despotify.domain.media.Playlist;
import se.despotify.domain.User;
import se.despotify.exceptions.DespotifyException;
import se.despotify.util.XMLElement;
import se.despotify.util.XML;

import java.util.Date;
import java.nio.charset.Charset;
import java.nio.ByteBuffer;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * @since 2009-apr-27 21:11:36
 */
public class SetPlaylistCollaborative extends Command<Boolean> {

  private static Logger log = LoggerFactory.getLogger(SetPlaylistCollaborative.class);

  private User user;
  private Playlist playlist;
  private boolean value;

  public SetPlaylistCollaborative(User user, Playlist playlist, boolean value) {
    this.user = user;
    this.playlist = playlist;
    this.value = value;
  }

  public Boolean send(Protocol protocol) throws DespotifyException {

    if (!playlist.getAuthor().equals(user.getName())) {
      throw new RuntimeException("user " + user.getName() + " != author " + playlist.getAuthor());
    }

    String xml = String.format(
        "<change><ops><pub>%d</pub></ops>" +
            "<time>%d</time><user>%s</user></change>" +
            "<version>%010d,%010d,%010d,%d</version>",
        value ? 1 : 0, new Date().getTime() / 1000, user.getName(),
        playlist.getRevision() + 1, playlist.getTracks().size(),
        playlist.getChecksum(), playlist.isCollaborative() ? 1 : 0
    );

    /* Create channel callback */
    ChannelCallback callback = new ChannelCallback();

    /* Create channel and buffer. */
    Channel channel  = new Channel("Change-Playlist-Channel", Channel.Type.TYPE_PLAYLIST, callback);
    byte[]     xmlBytes = xml.getBytes();
    ByteBuffer buffer   = ByteBuffer.allocate(2 + 17 + 4 + 4 + 4 + 1 + 1 + xmlBytes.length);

    /* Append channel id, playlist id and some bytes... */
    buffer.putShort((short)channel.getId());
    buffer.put(playlist.getUUID()); /* 16 bytes */
    buffer.put((byte)0x00); // 0x00 for adding tracks, 0x02 for the rest?
    buffer.putInt(playlist.getRevision().intValue());
    buffer.putInt(playlist.getTracks().size());
    buffer.putInt(playlist.getChecksum().intValue()); /* -1: Create playlist. */
    buffer.put((byte)(playlist.isCollaborative()?0x01:0x00));
    buffer.put((byte)0x03); /* Unknown */
    buffer.put(xmlBytes);
    buffer.flip();

    /* Register channel. */
    Channel.register(channel);

    /* Send packet. */
    protocol.sendPacket(PacketType.changePlaylist, buffer, value ? "set playlist collaborative flag true" : "set playlist collaborative flag false");

    /* Get response. */
    byte[] data = callback.getData(value ? "set playlist collaborative flag true response" : "set playlist collaborative flag false reponse");


    xml = "<?xml version=\"1.0\" encoding=\"utf-8\" ?><playlist>" +
            new String(data, Charset.forName("UTF-8")) +
            "</playlist>";
    if (log.isDebugEnabled()) {
      log.debug(xml);
    }
    XMLElement playlistElement = XML.load(xml);


    if (playlistElement.hasChild("confirm")) {
      /* Split version string into parts. */
      String[] parts = playlistElement.getChild("confirm").getChildText("version").split(",", 4);

      /* Set values. */
      playlist.setRevision(Long.parseLong(parts[0]));
      playlist.setChecksum(Long.parseLong(parts[2]));
      playlist.setCollaborative(Integer.parseInt(parts[3]) == 1);

      return true;
    }

    return false;

  }
}
