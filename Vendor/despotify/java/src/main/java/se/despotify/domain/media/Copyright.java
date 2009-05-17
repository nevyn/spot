package se.despotify.domain.media;

/**
 * @since 2009-maj-05 19:20:07
 */
public class Copyright {

  private String c;
  private String p;


  public String getC() {
    return c;
  }

  public void setC(String c) {
    this.c = c;
  }

  public String getP() {
    return p;
  }

  public void setP(String p) {
    this.p = p;
  }

  @Override
  public String toString() {
    return "Copyright{" +
        "c='" + c + '\'' +
        ", p='" + p + '\'' +
        '}';
  }
}
