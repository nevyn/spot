package se.despotify.client.protocol.command;

import se.despotify.client.protocol.PacketType;
import se.despotify.client.protocol.Protocol;
import se.despotify.client.protocol.channel.Channel;
import se.despotify.client.protocol.channel.ChannelCallback;
import se.despotify.domain.media.Image;
import se.despotify.exceptions.DespotifyException;

import java.nio.ByteBuffer;

/**
 * @since 2009-apr-27 18:02:29
 */
public class LoadImage extends Command<Boolean> {

  private Image image;

  public LoadImage(Image image) {
    this.image = image;
  }

  public Boolean send(Protocol protocol) throws DespotifyException {
    /* Data buffer. */
    byte[] data;

      /* Create channel callback */
      ChannelCallback callback = new ChannelCallback();

    /* Create channel and buffer. */
    Channel channel = new Channel("Image-Channel", Channel.Type.TYPE_IMAGE, callback);
    ByteBuffer buffer  = ByteBuffer.allocate(2 + 20);

    /* Append channel id and image hash. */
    buffer.putShort((short)channel.getId());
    buffer.put(image.getUUID());
    buffer.flip();

    /* Register channel. */
    Channel.register(channel);

    /* Send packet. */
    protocol.sendPacket(PacketType.image, buffer, "load image");

      /* Get data. */
    image.setBytes(callback.getData("load image response"));

    return true;

  }
}
