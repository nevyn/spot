package se.despotify.exceptions;

import se.despotify.util.XMLElement;

/**
 * @since 2009-maj-04 21:56:52
 */
public class MissingChildElement extends DespotifyException {

  public MissingChildElement(XMLElement parent, String child) {
    super("Missing child <" + child +"> in parent node <" + parent.getElement().getNodeName() + ">");
  }

}
