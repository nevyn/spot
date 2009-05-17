package se.despotify;

import org.junit.Test;
import se.despotify.domain.User;
import se.despotify.domain.media.Playlist;
import se.despotify.domain.media.PlaylistContainer;
import se.despotify.domain.media.Track;
import se.despotify.util.Hex;

import java.util.ArrayList;


/**
 * @since 2009-apr-23 10:09:37
 */
public class TestChecksum extends DespotifyClientTest {
  @Override
  protected Connection connectionFactory() {
    return null;
  }

  // todo artists, albums

  @Test
  public void testeAddTracksToPlaylist() {

    long[] checksums = new long[]{
        1461913864l,
        823267316l,
        2339641349l,
        1904484306l,
        3794544626l,
    };

    Playlist playlist = new Playlist(Hex.toBytes("473e7d4eef45cd4fa3ee2aaf96c01688"));
    playlist.setName("de");
    
    playlist.setTracks(new ArrayList<Track>(3));
          
    boolean fail = false;
    for (int i = 0; i < defaultTracks.length; i++) {
      playlist.getTracks().clear();
      for (int i2 = 0; i2 <= i; i2++) {
        playlist.getTracks().add((defaultTracks[i2]));
      }
      if (checksums[i] == playlist.calculateChecksum()) {
//        System.out.println("passing test" + i);
      } else {
        System.out.println("!! failing test " + i + ", calculated " + playlist.calculateChecksum() + " != expected " + checksums[i]);
        fail = true;
      }

    }

    assertFalse(fail);

  }


  @Test
  public void testAddPlaylistsToUser() {

    User user = new User();
    user.setPlaylists(new PlaylistContainer());

    assertEquals(1, user.getPlaylists().calculateChecksum());

    /*
    3600cd0000566796 2d4c1764d12cd68b 86a4394916020000 000000000000ffff [6????Vg?-L?d?,????9I????????????]
    ffff01033c69642d 69732d756e697175 652f3e3c6368616e 67653e3c6f70733e [????<id-is-unique/><change><ops>]
    3c6372656174652f 3e3c6e616d653e6a 6f74696679313c2f 6e616d653e3c2f6f [<create/><name>jotify1</name></o]
    70733e3c74696d65 3e31323430353335 3031373c2f74696d 653e3c757365723e [ps><time>1240535017</time><user>]
    6b656e742e66696e 656c6c3c2f757365 723e3c2f6368616e 67653e3c76657273 [kent.finell</user></change><vers]
    696f6e3e30303030 3030303030312c30 3030303030303030 302c303030303030 [ion>0000000001,0000000000,000000]
    303030312c303c2f 76657273696f6e3e                                   [0001,0</version>]

    3600e50000000000 0000000000000000 0000000000000000 0005000000000000 [6???????????????????????????????]
    000100033c636861 6e67653e3c6f7073 3e3c6164643e3c69 3e303c2f693e3c69 [????<change><ops><add><i>0</i><i]
    74656d733e353636 3739363264346331 3736346431326364 3638623836613433 [tems>5667962d4c1764d12cd68b86a43]
    393439313630323c 2f6974656d733e3c 2f6164643e3c2f6f 70733e3c74696d65 [9491602</items></add></ops><time]
    3e31323430353335 3031373c2f74696d 653e3c757365723e 6b656e742e66696e [>1240535017</time><user>kent.fin]
    656c6c3c2f757365 723e3c2f6368616e 67653e3c76657273 696f6e3e30303030 [ell</user></change><version>0000]
    3030303030362c30 3030303030303030 312c313032363232 393836362c303c2f [000006,0000000001,1026229866,0</]
    76657273696f6e3e                                                    [version>]
     */
    user.getPlaylists().getItems().add(new Playlist(Hex.toBytes("5667962d4c1764d12cd68b86a4394916"), "jotify1", "kent.finell", false));
    assertEquals(1026229866l, user.getPlaylists().calculateChecksum());

    /*
    3600cd0000fd5119 3b39429813002885 0a1a72bb7f020000 000000000000ffff [6?????Q?;9B???(???r?????????????]
    ffff01033c69642d 69732d756e697175 652f3e3c6368616e 67653e3c6f70733e [????<id-is-unique/><change><ops>]
    3c6372656174652f 3e3c6e616d653e6a 6f74696679323c2f 6e616d653e3c2f6f [<create/><name>jotify2</name></o]
    70733e3c74696d65 3e31323430353335 3130353c2f74696d 653e3c757365723e [ps><time>1240535105</time><user>]
    6b656e742e66696e 656c6c3c2f757365 723e3c2f6368616e 67653e3c76657273 [kent.finell</user></change><vers]
    696f6e3e30303030 3030303030312c30 3030303030303030 302c303030303030 [ion>0000000001,0000000000,000000]
    303030312c303c2f 76657273696f6e3e                                   [0001,0</version>]

    3600e50000000000 0000000000000000 0000000000000000 0006000000013d2b [6?????????????????????????????=+]
    066a00033c636861 6e67653e3c6f7073 3e3c6164643e3c69 3e313c2f693e3c69 [?j??<change><ops><add><i>1</i><i]
    74656d733e666435 3131393362333934 3239383133303032 3838353061316137 [tems>fd51193b394298130028850a1a7]
    326262376630323c 2f6974656d733e3c 2f6164643e3c2f6f 70733e3c74696d65 [2bb7f02</items></add></ops><time]
    3e31323430353335 3130353c2f74696d 653e3c757365723e 6b656e742e66696e [>1240535105</time><user>kent.fin]
    656c6c3c2f757365 723e3c2f6368616e 67653e3c76657273 696f6e3e30303030 [ell</user></change><version>0000]
    3030303030372c30 3030303030303030 322c333730313437 363237332c303c2f [000007,0000000002,3701476273,0</]
    76657273696f6e3e                                                    [version>]
     */
    user.getPlaylists().getItems().add(new Playlist(Hex.toBytes("fd51193b394298130028850a1a72bb7f"), "jotify2", "kent.finell", false));
    assertEquals(3701476273l, user.getPlaylists().calculateChecksum());


    /*
    3600cd00005710e6 6cde8a35bfa824d5 6f85fdab31020000 000000000000ffff [6????W??l??5??$?o???1???????????]
    ffff01033c69642d 69732d756e697175 652f3e3c6368616e 67653e3c6f70733e [????<id-is-unique/><change><ops>]
    3c6372656174652f 3e3c6e616d653e6a 6f74696679333c2f 6e616d653e3c2f6f [<create/><name>jotify3</name></o]
    70733e3c74696d65 3e31323430353335 3134383c2f74696d 653e3c757365723e [ps><time>1240535148</time><user>]
    6b656e742e66696e 656c6c3c2f757365 723e3c2f6368616e 67653e3c76657273 [kent.finell</user></change><vers]
    696f6e3e30303030 3030303030312c30 3030303030303030 302c303030303030 [ion>0000000001,0000000000,000000]
    303030312c303c2f 76657273696f6e3e                                   [0001,0</version>]

    3600e50000000000 0000000000000000 0000000000000000 000700000002dca0 [6???????????????????????????????]
    0bb100033c636861 6e67653e3c6f7073 3e3c6164643e3c69 3e323c2f693e3c69 [????<change><ops><add><i>2</i><i]
    74656d733e353731 3065363663646538 6133356266613832 3464353666383566 [tems>5710e66cde8a35bfa824d56f85f]
    646162333130323c 2f6974656d733e3c 2f6164643e3c2f6f 70733e3c74696d65 [dab3102</items></add></ops><time]
    3e31323430353335 3134383c2f74696d 653e3c757365723e 6b656e742e66696e [>1240535148</time><user>kent.fin]
    656c6c3c2f757365 723e3c2f6368616e 67653e3c76657273 696f6e3e30303030 [ell</user></change><version>0000]
    3030303030382c30 3030303030303030 332c343035313337 353135382c303c2f [000008,0000000003,4051375158,0</]
    76657273696f6e3e                                                    [version>]
     */
    user.getPlaylists().getItems().add(new Playlist(Hex.toBytes("5710e66cde8a35bfa824d56f85fdab31"), "jotify3", "kent.finell", false));
    assertEquals(4051375158l, user.getPlaylists().calculateChecksum());


  }


}
