<?php
/*
 * $Id$
 * Retrieve playlist data
 *
 */

require_once("config.php");
require_once("auth.php");


$id = "";
if(isset($_GET["id"]))
	$id = $_GET["id"];

$key = "";
if(isset($_GET["key"]))
	$key = $_GET["key"];

if(strlen($id) != 40 || strlen($key) != 32)
	die($xml_decl . "<despotify><errorcode>70</errorcode><errormessage>Need parameter 'id' (40 character file ID in hexadecimal notation) and 'key' (same requirements, 32 characters)</errormessage></despotify>");



ob_implicit_flush(TRUE);
$offset = 0;
$blocksize = 81920;
do {
	// Sending: substream 2678bfe49104604c5ef1646dbf72b6ae05d6ff1e 797652 81920 de1967d7a5253b47794f0d36da659db3
	$cmd = "substream $id $offset $blocksize $key\n";
	socket_write($fd, $cmd);
	$hdr = socket_read($fd, 512, PHP_NORMAL_READ);
	sscanf($hdr, "%d %d %s %s", &$errorcode, &$len, &$code, &$errormsg);
	if($errorcode != 200) {
		socket_write($fd, "quit\n");
		socket_close($fd);
		sleep(10);
		die($xml_decl . "<despotify><errorcode>71</errorcode><errormessage>". htmlspecialchars($errormsg) ."</errormessage></despotify>");
	}

	$output = "";
	$nbytes_to_read = $len;
	$nbytes_to_skip = 167;
	if($offset != 0)
		$nbytes_to_skip = 0;
	while($nbytes_to_read > 0) {
		if($nbytes_to_skip > 0) {
			$ret = socket_recv($fd, &$buf, $nbytes_to_skip, 0);
			if($ret <= 0)
				break;
			$nbytes_to_skip -= $ret;
			$nbytes_to_read -= $ret;
			continue;
		}

		$ret = socket_recv($fd, &$buf, $nbytes_to_read, 0);
		if($ret <= 0)
			break;

		$nbytes_to_read -= $ret;
		$output .= $buf;
	}

	$offset += $len;
	echo $output;
	flush();
	ob_flush();

} while($len % $blocksize == 0);
socket_write($fd, "quit\n");
socket_close($fd);
?>
