<?php
/**
 * Plugin Name:       Edebiyat Yarışmaları Widget
 * Plugin URI:         https://edebiyatyarismalari.com
 * Description:        edebiyatyarismalari.com'daki güncel edebiyat yarışması duyurularını [eyw_widget] shortcode'u ile sitenizde listeler.
 * Version:            1.0.0
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

define( 'EYW_VERSION', '1.0.0' );
define( 'EYW_PLUGIN_DIR', plugin_dir_path( __FILE__ ) );
define( 'EYW_PLUGIN_URL', plugin_dir_url( __FILE__ ) );
define( 'EYW_FEED_URL', 'https://edebiyatyarismalari.com/yarismalar.json' );
define( 'EYW_TRANSIENT_KEY', 'eyw_yarismalar' );
define( 'EYW_CACHE_TTL', 12 * HOUR_IN_SECONDS );

require_once EYW_PLUGIN_DIR . 'includes/class-eyw-data-source.php';
require_once EYW_PLUGIN_DIR . 'includes/class-eyw-shortcode.php';

add_action( 'wp_enqueue_scripts', 'eyw_register_assets' );
/**
 * Stil dosyasını kaydeder (henüz kuyruğa almaz — asıl enqueue shortcode render edildiğinde yapılır).
 */
function eyw_register_assets() {
	wp_register_style( 'eyw-style', EYW_PLUGIN_URL . 'assets/eyw-style.css', array(), EYW_VERSION );
}

EYW_Shortcode::init();
