package se.despotify.domain.media;

import se.despotify.domain.Store;
import se.despotify.util.XMLElement;

import javax.imageio.ImageIO;
import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.util.Arrays;
import java.util.regex.Pattern;

/**
 * @since 2009-apr-27 18:08:58
 */
public class Image extends Media {

  public Image() {
  }

  public Image(byte[] UUID) {
    super(UUID);
  }

  public Image(byte[] UUID, String hexUUID) {
    super(UUID, hexUUID);
  }

  public Image(String hexUUID) {
    super(hexUUID);
  }

  @Override
  protected int getUUIDlength() {
    return 20;
  }

  @Override
  protected Pattern getHexUUIDpattern() {
    return hexUUIDpattern40;
  }


  public void accept(Visitor visitor) {
    visitor.visit(this);
  }


  public String getSpotifyURL() {
    throw new UnsupportedOperationException();
  }

  public String getHttpURL() {
    throw new UnsupportedOperationException();
  }

  private int width;
  private int height;

  private byte[] bytes;

  public byte[] getBytes() {
    return bytes;
  }

  public void setBytes(byte[] bytes) {
    this.bytes = bytes;
  }

  public int getWidth() {
    return width;
  }

  public void setWidth(int width) {
    this.width = width;
  }

  public int getHeight() {
    return height;
  }

  public void setHeight(int height) {
    this.height = height;
  }



  public java.awt.Image toAwtImage() {
    try {
      return ImageIO.read(new ByteArrayInputStream(getBytes()));
    }
    catch (IOException e) {
      throw new RuntimeException(e);
    }
  }

  public static Image fromXMLElement(XMLElement imageNode, Store store) {
    Image image;

    if (imageNode.hasChild("id")) {
      image = store.getImage(imageNode.getChildText("id"));
    } else if (Media.hexUUIDpattern40.matcher(imageNode.getText()).matches()) {
      image = store.getImage(imageNode.getText());
    } else {
      throw new RuntimeException("Image hexUUID missing in XML node");
    }

    if (imageNode.hasChild("height")) {
      image.setHeight(Integer.valueOf(imageNode.getChildText("height")));
    }

    if (imageNode.hasChild("width")) {
      image.setWidth(Integer.valueOf(imageNode.getChildText("width")));
    }

    return image;
  }

  @Override
  public String toString() {
    return "Image{" +
        "hexUUID=" + getHexUUID() +
        ", width=" + width +
        ", height=" + height +
        ", bytes=" + (bytes == null ? null : bytes.length) +
        '}';
  }
}
