package se.despotify.domain.media;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import se.despotify.util.Hex;

import java.util.Arrays;
import java.util.regex.Pattern;

/**
 * @since 2009-apr-24 14:17:32
 */
public abstract class Media implements Visitable {

  protected static Logger log = LoggerFactory.getLogger(Media.class);

  protected abstract int getUUIDlength();
  protected abstract Pattern getHexUUIDpattern();

  protected final static Pattern hexUUIDpattern32 = Pattern.compile("^[0-9a-fA-F]{32}$");
  protected final static Pattern hexUUIDpattern40 = Pattern.compile("^[0-9a-fA-F]{40}$");


  protected  boolean isHexUUID(String value) {
    return getHexUUIDpattern().matcher(value).matches();
  }


  private byte[] UUID;

  protected Media() {
    UUID = null;
    hexUUID = null;
  }

  protected Media(byte[] UUID) {
    this(UUID, null);
  }

  protected Media(byte[] UUID, String hexUUID) {
    this.UUID = UUID;
    this.hexUUID = hexUUID;
  }

  protected Media(String hexUUID) {
    if (hexUUID == null) {
      throw new NullPointerException("Expected hex UUID");
    }
    if (!isHexUUID(hexUUID)) {
      throw new IllegalArgumentException(hexUUID + " is not a hex UUID");
    }
    this.UUID = Hex.toBytes(hexUUID);
    this.hexUUID = hexUUID;
  }

  public void setUUID(String hexUUID) {
    if (isHexUUID(hexUUID)) {
      this.UUID= Hex.toBytes(hexUUID);
      this.hexUUID = hexUUID;
    } else {
      throw new IllegalArgumentException(hexUUID + " is not a valid UUID.");
    }
  }

  public void setUUID(byte[] UUID) {
    if (UUID == null) {
      throw new IllegalArgumentException("UUID must not be null");
    } else if (UUID.length != getUUIDlength()) {
      throw new IllegalArgumentException("UUID should be "+getUUIDlength()+" bytes");
    }
    this.UUID = UUID;
    hexUUID = null; // reset
  }

	public final byte[] getUUID(){
		return this.UUID;
	}

  // todo transient URI too!

  private transient String hexUUID;

  public final String getHexUUID() {
    if (hexUUID == null && UUID != null) {
      hexUUID = Hex.toHex(UUID);
    }
    return hexUUID;
  }


	public abstract String getSpotifyURL();

  public abstract String getHttpURL();

  @Override
  public boolean equals(Object o) {
    if (this == o) return true;
    if (o == null || getClass() != o.getClass()) return false;

    Media media = (Media) o;

    return Arrays.equals(UUID, media.UUID);

  }

  @Override
  public int hashCode() {
    return Arrays.hashCode(UUID);
  }

  @Override
  public String toString() {
    return getClass().getSimpleName() + "{" +
        "hexUUID=" + getHexUUID()+
        '}';
  }
}
