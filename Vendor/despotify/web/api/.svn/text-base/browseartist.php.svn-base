<?php
/*
 * $Id$
 * Browse artist meta data
 *
 */

require_once("config.php");
require_once("auth.php");


$id = "";
if(isset($_GET["id"]))
	$id = $_GET["id"];

/* Verify input */
if(strlen($id) != 32 || !preg_match("/[0-9a-f]{32}/", $id))
	die($xml_decl . "<despotify><errorcode>30</errorcode><errormessage>Need parameter 'id' (16 bytes artist ID in hexadecimal notation)</errormessage></despotify>");


socket_write($fd, "browseartist $id\n");
$hdr = socket_read($fd, 512, PHP_NORMAL_READ);
sscanf($hdr, "%d %d %s %s", &$errorcode, &$len, &$code, &$errormsg);
if($errorcode != 200) {
	socket_write($fd, "quit\n");
	socket_close($fd);
	die($xml_decl . "<despotify><errorcode>31</errorcode><errormessage>". htmlspecialchars($errormsg) ."</errormessage></despotify>");
}

$output = socket_read($fd, $len);
socket_write($fd, "quit\n");
socket_close($fd);

echo $output;


?>
