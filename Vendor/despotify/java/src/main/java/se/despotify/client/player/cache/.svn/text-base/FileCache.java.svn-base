package se.despotify.client.player.cache;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;

public class FileCache implements Cache {
	private File directory;
	
	public FileCache(){
		this(new File(System.getProperty("user.home") + "/.despotify-cache"));
	}

	public FileCache(File directory){
		this.directory = directory;
		
		if(!this.directory.exists()){
			this.directory.mkdirs();
		}
	}
	
	public void clear(){
		for(File file : this.directory.listFiles()){
			file.delete();
		}
	}
	
	public void clear(String category){
		File directory = new File(this.directory, category);
		
		for(File file : directory.listFiles()){
			if(file.isFile()){
				file.delete();
			}
		}
	}
	
	public boolean contains(String category, String hash){		
		return new File(this.directory, category + "/" + hash).exists();
	}
	
	public byte[] load(String category, String hash){
		try{
			File            file  = new File(this.directory, category + "/" + hash);
			FileInputStream input = new FileInputStream(file);
			byte[]          data  = new byte[(int)file.length()];
			
			input.read(data);
			input.close();
			
			return data;
		}
		catch(IOException e){
			return null;
		}
	}
	
	public void remove(String category, String hash){
		new File(this.directory, category + "/" + hash).delete();
	}
	
	public void store(String category, String hash, byte[] data){
		try{
			File file = new File(this.directory, category + "/" + hash);

      File directory = file.getParentFile();
			if(!directory.exists() && ! directory.mkdirs()) {
        throw new RuntimeException("Could not create directory " + directory.getAbsolutePath());
			}
			
			FileOutputStream output = new FileOutputStream(file);
			
			output.write(data);
			output.close();
		} 
		catch(IOException e){
			/* Ignore. */
		}
	}
}
