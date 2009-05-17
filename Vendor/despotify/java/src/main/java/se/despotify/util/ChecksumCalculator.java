package se.despotify.util;

import se.despotify.domain.media.*;

import java.util.zip.Adler32;

/**
 * @since 2009-apr-25 21:59:26
 */
public class ChecksumCalculator extends VisitorAdapter {

  private Adler32 checksum;

  public ChecksumCalculator() {
    checksum = new Adler32();
  }

  public long getValue() {
    return checksum.getValue();
  }

  @Override
  public void visit(Album album) {
    checksum.update(album.getUUID());
    checksum.update((byte)0x02);
  }

  @Override
  public void visit(Artist artist) {
    checksum.update(artist.getUUID());
    checksum.update((byte)0x02);
  }

  @Override
  public void visit(Playlist playlist) {
    checksum.update(playlist.getUUID());
    checksum.update((byte)0x02); // verified 0x02
  }

  @Override
  public void visit(Track track) {
    checksum.update(track.getUUID());
    checksum.update((byte)0x01);  // verified 0x01
  }

  public Adler32 getChecksum() {
    return checksum;
  }
}
