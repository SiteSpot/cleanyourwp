<?php
/**
 * Plugin Name: CleanYourWP: Disable XML-RPC
 * Description: Turns off XML-RPC and the pingback header. Must-use plugin.
 */
add_filter( 'xmlrpc_enabled', '__return_false' );
add_filter( 'xmlrpc_methods', '__return_empty_array' );
add_filter( 'wp_headers', function ( $headers ) {
	unset( $headers['X-Pingback'] );
	return $headers;
} );
add_filter( 'bloginfo_url', function ( $output, $show ) {
	return 'pingback_url' === $show ? '' : $output;
}, 10, 2 );
