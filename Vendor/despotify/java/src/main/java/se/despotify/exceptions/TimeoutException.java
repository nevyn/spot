package se.despotify.exceptions;

public class TimeoutException extends RuntimeException {

  public TimeoutException(long milliseconds) {
    super("After " + milliseconds + " milliseconds");
  }

  public TimeoutException() {
    super();
  }

  public TimeoutException(String s) {
    super(s);
  }

  public TimeoutException(String s, Throwable throwable) {
    super(s, throwable);
  }

  public TimeoutException(Throwable throwable) {
    super(throwable);
  }
}
