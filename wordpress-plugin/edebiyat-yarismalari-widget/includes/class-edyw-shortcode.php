<?php
if ( ! defined( 'ABSPATH' ) ) {
	exit;
}

require_once EDYW_PLUGIN_DIR . 'includes/class-edyw-data-source.php';

/**
 * [edyw_widget] shortcode'unu kaydeder ve render eder.
 */
class EDYW_Shortcode {

	/**
	 * Hook kayıtları.
	 */
	public static function init() {
		add_shortcode( 'edyw_widget', array( __CLASS__, 'render' ) );
	}

	/**
	 * Shortcode çıktısını üretir.
	 *
	 * @param array $atts Shortcode attribute'ları.
	 * @return string
	 */
	public static function render( $atts ) {
		$atts = shortcode_atts(
			array(
				'count'    => 5,
				'tip'      => '',
				'baslik'   => '',
				'ucretsiz' => '',
				'bicim'    => '',
				'kitapsiz' => '',
				'rozet'    => '',
			),
			$atts,
			'edyw_widget'
		);

		$items = EDYW_Data_Source::get_items();

		if ( '' !== $atts['tip'] ) {
			$items = EDYW_Data_Source::filter_by_tag( $items, $atts['tip'] );
		}

		if ( '1' === (string) $atts['ucretsiz'] ) {
			$items = EDYW_Data_Source::filter_free( $items );
		}

		if ( '' !== $atts['bicim'] ) {
			$items = EDYW_Data_Source::filter_by_submission_type( $items, $atts['bicim'] );
		}

		if ( '1' === (string) $atts['kitapsiz'] ) {
			$items = EDYW_Data_Source::filter_no_book( $items );
		}

		$show_badges = '1' === (string) $atts['rozet'];

		$count = max( 1, (int) $atts['count'] );
		$items = array_slice( $items, 0, $count );

		if ( empty( $items ) ) {
			return '';
		}

		wp_enqueue_style( 'edyw-style' );

		ob_start();
		?>
		<div class="edyw-widget">
			<?php if ( '' !== $atts['baslik'] ) : ?>
				<h3 class="edyw-widget__title"><?php echo esc_html( $atts['baslik'] ); ?></h3>
			<?php endif; ?>
			<ul class="edyw-widget__list">
				<?php foreach ( $items as $item ) : ?>
					<li class="edyw-widget__item">
						<a
							href="<?php echo esc_url( $item['url'] ?? '' ); ?>"
							rel="nofollow sponsored noopener"
							target="_blank"
						><?php echo esc_html( $item['title'] ?? '' ); ?></a>
						<?php if ( ! empty( $item['dateHuman'] ) ) : ?>
							<span class="edyw-widget__date">
								<?php
								echo esc_html(
									sprintf(
										/* translators: %s: son başvuru tarihi */
										__( 'Son başvuru: %s', 'edebiyat-yarismalari-widget' ),
										$item['dateHuman']
									)
								);
								?>
							</span>
						<?php endif; ?>
						<?php if ( ! empty( $item['totalPrize'] ) ) : ?>
							<span class="edyw-widget__prize">
								<?php
								echo esc_html(
									sprintf(
										/* translators: %s: toplam para ödülü */
										__( 'Ödül: %s', 'edebiyat-yarismalari-widget' ),
										$item['totalPrize']
									)
								);
								?>
							</span>
						<?php endif; ?>
						<?php $badges = $show_badges ? EDYW_Data_Source::badges( $item ) : array(); ?>
						<?php if ( ! empty( $badges ) ) : ?>
							<span class="edyw-widget__badges">
								<?php foreach ( $badges as $badge ) : ?>
									<span class="edyw-widget__badge"><?php echo esc_html( $badge ); ?></span>
								<?php endforeach; ?>
							</span>
						<?php endif; ?>
					</li>
				<?php endforeach; ?>
			</ul>
			<p class="edyw-widget__credit">
				<?php esc_html_e( 'Kaynak:', 'edebiyat-yarismalari-widget' ); ?>
				<a href="https://edebiyatyarismalari.com" rel="nofollow sponsored noopener" target="_blank">edebiyatyarismalari.com</a>
			</p>
		</div>
		<?php
		return ob_get_clean();
	}
}
