package se.despotify.client.protocol;

public enum PacketType {

  // todo: make sure you add new commands to the {@link #toValue(int)} method!
  
  /* Core functionality. */
  secrectBlock(0x02),
  ping(0x04),
  getSubStream(0x08),
  channelData(0x09),
  channelerR(0x0a),
  channelAbort(0x0b),
  requestKey(0x0c),
  AESkey(0x0d),
  cacheHash(0x0f),
  SHAcache(0x10),
  image(0x19),
  tokenNotify(0x4f),

  /* Rights management. */
  countryCode(0x1b),

  /* P2P related. */
  p2pSetup(0x20),
  p2pInitBlock(0x21),

  /* Search and metadata. */
  browse(0x30),
  search(0x31),
  trackAddedToPlaylist(0x34),
  getPlaylist(0x35),
  changePlaylist(0x36),

  /* Session management. */
  notify(0x42),
  log(0x48),
  pong(0x49),
  pongAck(0x4a),
  pause(0x4b),
  requestAd(0x4e),
  requestPlay(0x4f),

  /* Internal. */
  productInformation(0x50),
  welcome(0x69);


  private byte byteValue;
  private int intValue;

  PacketType(int intValue) {
    this.intValue = intValue;
    byteValue = (byte)intValue;
  }

  public static PacketType valueOf(int intValue) {

    if (intValue == secrectBlock.getIntValue()) {
      return secrectBlock;
    } else if (intValue == ping.getIntValue()) {
      return ping;
    } else if (intValue == getSubStream.getIntValue()) {
      return getSubStream;
    } else if (intValue == channelData.getIntValue()) {
      return channelData;
    } else if (intValue == channelerR.getIntValue()) {
      return channelerR;
    } else if (intValue == channelAbort.getIntValue()) {
      return channelAbort;
    } else if (intValue == requestKey.getIntValue()) {
      return requestKey;
    } else if (intValue == AESkey.getIntValue()) {
      return AESkey;
    } else if (intValue == cacheHash.getIntValue()) {
      return cacheHash;
    } else if (intValue == SHAcache.getIntValue()) {
      return SHAcache;
    } else if (intValue == image.getIntValue()) {
      return image;
    } else if (intValue == tokenNotify.getIntValue()) {
      return tokenNotify;
    } else if (intValue == countryCode.getIntValue()) {
      return countryCode;
    } else if (intValue == p2pSetup.getIntValue()) {
      return p2pSetup;
    } else if (intValue == p2pInitBlock.getIntValue()) {
      return p2pInitBlock;
    } else if (intValue == browse.getIntValue()) {
      return browse;
    } else if (intValue == search.getIntValue()) {
      return search;
    } else if (intValue == trackAddedToPlaylist.getIntValue()) {
      return trackAddedToPlaylist;
    } else if (intValue == getPlaylist.getIntValue()) {
      return getPlaylist;
    } else if (intValue == changePlaylist.getIntValue()) {
      return changePlaylist;
    } else if (intValue == notify.getIntValue()) {
      return notify;
    } else if (intValue == log.getIntValue()) {
      return log;
    } else if (intValue == pong.getIntValue()) {
      return pong;
    } else if (intValue == pongAck.getIntValue()) {
      return pongAck;
    } else if (intValue == pause.getIntValue()) {
      return pause;
    } else if (intValue == requestAd.getIntValue()) {
      return requestAd;
    } else if (intValue == requestPlay.getIntValue()) {
      return requestPlay;
    } else if (intValue == productInformation.getIntValue()) {
      return productInformation;
    } else if (intValue == welcome.getIntValue()) {
      return welcome;
    }

    return null;
  }

  public byte getByteValue() {
    return byteValue;
  }

  public int getIntValue() {
    return intValue;
  }

  public static void main(String[] args) throws Exception {
    System.currentTimeMillis();
  }
}
