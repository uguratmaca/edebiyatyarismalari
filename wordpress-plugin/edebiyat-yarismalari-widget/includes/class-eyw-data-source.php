<?php
if ( ! defined( 'ABSPATH' ) ) {
	exit;
}

/**
 * edebiyatyarismalari.com/yarismalar.json besleme verisini çeker, cache'ler ve filtreler.
 */
class EYW_Data_Source {

	const FALLBACK_OPTION = 'eyw_yarismalar_fallback';

	/**
	 * Yarışma listesini döndürür (en yakın son başvuru tarihi önce).
	 *
	 * @return array
	 */
	public static function get_items() {
		$items = get_transient( EYW_TRANSIENT_KEY );

		if ( false === $items ) {
			$items = self::fetch_remote();
		}

		if ( ! is_array( $items ) ) {
			return array();
		}

		usort(
			$items,
			function ( $a, $b ) {
				return ( $a['lastDate'] ?? 0 ) <=> ( $b['lastDate'] ?? 0 );
			}
		);

		return $items;
	}

	/**
	 * Uzak JSON'u çeker; başarısız olursa varsa en son başarılı sonucu (stale) döndürür.
	 *
	 * @return array
	 */
	private static function fetch_remote() {
		$response = wp_remote_get(
			EYW_FEED_URL,
			array(
				'timeout' => 5,
			)
		);

		if ( is_wp_error( $response ) || 200 !== wp_remote_retrieve_response_code( $response ) ) {
			$fallback = get_option( self::FALLBACK_OPTION, array() );
			return is_array( $fallback ) ? $fallback : array();
		}

		$body  = wp_remote_retrieve_body( $response );
		$items = json_decode( $body, true );

		if ( ! is_array( $items ) ) {
			$fallback = get_option( self::FALLBACK_OPTION, array() );
			return is_array( $fallback ) ? $fallback : array();
		}

		set_transient( EYW_TRANSIENT_KEY, $items, EYW_CACHE_TTL );
		update_option( self::FALLBACK_OPTION, $items, false );

		return $items;
	}

	/**
	 * Verilen tag'e (tip) göre süzer. Karşılaştırma büyük/küçük harf ve Türkçe karakter duyarsızdır.
	 *
	 * @param array  $items Yarışma listesi.
	 * @param string $tag   Aranacak tag, örn. "hikaye yarışması".
	 * @return array
	 */
	public static function filter_by_tag( array $items, $tag ) {
		if ( '' === trim( (string) $tag ) ) {
			return $items;
		}

		$needle = mb_strtolower( trim( $tag ), 'UTF-8' );

		return array_values(
			array_filter(
				$items,
				function ( $item ) use ( $needle ) {
					if ( empty( $item['tags'] ) || ! is_array( $item['tags'] ) ) {
						return false;
					}
					foreach ( $item['tags'] as $item_tag ) {
						if ( mb_strtolower( (string) $item_tag, 'UTF-8' ) === $needle ) {
							return true;
						}
					}
					return false;
				}
			)
		);
	}
}
