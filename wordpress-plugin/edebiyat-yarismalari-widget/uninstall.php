<?php
if ( ! defined( 'WP_UNINSTALL_PLUGIN' ) ) {
	exit;
}

delete_option( 'edyw_yarismalar_fallback' );
delete_transient( 'edyw_yarismalar' );
