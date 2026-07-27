<?php
if ( ! defined( 'WP_UNINSTALL_PLUGIN' ) ) {
	exit;
}

delete_option( 'eyw_yarismalar_fallback' );
delete_transient( 'eyw_yarismalar' );
