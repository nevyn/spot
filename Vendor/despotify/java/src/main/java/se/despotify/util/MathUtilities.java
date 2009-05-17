package se.despotify.util;

public class MathUtilities {
	public static float map(float value, float imin, float imax, float omin, float omax){
		return omin + (omax - omin) * ((value - imin) / (imax - imin));
	}
	
	public static float constrain(float value, float min, float max){
		return Math.max(Math.min(value, max), min);
	}
}
