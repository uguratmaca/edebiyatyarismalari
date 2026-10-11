<?php
if ( ! defined( 'ABSPATH' ) ) {
	exit;
}

/**
 * edebiyatyarismalari.com/yarismalar.json besleme verisini çeker, cache'ler ve filtreler.
 */
class EDYW_Data_Source {

	const FALLBACK_OPTION = 'edyw_yarismalar_fallback';

	/**
	 * Yarışma listesini döndürür (en yakın son başvuru tarihi önce).
	 *
	 * @return array
	 */
	public static function get_items() {
		$items = get_transient( EDYW_TRANSIENT_KEY );

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
			EDYW_FEED_URL,
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

		set_transient( EDYW_TRANSIENT_KEY, $items, EDYW_CACHE_TTL );
		update_option( self::FALLBACK_OPTION, $items, false );

		return $items;
	}

	/**
	 * Verilen tag'e (tip) göre süzer. Virgülle ayrılmış birden fazla tag verilebilir, herhangi
	 * biri eşleşen yarışma gösterilir. Karşılaştırma büyük/küçük harf duyarsızdır.
	 *
	 * @param array  $items Yarışma listesi.
	 * @param string $tag   Aranacak tag(ler), örn. "hikaye yarışması" veya "şiir yarışması,hikaye yarışması".
	 * @return array
	 */
	public static function filter_by_tag( array $items, $tag ) {
		$needles = self::split_list( $tag );
		if ( empty( $needles ) ) {
			return $items;
		}

		return array_values(
			array_filter(
				$items,
				function ( $item ) use ( $needles ) {
					if ( empty( $item['tags'] ) || ! is_array( $item['tags'] ) ) {
						return false;
					}
					foreach ( $item['tags'] as $item_tag ) {
						if ( in_array( self::lower( $item_tag ), $needles, true ) ) {
							return true;
						}
					}
					return false;
				}
			)
		);
	}

	/**
	 * Sadece şartnamesinde açıkça "Ücretsiz" yazan yarışmaları bırakır (entryFee boşsa elenir).
	 *
	 * @param array $items Yarışma listesi.
	 * @return array
	 */
	public static function filter_free( array $items ) {
		return array_values(
			array_filter(
				$items,
				function ( $item ) {
					return 'ücretsiz' === self::lower( $item['entryFee'] ?? '' );
				}
			)
		);
	}

	/**
	 * Gönderim biçimine (submissionType) göre süzer: "tek eser", "kitap dosyası", "yayımlanmış kitap".
	 * Virgülle birden fazla değer verilebilir. submissionType yoksa yarışma "tek eser" sayılır.
	 *
	 * @param array  $items Yarışma listesi.
	 * @param string $bicim Aranacak biçim(ler).
	 * @return array
	 */
	public static function filter_by_submission_type( array $items, $bicim ) {
		$needles = self::split_list( $bicim );
		if ( empty( $needles ) ) {
			return $items;
		}

		return array_values(
			array_filter(
				$items,
				function ( $item ) use ( $needles ) {
					foreach ( self::submission_types( $item ) as $type ) {
						if ( in_array( self::lower( $type ), $needles, true ) ) {
							return true;
						}
					}
					return false;
				}
			)
		);
	}

	/**
	 * Daha önce kitabı yayımlanmamış yazarlara açık yarışmaları bırakır.
	 *
	 * @param array $items Yarışma listesi.
	 * @return array
	 */
	public static function filter_no_book( array $items ) {
		return array_values(
			array_filter(
				$items,
				function ( $item ) {
					return 'kitabı olmayanlar' === self::lower( $item['authorCondition'] ?? '' );
				}
			)
		);
	}

	/**
	 * Yarışma satırında gösterilecek rozet etiketlerini döndürür.
	 *
	 * @param array $item Yarışma.
	 * @return string[]
	 */
	public static function badges( array $item ) {
		$labels = array();
		$types  = array_map( array( __CLASS__, 'lower' ), self::submission_types( $item ) );
		$author = self::lower( $item['authorCondition'] ?? '' );

		if ( 'ücretsiz' === self::lower( $item['entryFee'] ?? '' ) ) {
			$labels[] = 'Ücretsiz';
		}
		if ( in_array( 'kitap dosyası', $types, true ) ) {
			$labels[] = 'Kitap dosyası';
		}
		if ( in_array( 'yayımlanmış kitap', $types, true ) ) {
			$labels[] = 'Yayımlanmış kitap';
		}
		if ( 'kitabı olmayanlar' === $author ) {
			$labels[] = 'Kitabı olmayanlara';
		}
		if ( 'ilk kitap' === $author ) {
			$labels[] = 'İlk kitap';
		}

		return $labels;
	}

	/**
	 * Yarışmanın gönderim biçimlerini döndürür; alan yoksa "tek eser" sayılır.
	 *
	 * @param array $item Yarışma.
	 * @return array
	 */
	private static function submission_types( array $item ) {
		if ( ! empty( $item['submissionType'] ) && is_array( $item['submissionType'] ) ) {
			return $item['submissionType'];
		}
		return array( 'tek eser' );
	}

	/**
	 * Virgülle ayrılmış metni küçük harfli, boşlukları temizlenmiş bir listeye çevirir.
	 *
	 * @param string $str Virgülle ayrılmış liste.
	 * @return string[]
	 */
	private static function split_list( $str ) {
		return array_values( array_filter( array_map( array( __CLASS__, 'lower' ), explode( ',', (string) $str ) ) ) );
	}

	/**
	 * @param mixed $str Metin.
	 * @return string
	 */
	private static function lower( $str ) {
		return mb_strtolower( trim( (string) $str ), 'UTF-8' );
	}
}
