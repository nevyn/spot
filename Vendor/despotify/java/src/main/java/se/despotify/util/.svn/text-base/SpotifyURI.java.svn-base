package se.despotify.util;

import java.util.regex.Pattern;

public class SpotifyURI {

  private static Pattern hexPattern = Pattern.compile("^[0-9a-fA-F]{32}$");
  public static boolean isHex(String value) {
    return hexPattern.matcher(value).matches();
  }  

	public static String toHex(String uri){
		StringBuffer hex = new StringBuffer(baseConvert(uri, 62, 16));

		while(hex.length() < 32){
			hex.insert(0, '0');
		}

		return hex.toString();
	}

  public static String toURI(byte[] UUID) {
    if (UUID.length != 16) {
      throw new IllegalArgumentException("UUID should be 16 bytes");
    }
    return toURI(Hex.toHex(UUID));
  }

	public static String toURI(String hex){
		StringBuffer uri = new StringBuffer(baseConvert(hex, 16, 62));
		
		while(uri.length() < 22){
			uri.insert(0, '0');
		}
		
		return uri.toString();
	}

	private static String baseConvert(String source, int from, int to) {
		String chars  = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ";
		String result = "";
		int    length = source.length();
		int[]  number = new int[length];
		
		for(int i = 0; i < length; i++){
			number[i] = chars.indexOf(source.charAt(i));
		}

		int divide;
		int newlen;

		do{
			divide = 0;
			newlen = 0;

			for (int i = 0; i < length; i++){
				divide = divide * from + number[i];

				if(divide >= to){
					number[newlen++] = (int)(divide / to);
					divide = divide % to;
				}
				else if(newlen > 0){
					number[newlen++] = 0;
				}
			}
			
			length = newlen;
			result = chars.charAt(divide) + result;
		}
		while(newlen != 0);
		
		return result;
	}
}
