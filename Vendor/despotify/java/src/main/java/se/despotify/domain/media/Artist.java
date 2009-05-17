package se.despotify.domain.media;

import se.despotify.domain.Store;
import se.despotify.util.SpotifyURI;
import se.despotify.util.XMLElement;

import java.util.ArrayList;
import java.util.List;
import java.util.Arrays;
import java.util.regex.Pattern;

public class Artist extends Media implements Visitable {
  private String name;
  private Image portrait;
  private Float popularity;
  private List<Artist> similarArtists;
  private List<Biography> biographies;
  private List<String> genres;
  private List<String> yearsActive;
  private List<Album> albums;

  public Artist() {
    super();
  }

  public Artist(byte[] UUID) {
    super(UUID);
  }

  public Artist(byte[] UUID, String hexUUID) {
    super(UUID, hexUUID);
  }

  public Artist(String hexUUID) {
    super(hexUUID);
  }

  @Override
  protected int getUUIDlength() {
    return 16;
  }

  @Override
  protected Pattern getHexUUIDpattern() {
    return hexUUIDpattern32;
  }
  

  @Override
  public void accept(Visitor visitor) {
    visitor.visit(this);
  }

  @Override
  public String getSpotifyURL() {
    return "spotify:artist:" + SpotifyURI.toURI(getUUID());
  }

  @Override
  public String getHttpURL() {
    return "http://open.spotify.com/artist/" + SpotifyURI.toURI(getUUID());
  }

  public String getName() {
    return name;
  }

  public void setName(String name) {
    this.name = name;
  }

  public Image getPortrait() {
    return portrait;
  }

  public void setPortrait(Image portrait) {
    this.portrait = portrait;
  }

  public Float getPopularity() {
    return popularity;
  }

  public void setPopularity(Float popularity) {
    this.popularity = popularity;
  }

  public List<Artist> getSimilarArtists() {
    return similarArtists;
  }

  public void setSimilarArtists(List<Artist> similarArtists) {
    this.similarArtists = similarArtists;
  }

  public List<Biography> getBiographies() {
    return biographies;
  }

  public void setBiographies(List<Biography> biographies) {
    this.biographies = biographies;
  }

  public List<String> getGenres() {
    return genres;
  }

  public void setGenres(List<String> genres) {
    this.genres = genres;
  }

  public List<String> getYearsActive() {
    return yearsActive;
  }

  public void setYearsActive(List<String> yearsActive) {
    this.yearsActive = yearsActive;
  }

  public List<Album> getAlbums() {
    return albums;
  }

  public void setAlbums(List<Album> albums) {
    this.albums = albums;
  }

  public static Artist fromXMLElement(XMLElement artistNode, Store store) {
    Artist artist = store.getArtist(artistNode.getChildText("id"));

    /* Set name. */
    if (artistNode.hasChild("name")) {
      artist.name = artistNode.getChildText("name");
    }

    /* Set portrait. */
    if (artistNode.hasChild("portrait")) {
      XMLElement portraitNode  = artistNode.getChild("portrait");
      if (!"".equals(portraitNode.getText().trim())) {
        artist.portrait = Image.fromXMLElement(portraitNode, store);
      }
    }

    /* Set popularity. */
    if (artistNode.hasChild("popularity")) {
      artist.popularity = Float.parseFloat(artistNode.getChildText("popularity"));
    }

    XMLElement biosNode = artistNode.getChild("bios");
    if (biosNode != null) {

      List<Biography> biographies = new ArrayList<Biography>();

      for (XMLElement bioNode : biosNode.getChildren()) {
        if (!"bio".equals(bioNode.getElement().getNodeName())) {
          log.warn("Unknown bios child node " + bioNode.getElement().getNodeName());
        } else {
          Biography biography = new Biography();
          biography.setText(bioNode.getChildText("text"));
          if (bioNode.hasChild("portraits")) {
            biography.setPortraits(new ArrayList<Image>());
            for (XMLElement portraitNode : bioNode.getChild("portraits").getChildren()) {
              biography.getPortraits().add(Image.fromXMLElement(portraitNode, store));
            }
          }
          biographies.add(biography);
        }
        artist.biographies = biographies;
      }
    }

    if (artistNode.hasChild("years-active")) {
      artist.yearsActive = new ArrayList<String>(Arrays.asList(artistNode.getChildText("years-active").split(",")));
    }

    if (artistNode.hasChild("genres")) {
      artist.genres = new ArrayList<String>(Arrays.asList(artistNode.getChildText("genres").split(",")));
    }

    XMLElement albumsNode = artistNode.getChild("albums");
    if (albumsNode != null) {
      List<Album> albums = new ArrayList<Album>();
      for (XMLElement albumNode : albumsNode.getChildren())  {
        albums.add(Album.fromXMLElement(albumNode, store));
      }
      artist.albums = albums;
    }

    /* Set similar artists. */
    if (artistNode.hasChild("similar-artists")) {

      List<Artist> similarArtists = new ArrayList<Artist>();

      for (XMLElement similarArtistElement : artistNode.getChild("similar-artists").getChildren()) {
        similarArtists.add(Artist.fromXMLElement(similarArtistElement, store));
      }

      artist.setSimilarArtists(similarArtists);
    }


    return artist;
  }


  public static Artist fromURI(String uri) {
    Artist artist = new Artist();

    artist.setUUID(SpotifyURI.toHex(uri));

    return artist;
  }

  @Override
  public String toString() {
    return "Artist{" +
        "id='" + getHexUUID() + '\'' +
        ", name='" + name + '\'' +
        ", portrait='" + portrait + '\'' +
        ", popularity=" + popularity +
        ", similarArtists=" + (similarArtists == null ? null : similarArtists.size()) +
        '}';
  }
}
