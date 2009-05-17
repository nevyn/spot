package se.despotify.util;

import org.w3c.dom.Document;
import org.xml.sax.InputSource;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import java.io.*;
import java.nio.charset.Charset;

public class XML {

  protected static Logger log = LoggerFactory.getLogger(XML.class);


  public static XMLElement load(Reader xml) {

    long started = System.currentTimeMillis();

    /* Document and elements */
    DocumentBuilder documentBuilder = null;
    Document document = null;

    /* Create document. */
    try {
      documentBuilder = DocumentBuilderFactory.newInstance().newDocumentBuilder();
      document = documentBuilder.parse(new InputSource(xml));
    }
    catch (Exception e) {
      return null;
    }

    /* Return root element. */
    XMLElement root = new XMLElement(document.getDocumentElement());


    if (log.isDebugEnabled()) {
      long millisecondsSpent = System.currentTimeMillis() - started;
      log.debug(millisecondsSpent + " milliseconds spent creating DOM tree from input XML.");
    }


    return root;
  }

  public static XMLElement load(File xml) throws FileNotFoundException {
    return load(new FileReader(xml));
  }

  public static XMLElement load(String xml) {
//    try {
//      Writer w = new OutputStreamWriter(new FileOutputStream(new File(System.currentTimeMillis() + ".xml")), "UTF8");
//      w.write(xml);
//      w.close();
//    } catch (Exception e) {
//      //
//    }
    return load(new StringReader(xml));
  }

  public static XMLElement load(byte[] xml, Charset charset) {
    return load(new String(xml, charset));
  }
}
