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

if($id == "*")
	$id = "0000000000000000000000000000000000";

/* Verify input */
if(strlen($id) != 34 || !preg_match("/[0-9a-f]{34}/", $id))
	die($xml_decl . "<despotify><errorcode>10</errorcode><errormessage>Need parameter 'id' (17 bytes playlist ID in hexadecimal notation)</errormessage></despotify>");




socket_write($fd, "playlist $id\n");
$hdr = socket_read($fd, 512, PHP_NORMAL_READ);
sscanf($hdr, "%d %d %s %s", &$errorcode, &$len, &$code, &$errormsg);
if($errorcode != 200) {
	socket_write($fd, "quit\n");
	socket_close($fd);
	die($xml_decl . "<despotify><errorcode>11</errorcode><errormessage>". htmlspecialchars($errormsg) ."</errormessage></despotify>");
}

$output = socket_read($fd, $len);
socket_write($fd, "quit\n");
socket_close($fd);

echo $output;


?>
