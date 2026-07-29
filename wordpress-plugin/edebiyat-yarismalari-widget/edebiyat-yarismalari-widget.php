<?php
/**
 * Plugin Name:       Edebiyat Yarışmaları Widget
 * Description:        edebiyatyarismalari.com'daki güncel edebiyat yarışması duyurularını [edyw_widget] shortcode'u ile sitenizde listeler.
 * Version:            1.0.1
 * Requires at least:  5.8
 * Requires PHP:       7.4
 * Author:             edebiyatyarismalari.com
 * Author URI:         https://edebiyatyarismalari.com
 * License:             GPL v2 or later
 * License URI:         https://www.gnu.org/licenses/gpl-2.0.html
 * Text Domain:         edebiyat-yarismalari-widget
 */

if ( ! defined( 'ABSPATH' ) ) {
	exit; // Doğrudan erişim engellendi.
}

define( 'EDYW_VERSION', '1.0.1' );
define( 'EDYW_PLUGIN_DIR', plugin_dir_path( __FILE__ ) );
define( 'EDYW_PLUGIN_URL', plugin_dir_url( __FILE__ ) );
define( 'EDYW_FEED_URL', 'https://edebiyatyarismalari.com/yarismalar.json' );
define( 'EDYW_TRANSIENT_KEY', 'edyw_yarismalar' );
define( 'EDYW_CACHE_TTL', 12 * HOUR_IN_SECONDS );

require_once EDYW_PLUGIN_DIR . 'includes/class-edyw-data-source.php';
require_once EDYW_PLUGIN_DIR . 'includes/class-edyw-shortcode.php';

add_action( 'wp_enqueue_scripts', 'edyw_register_assets' );
/**
 * Stil dosyasını kaydeder (henüz kuyruğa almaz — asıl enqueue shortcode render edildiğinde yapılır).
 */
function edyw_register_assets() {
	wp_register_style( 'edyw-style', EDYW_PLUGIN_URL . 'assets/edyw-style.css', array(), EDYW_VERSION );
}

EDYW_Shortcode::init();
