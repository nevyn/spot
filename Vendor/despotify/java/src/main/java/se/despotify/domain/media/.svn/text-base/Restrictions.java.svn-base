package se.despotify.domain.media;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import se.despotify.util.XMLElement;

import java.util.Arrays;
import java.util.LinkedHashSet;
import java.util.Set;

/**
 * @since 2009-apr-30 08:31:26
 */
public class Restrictions {

  protected static Logger log = LoggerFactory.getLogger(Restrictions.class);


  /**
   * AT,BE,CH,CN,CZ,DK,ES,FI,GB,HK,HU,IE,IL,IN,IT,MY,NL,NO,NZ,PL,PT,RU,SE,SG,SK,TR,TW,ZA
   */
  private Set<String> allowed;

  /**
   * AT,BE,CH,CN,CZ,DK,ES,FI,GB,HK,HU,IE,IL,IN,IT,MY,NL,NO,NZ,PL,PT,RU,SE,SG,SK,TR,TW,ZA
   */
  private Set<String> forbidden;

  /**
   * free,daypass,premium
   */
  private Set<String> catalogues;

  public Set<String> getAllowed() {
    return allowed;
  }

  public void setAllowed(Set<String> allowed) {
    this.allowed = allowed;
  }

  public Set<String> getCatalogues() {
    return catalogues;
  }

  public void setCatalogues(Set<String> catalogues) {
    this.catalogues = catalogues;
  }

  public Set<String> getForbidden() {
    return forbidden;
  }

  public void setForbidden(Set<String> forbidden) {
    this.forbidden = forbidden;
  }

  public static Restrictions fromXMLElement(XMLElement restrictionsNode) {
    Restrictions restrictions = new Restrictions();


    String tmp;
    if ((tmp = restrictionsNode.getAttribute("allowed")) != null) {
      restrictions.setAllowed(new LinkedHashSet<String>(Arrays.asList(tmp.split(","))));
    }
    if ((tmp = restrictionsNode.getAttribute("forbidden")) != null) {
      restrictions.setForbidden(new LinkedHashSet<String>(Arrays.asList(tmp.split(","))));
    }
    if ((tmp = restrictionsNode.getAttribute("catalouges")) != null) {
      restrictions.setCatalogues(new LinkedHashSet<String>(Arrays.asList(tmp.split(","))));
    }

    // todo enumarate all attributes and warn if there are any unknown

    return restrictions;
  }

  @Override
  public String toString() {
    return "Restrictions{" +
        "allowed=" + allowed +
        ", forbidden=" + forbidden +
        ", catalogues=" + catalogues +
        '}';
  }
}
