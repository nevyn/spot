package se.despotify.domain.media;

/**
 *
 * @since 2009-apr-20 20:02:01
 */
public interface Visitor {

  public abstract void visit(Album album);
  public abstract void visit(Artist artist);
  public abstract void visit(Playlist playlist);
  public abstract void visit(Track track);
  public abstract void visit(Image image);

}
