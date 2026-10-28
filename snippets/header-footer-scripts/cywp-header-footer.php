<?php
/**
 * Plugin Name: CleanYourWP: Header and footer scripts
 * Description: Prints fixed HTML in the head and footer. Edit this file to change it. Must-use plugin.
 */
add_action( 'wp_head', function () {
	echo <<<'HTML'
<!-- CleanYourWP head: put verification meta tags or an analytics loader here -->
HTML;
}, 5 );

add_action( 'wp_footer', function () {
	echo <<<'HTML'
<!-- CleanYourWP footer: put chat widgets or late-loading scripts here -->
HTML;
}, 99 );
