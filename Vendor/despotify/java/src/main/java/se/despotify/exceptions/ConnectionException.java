package se.despotify.exceptions;

@SuppressWarnings("serial")
public class ConnectionException extends DespotifyException {
	public ConnectionException(String message){
		super(message);
	}
}
