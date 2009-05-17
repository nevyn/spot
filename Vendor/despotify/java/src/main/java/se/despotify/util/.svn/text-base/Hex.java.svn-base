package se.despotify.util;

import org.slf4j.Logger;

import java.nio.charset.Charset;

public class Hex {
  /* Safe with leading zeroes (unlike BigInteger) and with negative byte values (unlike Byte.parseByte). */
  public static byte[] toBytes(String hex) {
    if (hex.length() % 2 != 0) {
      throw new IllegalArgumentException("Input string must contain an even number of characters");
    }

    byte[] bytes = new byte[hex.length() / 2];

    for (int i = 0; i < hex.length(); i += 2) {
      bytes[i / 2] = (byte) (
          (Character.digit(hex.charAt(i), 16) << 4) +
              Character.digit(hex.charAt(i + 1), 16)
      );
    }

    return bytes;
  }

  public static String toHex(byte[] bytes) {
    String hex = "";

    for (int i = 0; i < bytes.length; i++) {
      hex += String.format("%02x", bytes[i]);
    }

    return hex;
  }

  private static final Charset ISO88591 = Charset.forName("ISO8859-1");


  public static String log(byte[] packet, Logger log) {
    return log(packet, 0, packet.length, log);
  }

  public static String log(byte[] packet, int offset, int length, Logger log) {


    int maxLength = log.isDebugEnabled() ? length : 1024;

    StringBuilder sb = new StringBuilder(Math.min(maxLength * 5, length * 4));

    sb.append("    1   3    5  7   |9   11  13  15  |17  19  21  23  |25  27  29  31  |           1111111112222222222333\n");
    sb.append("      2   4   6   8 |  10  12  14  16|  18  20  22  24|  26  28  31  32| 12345678901234567890123456789012\n");
    sb.append("    ----------------|----------------|----------------|----------------|----------------------------------\n");

    int lineIndex = 0;
    int groupLineIndex = 0;
    int lineByteIndex = 0;
    int lineStartByteIndex = offset;

    byte[] tmp = new byte[1];
    int index;
    sb.append("    ");
    for (index = offset; index < offset + length; index++) {
      tmp[0] = packet[index];
      sb.append(Hex.toHex(tmp));
      if (++groupLineIndex == 8) {
        groupLineIndex = 0;
        sb.append(" ");

        if (++lineIndex == 4) {
          lineIndex = 0;
          sb.append("[");
          for (int i = lineStartByteIndex; i < lineStartByteIndex + lineByteIndex + 1; i++) {
            sb.append(format(packet[i]));
          }
//          sb.append(new String(packet, lineStartByteIndex, lineByteIndex + 1, ISO88591));
          sb.append("]\n    ");
          lineByteIndex = -1;
          lineStartByteIndex = index + 1;
          if (!log.isDebugEnabled()) {
            if (index >= maxLength) {
              sb.append("[trunkated]\n");
              break;
            }
          }
        }
      }
      lineByteIndex++;
    }

    // final
    if (lineByteIndex > 0) {
      for (int skipped = lineByteIndex; skipped < 8 * 4; skipped++) {
        sb.append("  ");
        if (++groupLineIndex == 8) {
          groupLineIndex = 0;
          sb.append(" ");

          if (++lineIndex == 4) {
            lineIndex = 0;
          }
        }
      }
      sb.append("[");
//      sb.append(new String(packet, lineStartByteIndex, lineByteIndex, ISO88591));
      for (int i = lineStartByteIndex; i < lineStartByteIndex + lineByteIndex; i++) {
        sb.append(format(packet[i]));
      }
      sb.append("]\n");
    }


    return sb.toString();
  }

  public static String format(byte b) {
    if (b > 0x1f && b < 0x7f) {
      return new String(new byte[]{b}, ISO88591);
    } else {
      return "?";
    }
  }

}
