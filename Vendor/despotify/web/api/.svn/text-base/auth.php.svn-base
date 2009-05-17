<?php
/*
 * $Id$
 * Connect to backend (the gateway) and authenticate
 *
 */

require_once("config.php");


/*
 * Initialize common variables
 *
 */
$session = 0;
if(isset($_GET["session"]))
	$session = $_GET["session"];


/*
 * Connect to backend
 *
 */

$fd = socket_create(AF_INET, SOCK_STREAM, SOL_TCP);
if((@socket_connect($fd, $gw_host, $gw_port)) === FALSE) {
	socket_close($fd);
	die($xml_decl . '<despotify><errorcode>2</errorcode><errormessage>Backend connect failed</errormessage></despotify>');
}


if($session == 0) {
	/*
	 * Bail out unless we got the required parameters
	 *
	 */
 	if(!isset($_GET["user"]) || !isset($_GET["pass"]))
		die($xml_decl
			."<despotify><errorcode>3</errorcode><errormessage>Not logged in, need parameters 'user' and 'pass'</errormessage></despotify>");


	/*
	 * Try to login using the user and pass provided
	 *
	 */
	socket_write($fd, sprintf("login %.20s %.20s\n", $_GET["user"], $_GET["pass"]));
	$hdr = socket_read($fd, 512, PHP_NORMAL_READ);
	sscanf($hdr, "%d", &$errorcode);
	if($errorcode != 200) {
		socket_write($fd, "quit\n");
		socket_close($fd);
		die($xml_decl . "<despotify><errorcode>4</errorcode><errormessage>Login failed</errormessage></despotify>");
	}


	/*
	 * Report session ID and exit
	 *
	 */
	socket_write($fd, "id\n");
	$hdr = socket_read($fd, 512, PHP_NORMAL_READ);
	sscanf($hdr, "%d %d", &$errorcode, &$len);
	$output = socket_read($fd, $len);
	die($xml_decl . "<despotify><errorcode>0</errorcode><session>". $output ."</session></despotify>");
}
else {
	/*
	 * Try to hook up to an existing connection
	 *
	 */
	socket_write($fd, sprintf("session %s\n", $session));
	$hdr = socket_read($fd, 512, PHP_NORMAL_READ);
	sscanf($hdr, "%d %d %s %[^\n]", &$errorcode, &$len, &$status, &$output);
	if($errorcode != 200) {
		socket_write($fd, "quit\n");
		socket_close($fd);
		die($xml_decl . "<despotify><errorcode>6</errorcode><errormessage>". htmlspecialchars($output, ENT_NOQUOTES) ."</errormessage></despotify>");
	}

}

?>
