<?php

class Despotify {
	public $socket;
	private $sessionid;
	private $loggedin;
	private $gateway;
	private $port;

	public $error;
	public $errorcode;

	function __construct($gateway, $port) {
		$this->gateway = $gateway;
		$this->port = $port;
	}

	function connect() {
		$this->socket = socket_create(AF_INET, SOCK_STREAM, SOL_TCP);
		if((@socket_connect($this->socket, $this->gateway, $this->port)) === FALSE) {
			$this->errorcode = socket_last_error();
			$this->error = socket_strerror($this->errorcode);
			unset($this->socket);
			return false;
		}
		return true;
	}
	private function sock_connected() {
		if (! $this->socket) {
			$this->errorcode = socket_last_error();
			$this->error = socket_strerror($this->errorcode);
			return false;
		}
		return true;
	}
	private function sock_get_header() {
		$hdr = socket_read($this->socket, 512, PHP_NORMAL_READ);
                sscanf($hdr, "%d %d %s %s", &$errorcode, &$len, &$code, &$errormsg);
		if ($errorcode != 200) {
			$this->error = $errormsg;
			$this->errorcode = $errorcode;
			return false;
		}

		return $len;
	}
	private function sock_read($len) {
		$output = "";
        	$nbytes_to_read = $len;

        	while($nbytes_to_read > 0) {
                	$ret = socket_recv($this->socket, &$buf, $nbytes_to_read, 0);
                	if($ret <= 0)
                       		break;

              		$nbytes_to_read -= $ret;
                	$output .= $buf;
		}

		return $output;
	}

	function substream($file, $offset, $blocksize, $key) {
		socket_write($this->socket, sprintf("substream %40s %u %u %32s\n", $file, $offset, $blocksize, $key));
		if (($len = $this->sock_get_header()) === FALSE)
			return false;

		$rlen = $len;

		if ($offset == 0) {
			$skip = $this->sock_read(167);
			$rlen -= 167;
		}
		$data = $this->sock_read($rlen);
		return array($len, $data);
	}

	function auth($username, $password) {
		if (! $this->sock_connected())
			return false;

		socket_write($this->socket, sprintf("login %.20s %.20s\n", $username, $password));
		if (($len = $this->sock_get_header()) === FALSE)
			return false;

		socket_write($this->socket, "id\n");
                if (($len = $this->sock_get_header()) === FALSE) 
                        return false;

		$this->sessionid = $this->sock_read($len);

		return $this->sessionid;
	}
	function loggedin() {
		if ($this->sessionid != '') {
			return TRUE;
		}
		return FALSE;
	}
	function session($sessionid) {
		if (! $this->sock_connected()) 
			return false;

		socket_write($this->socket, sprintf("session %s\n", $sessionid));
                if (($len = $this->sock_get_header()) === FALSE) 
                        return false;

		$this->sessionid = $sessionid;
		return true;
	}
	function key($fileid,$trackid) {
		if (! $this->sock_connected()) 
			return false;

		$fileid = substr(trim($fileid), 0, 40);
		$trackid = substr(trim($trackid), 0, 32);
	
		socket_write($this->socket, "key ".$fileid." ".$trackid."\n");
                if (($len = $this->sock_get_header()) === FALSE) 
                        return false;

		$output = $this->sock_read($len);
		$output = str_replace("\0", '', $output);
		$xml = new SimpleXMLElement($output);

		$key = (array)$xml->xpath("/filekey/key");
		
		return $key[0];
	}
	function image($imageid) {
		if (! $this->sock_connected()) 
			return false;

		$imageid = substr(trim($imageid), 0, 40);
	
		socket_write($this->socket, "image ".$imageid."\n");
                if (($len = $this->sock_get_header()) === FALSE) 
                        return false;

		$output = $this->sock_read($len);
		return $output;
	}
	function search($string) {
		if (! $this->sock_connected()) 
			return false;

		socket_write($this->socket, "search ".$string."\n");
                if (($len = $this->sock_get_header()) === FALSE) 
                        return false;

		$output = $this->sock_read($len);

		$xml = new SimpleXMLElement($output);

		$items = $xml->xpath("/result/total-tracks");
		$return['trackcount'] = (int)$items[0][0];

		$items = $xml->xpath("/result/total-albums");
		$return['albumcount'] = (int)$items[0][0];

		$items = $xml->xpath("/result/total-artists");
		$return['artistcount'] = (int)$items[0][0];

		$items = $xml->xpath("/result/artists/artist");
		while ( $node = each($items)) {
			$artist = array();
			$arr = (array)$node[1];
			$artist['id'] = $arr['id'];
			$artist['name'] = $arr['name'];

			$return['artists'][] = $artist;
		}

		$items = $xml->xpath("/result/albums/album");
		while ( $node = each($items)) {
			$album = array();
			$arr = (array)$node[1];
			$album['id'] = $arr['id'];
			$album['name'] = $arr['name'];
			$album['artistid'] = $arr['artist-id'];
			$album['artistname'] = $arr['artist-name'];
			$album['images'][] = $arr['cover'];

			$return['albums'][] = $album;
		}

		$items = $xml->xpath("/result/tracks/track");
		while ( $node = each($items)) {
			$track = array();
			$arr = (array)$node[1];
			$track['id'] = $arr['id'];
			$track['redirect'] = $arr['redirect'];
			$track['title'] = $arr['title'];
			$track['artistid'] = $arr['artist-id'];
			$track['artist'] = $arr['artist'];
			$track['album'] = $arr['album'];
			$track['albumid'] = $arr['album-id'];
			$track['year'] = $arr['year'];
			$track['tracknumber'] = $arr['track-number'];
			$track['length'] = $arr['length'];
			$track['cover'] = $arr['cover'];

			$return['tracks'][] = $track;
		}

		return $return;
	}
	function playlists() {
		if (! $this->sock_connected()) 
			return false;

		$playlist = "0000000000000000000000000000000000";
		socket_write($this->socket, "playlist ".$playlist."\n");
                if (($len = $this->sock_get_header()) === FALSE) 
                        return false;

		$output = $this->sock_read($len);

		$xml = new SimpleXMLElement($output);
		$items = $xml->xpath("/playlist/next-change/change/ops/add/items");
		$items = explode(",", $items[0][0]);
			
		return $items;
	}
	function playlist($playlist = '') {
		if (! $this->sock_connected()) 
			return false;

		$playlist = trim($playlist);
		if ($playlist == '') {
			$playlist = "0000000000000000000000000000000000";
		}
		socket_write($this->socket, "playlist ".$playlist."\n");
                if (($len = $this->sock_get_header()) === FALSE) 
                        return false;

		$output = $this->sock_read($len);
		$xml = new SimpleXMLElement($output);

		$user = $xml->xpath("/playlist/next-change/change/user");
		$user = $user[0][0];

		$name = $xml->xpath("/playlist/next-change/change/ops/name");
		$name = $name[0][0];

		$items = $xml->xpath("/playlist/next-change/change/ops/add/items");
		$items = explode(",", $items[0][0]);

		$return['name'] = $name;
		$return['user'] = $user;
		$return['items'] = $items;
		$return['itemcount'] = count($items);

		return $return;
	}
	function browseartist($artistid) {
		if (! $this->sock_connected()) 
			return false;

		$artistid = substr(trim($artistid),0,32);

		$info = array();

		socket_write($this->socket, "browseartist $artistid\n");
	        if (($len = $this->sock_get_header()) === FALSE) 
        		return false;

		$return = $this->sock_read($len);
		$xml = new SimpleXMLElement($return);

		$info['artistid'] = $artistid;
	
		$str = $xml->xpath("/artist/name");
		$info['artistname'] = utf8_decode($str[0]);

		$str = $xml->xpath("/artist/bios/bio/text");
		$info['biography'] = preg_replace("/\n/", "<br>", utf8_decode($str[0]));

		$str = $xml->xpath("/artist/portrait/id");
		if ($str) {
			$info['images'][] = utf8_decode($str[0]);
		}

		$str = $xml->xpath("/artist/bios/bio/portraits/portrait/id");
		while ( $node = each($str)) {
			if ($info['images'][0] != utf8_decode($node[1]))
				$info['images'][] = utf8_decode($node[1]);
		}
		
		return $info;
	}

	function browsetrack($trackids) {
		if (! $this->sock_connected()) 
			return false;

		$tmp_tracks = "";
		$counter = 0;
		$global_counter = 0;

		$tracks = array();
		$trackidlist = array();
		if (is_array($trackids)) {
			$trackidlist = $trackids;
		}
		else {
			$trackidlist[] = $trackids;
		}
		for ($i=0; $i<count($trackidlist); $i++) {
			if (strlen($trackidlist[$i]) % 32 != 0) {
				$this->error = "track ids must be 32 chars each";
				$this->errorcode = 9;
				return false;
			}

			$tracknum .= $trackidlist[$i];
			$counter += 1;
			if ($counter % 128 == 0 || $counter == count($trackidlist)) {
				socket_write($this->socket, "browsetrack $tracknum\n");
	        		if (($len = $this->sock_get_header()) === FALSE) 
        				return false;
				$return = $this->sock_read($len);

				$tracknum = "";
				$xml = new SimpleXMLElement($return);

				$info = array();
				
				$items = $xml->xpath("/result/tracks/track");
				while ($node = each($items)) {	
					$track = array();
					$arr = (array)$node[1];
					$track['trackid'] = $arr['id'];
					$track['title'] = $arr['title'];
					$track['artistid'] = $arr['artist-id'];
					$track['artist'] = $arr['artist'];
					$track['album'] = $arr['album'];
					$track['albumid'] = $arr['album-id'];
					$track['year'] = $arr['year'];
					$track['tracknumber'] = $arr['track-number'];
					$track['length'] = $arr['length'];
					$track['spotifyuri'] = "spotify:track:".$this->idtouri($track['trackid']);

					$file = (array)$arr['files'];
					if ($file) {
						$track['fileid'] = (string)$file['file']->attributes()->id;
						$track['fileformat'] = (string)$file['file']->attributes()->format;
					}

					$tracks[] = $track;
				}
			}
		}
		return $tracks;
	}

	function disconnect() {
		socket_write($this->socket, "quit\n");
		socket_close($this->socket);
	}


	function uritoid($uri) {
		return str_pad($this->s_base_convert($uri, 62, 16), 32, '0', STR_PAD_LEFT);
	}
	function idtouri($id) {
		return str_pad($this->s_base_convert($id, 16,62), 22, '0', STR_PAD_LEFT);
	}
	function sessionid() {
		return $this->sessionid;
	}

	private function s_base_convert ($numstring, $frombase, $tobase) {
   		$chars = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ";
   		$tostring = substr($chars, 0, $tobase);

   		$length = strlen($numstring);
   		$result = '';
   		for ($i = 0; $i < $length; $i++) {
       			$number[$i] = strpos($chars, $numstring{$i});
   		}
   		do {
       			$divide = 0;
       			$newlen = 0;
       			for ($i = 0; $i < $length; $i++) {
           			$divide = $divide * $frombase + $number[$i];
           			if ($divide >= $tobase) {
               				$number[$newlen++] = (int)($divide / $tobase);
               				$divide = $divide % $tobase;
           			} elseif ($newlen > 0) {
               				$number[$newlen++] = 0;
           			}
       			}
       			$length = $newlen;
       			$result = $tostring{$divide} . $result;
   		}
   		while ($newlen != 0);
   		return $result;
	}
	private function print_r_html($array) {
		echo "<pre>";
		print_r($array);
		echo "</pre>";
	}
	private function parse_album_info($input) {
		$xml = new SimpleXMLElement($input);
		$albums = $xml->xpath("/album");
		$return = array();
		while ( $node = each($albums)) {
			$itm = (array)$node[1];
			$item = array();

			$item['name'] = utf8_decode($itm['name']);
			$item['id'] = utf8_decode($itm['id']);
			$item['artist'] = utf8_decode($itm['artist']);
			$item['artistid'] = utf8_decode($itm['artist-id']);
			$item['year'] = utf8_decode($itm['year']);
			if ($itm['cover'] != '') {
				#$item['images'][] = utf8_decode($itm['cover']);
			}
			$item['review'] = $itm['review'];

			$item['tracks'] = $this->parse_album_tracks($input);
		}
		return $item;
	}
	private function parse_album_tracks($input) {
		$xml = new SimpleXMLElement($input);
		$items = $xml->xpath("/album/discs/disc");
		$tracks = array();
		while ($item = each($items)) {
			$item = (array)$item[1];
			$discnumber = $item['disc-number'];
			$trackinfo = (array)$item['track'];
			foreach ($trackinfo as $trackitem) {
				$trackitem = (array)$trackitem;
				$trackid = $trackitem['track-number'];
				$tracks[$discnumber][$trackid]['id'] = $trackitem['id'];
				$tracks[$discnumber][$trackid]['title'] = $trackitem['title'];
				$tracks[$discnumber][$trackid]['artistid'] = $trackitem['artist-id'];
				$tracks[$discnumber][$trackid]['artist'] = $trackitem['artist'];
				$tracks[$discnumber][$trackid]['tracknumber'] = $trackitem['track-number'];
				$tracks[$discnumber][$trackid]['length'] = $trackitem['length'];

				$files = (array)$trackitem['files'];
				$tracks[$discnumber][$trackid]['fileid'] = (string)$files['file']->attributes()->id;
				$tracks[$discnumber][$trackid]['fileformat'] = (string)$files['file']->attributes()->format;
			}
		}
		return $tracks;
	}

	function browsealbum($albumid) {
		if (! $this->sock_connected()) 
			return false;

		$info = array();

		$albumid = substr(trim($albumid),0,32);
		
		socket_write($this->socket, "browsealbum $albumid\n");
	        if (($len = $this->sock_get_header()) === FALSE) 
        		return false;

		$return = $this->sock_read($len);
		$albums = $this->parse_album_info($return);
		return $albums;
		$xml = new SimpleXMLElement($return);

		$info = array();

		$info['trackid'] = $trackid;

		$title = $xml->xpath("/result/tracks/track/title");
		$info['title'] = utf8_decode($title[0]);

		$artistid = $xml->xpath("/result/tracks/track/artist-id");
		$info['artistid'] = utf8_decode($artistid[0]);

		$artist = $xml->xpath("/result/tracks/track/artist");
		$info['artist'] = utf8_decode($artist[0]);

		$album = $xml->xpath("/result/tracks/track/album");
		$info['album'] = utf8_decode($album[0]);

		$albumid = $xml->xpath("/result/tracks/track/album-id");
		$info['albumid'] = utf8_decode($albumid[0]);

		$year = $xml->xpath("/result/tracks/track/year");
		$info['year'] = utf8_decode($year[0]);

		$tracknumber = $xml->xpath("/result/tracks/track/track-number");
		$info['tracknumber'] = utf8_decode($tracknumber[0]);

		$length = $xml->xpath("/result/tracks/track/length");
		$info['length'] = utf8_decode($length[0]);

		$file = $xml->xpath("/result/tracks/track/files/file");
		$info['file'] = $file['id'];

		$info['spotifyuri'] = "spotify:track:".$this->idtouri($trackid);

		return $info;
	}
}

?>
