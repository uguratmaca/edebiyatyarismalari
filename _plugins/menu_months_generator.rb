# Header'daki "Zamana Göre" menüsünün ayları elle güncellendiğinde geride kalıyordu.
# Bu generator build-time'da (Pages her gün yeniden build ediliyor) bu ay ve sonraki
# iki ayın aylık sayfasını (menuler/aylar/<yıl>/<ay>.md) bulup
# site.data['menu_months'] içine [{ 'title', 'url' }] olarak yazar. Sayfası olmayan
# ay atlanır, böylece menüde 404 link çıkmaz; yeni yılın sayfaları elle eklenir.
module Jekyll
  class MenuMonthsGenerator < Generator
    safe true
    priority :low

    SLUGS = %w[ocak subat mart nisan mayis haziran temmuz agustos eylul ekim kasim aralik].freeze
    NAMES = %w[Ocak Şubat Mart Nisan Mayıs Haziran Temmuz Ağustos Eylül Ekim Kasım Aralık].freeze
    MONTH_COUNT = 3

    def generate(site)
      now = Time.now.getlocal('+03:00')
      permalinks = site.pages.select { |p| p.data['layout'] == 'monthly' }
                             .map { |p| p.data['permalink'].to_s.delete_prefix('/') }

      months = (0...MONTH_COUNT).filter_map do |offset|
        index = now.month - 1 + offset
        month = index % 12
        year = now.year + index / 12
        permalink = "#{SLUGS[month]}-#{year}-yarismalar/"
        next unless permalinks.include?(permalink)

        { 'title' => "#{NAMES[month]} #{year} Yarışmaları", 'url' => "/#{permalink}" }
      end

      site.data['menu_months'] = months
    end
  end
end
