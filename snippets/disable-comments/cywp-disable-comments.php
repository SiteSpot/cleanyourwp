<?php
/**
 * Plugin Name: CleanYourWP: Disable comments
 * Description: Turns comments off everywhere. Must-use plugin; copy to wp-content/mu-plugins/.
 */
add_action( 'init', function () {
	foreach ( get_post_types() as $type ) {
		remove_post_type_support( $type, 'comments' );
		remove_post_type_support( $type, 'trackbacks' );
	}
}, 100 );
add_filter( 'comments_open', '__return_false', 20 );
add_filter( 'pings_open', '__return_false', 20 );
add_filter( 'comments_array', '__return_empty_array', 20 );
add_filter( 'feed_links_show_comments_feed', '__return_false' );
add_filter( 'rest_endpoints', function ( $endpoints ) {
	unset( $endpoints['/wp/v2/comments'], $endpoints['/wp/v2/comments/(?P<id>[\d]+)'] );
	return $endpoints;
} );
add_action( 'admin_menu', function () { remove_menu_page( 'edit-comments.php' ); } );
add_action( 'admin_bar_menu', function ( $bar ) { $bar->remove_node( 'comments' ); }, 999 );
add_action( 'widgets_init', function () { unregister_widget( 'WP_Widget_Recent_Comments' ); }, 20 );
