# feed.xml (Mailchimp'in haftalık RSS-otomasyonunun kaynağı) varsayılan olarak
# en yeni eklenen postu en üste koyar. Bu filtre, o sırayı iki sinyale göre
# yeniden düzenler — tamamen build-time'da, mail gönderiminde elle bir şey
# yapmaya gerek kalmadan:
#   1. `featured: true` olan post(lar) her zaman en üstte.
#   2. Eşit durumda (ikisi de featured ya da ikisi de değilse) `totalPrize`'ı
#      en yüksek olan önde — bkz. prize_amount_parser.rb (aynı TL ayrıştırıcı).
#   3. Geri kalanında mevcut (en yeni eklenen önce) sıra korunur.
require_relative "prize_amount_parser"

module Jekyll
  module FeedOrderFilter
    include Jekyll::PrizeAmountParserFilter

    def order_for_feed(posts)
      return posts unless posts.respond_to?(:each_with_index)

      posts.each_with_index
        .sort_by do |post, index|
          featured = feed_field(post, "featured")
          prize = prize_amount_try(feed_field(post, "totalPrize")) || 0
          [featured ? 0 : 1, -prize, index]
        end
        .map(&:first)
    end

    private

    def feed_field(post, key)
      post.respond_to?(:data) ? post.data[key] : post[key]
    end
  end
end

Liquid::Template.register_filter(Jekyll::FeedOrderFilter)
