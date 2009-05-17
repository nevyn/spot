<?php
/*
 * $Id$
 * Search requests
 *
 */

require_once("config.php");
require_once("auth.php");


$q = "";
if(isset($_GET["q"]))
	$q = $_GET["q"];

/* Verify input */
if(strlen($q) == 0)
	die($xml_decl . "<despotify><errorcode>20</errorcode><errormessage>Need parameter 'q' (searchtext)</errormessage></despotify>");


socket_write($fd, sprintf("search %.40s\n", $q));
$hdr = socket_read($fd, 512, PHP_NORMAL_READ);
sscanf($hdr, "%d %d %s %s", &$errorcode, &$len, &$code, &$errormsg);
if($errorcode != 200 || $len == 0) {
	socket_write($fd, "quit\n");
	socket_close($fd);
	die($xml_decl . "<despotify><errorcode>21</errorcode><errormessage>". htmlspecialchars($errormsg . ", len=$len") ."</errormessage></despotify>");
}

$output = socket_read($fd, $len);
socket_write($fd, "quit\n");
socket_close($fd);

echo $output;

?>
