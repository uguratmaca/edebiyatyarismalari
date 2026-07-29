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
				'count'  => 5,
				'tip'    => '',
				'baslik' => '',
			),
			$atts,
			'edyw_widget'
		);

		$items = EDYW_Data_Source::get_items();

		if ( '' !== $atts['tip'] ) {
			$items = EDYW_Data_Source::filter_by_tag( $items, $atts['tip'] );
		}

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
