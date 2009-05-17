package se.despotify.client.player;

import java.io.ByteArrayInputStream;
import java.io.DataInputStream;
import java.io.IOException;

public class SpotifyOggHeader {
	private int   samples;
	private int   length;
	private int   unknown;
	private int[] table;
	private float gainScale;
	private float gainDb;
	private int[] headerTableDec = new int[]{
		    0,    112,    197,    327,    374,    394,    407,    417,
		  425,    433,    439,    444,    449,    454,    458,    462,
		  466,    470,    473,    477,    480,    483,    486,    489,
		  491,    494,    497,    499,    502,    504,    506,    509,
		  511,    513,    515,    517,    519,    521,    523,    525,
		  527,    529,    531,    533,    535,    537,    538,    540,
		  542,    544,    545,    547,    549,    550,    552,    554,
		  555,    557,    558,    560,    562,    563,    565,    566,
		  568,    569,    571,    572,    574,    575,    577,    578,
		  580,    581,    583,    584,    585,    587,    588,    590,
		  591,    593,    594,    595,    597,    598,    599,    601,
		  602,    604,    605,    606,    608,    609,    610,    612,
		  613,    615,    616,    617,    619,    620,    621,    623,
		  624,    625,    627,    628,    629,    631,    632,    634,
		  635,    636,    638,    639,    640,    642,    643,    644,
		  646,    647,    649,    650,    651,    653,    654,    655,
		  657,    658,    660,    661,    662,    664,    665,    667,
		  668,    669,    671,    672,    674,    675,    677,    678,
		  679,    681,    682,    684,    685,    687,    688,    690,
		  691,    693,    694,    696,    697,    699,    700,    702,
		  704,    705,    707,    708,    710,    712,    713,    715,
		  716,    718,    720,    721,    723,    725,    727,    728,
		  730,    732,    734,    735,    737,    739,    741,    743,
		  745,    747,    748,    750,    752,    754,    756,    758,
		  760,    763,    765,    767,    769,    771,    773,    776,
		  778,    780,    782,    785,    787,    790,    792,    795,
		  797,    800,    803,    805,    808,    811,    814,    817,
		  820,    823,    826,    829,    833,    836,    840,    843,
		  847,    851,    855,    859,    863,    868,    872,    877,
		  882,    887,    893,    898,    904,    911,    918,    925,
		  933,    941,    951,    961,    972,    985,   1000,   1017,
		 1039,   1067,   1108,   1183,   1520,   2658,   4666,   8191
	};
	
	public SpotifyOggHeader(byte[] header){
		/* Try to parse header. If it fails, just set default values. */
		try{
			this.parse(header);
		}
		catch(IOException e){
			this.samples   = 0;
			this.length    = 0;
			this.unknown   = 0;
			this.table     = new int[0];
			this.gainScale = 1.0f;
			this.gainDb    = 0.0f;
		}
	}
	
	/* Total number of samples. */
	public int getSamples(){
		return this.samples;
	}
	
	/* Length in seconds. */
	public int getSeconds(int sampleRate){
		return this.samples / sampleRate;
	}
	
	/* Length in bytes. */
	public int getLength(){
		return this.length;
	}
	
	public float getGainScale() {
		return this.gainScale;
	}
	
	public float getGainDb() {
		return this.gainDb;
	}
	
	/* Swap short bytes. */
	private short swap(short value){
		return  (short)(((value & 0xff  ) << 8) |
						((value & 0xff00) >> 8));
	}
	
	/* Swap integer bytes. */
	private int swap(int value){
		return  ((value & 0xff      ) << 24) |
				((value & 0xff00    ) <<  8) |
				((value & 0xff0000  ) >>  8) |
				((value & 0xff000000) << 24);
	}
	
	/* Parse Spotify header. */
	private void parse(byte[] header) throws IOException {
		/* Get input steam of bytes. */
		DataInputStream input = new DataInputStream(new ByteArrayInputStream(header));
		
		/* Skip OGG page header (length is always 0x1C in this case). */
		input.skip(0x1C);
		
		/* Read Spotify specific data. */
		if(input.read() == 0x81){
			while(input.available() >= 2){
				int blockSize = this.swap(input.readShort());
				
				if(input.available() >= blockSize && blockSize > 0){
					switch(input.read()){
						/* Table lookup */
						case 0: {
							if(blockSize == 0x6e){
								this.samples = this.swap(input.readInt());
								this.length  = this.swap(input.readInt());
								this.unknown = -this.headerTableDec[input.read()];
								this.table   = new int[0x64];
								
								int ack = this.unknown;
								int ctr = 0;
								
								for(int i = 0; i < 0x64; i++){
									ack += this.headerTableDec[input.read()];
									
									this.table[ctr] = ack;
								}
							}
							
							break;
						}
						/* Gain */
						case 1: {
							if(blockSize > 0x10){
								this.gainDb = 1.0f;
								
								int value;
								
								if((value = this.swap(input.readInt())) != -1){
									this.gainDb = Float.intBitsToFloat(value);
								}
								
								if(this.gainDb < -40.0f){
									this.gainDb = 0.0f;
								}
								
								this.gainScale = this.gainDb * 0.05f;
								this.gainScale = (float)Math.pow(10.0, this.gainScale);
							}
							
							break;
						}
					}
				}
			}
		}
	}
}
