package se.despotify.util;

import junit.framework.TestCase;
import org.junit.Test;

/**
 *
 * @since 2009-apr-23 08:12:25
 */
public class TestSpotifyURI extends TestCase {

  @Test
  public void test() {
    assertFalse(SpotifyURI.isHex("6Odybr7gR4L9LwO8dBgBwS"));
    assertTrue(SpotifyURI.isHex("dfc122480dd8711e45ec94f69d2e56ba"));
    
    assertFalse(SpotifyURI.isHex("dfc122480dd8711e45ec94f69d2e56babb"));
    assertFalse(SpotifyURI.isHex("dfc122480dd8711e45ec94f69d2e"));

  }


}
