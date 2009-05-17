package se.despotify.domain.media;

import java.util.List;

/**
 * @since 2009-apr-30 09:03:24
 */
public class Biography {

  private String text;
  private List<Image> portraits;

  public String getText() {
    return text;
  }

  public void setText(String text) {
    this.text = text;
  }

  public List<Image> getPortraits() {
    return portraits;
  }

  public void setPortraits(List<Image> portraits) {
    this.portraits = portraits;
  }

  @Override
  public String toString() {
    return "Biography{" +
        "text='" + text + '\'' +
        ", portraits=" + portraits +
        '}';
  }
}
