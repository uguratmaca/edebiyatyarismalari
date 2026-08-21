# Ana sayfa sayfalaması (index.html + sayfa2../sayfa5/) elle bakımı gereken sabit
# counter aralıklarına dayanıyordu ve pagination.html en fazla 5 sayfa linkliyordu
# — aktif (hidden/sticky olmayan, lastDate'i geçmemiş) yarışma sayısı 34'ü geçince
# fazlası sayfalamadan tamamen düşüyordu.
#
# Bu generator, build-time'da aktif sayıya göre kaç sayfa gerektiğini hesaplar:
# - site.data['dynamic_pagination']['total_pages'] içine yazar (pagination.html bunu okuyup
#   ihtiyaç kadar sayfa linki üretir).
# - index.html (sayfa 1) ve sayfa2../sayfa5/ repo'da statik dosya olarak duruyor, onlara
#   dokunmaz; sadece 6. sayfadan itibaren gerekiyorsa sayfaN/index.html'i kendisi üretir.
#
# Sayfa başına içerik sayısı (6 ilk sayfada, 7 sonrakilerde) index.html/sayfa2-5'teki
# counter aralıklarıyla birebir aynı olmalı.
module Jekyll
  class HomepagePaginationGenerator < Generator
    safe true
    priority :low

    FIRST_PAGE_SIZE = 6
    PAGE_SIZE = 7
    STATIC_PAGES = 5 # index.html (1) + sayfa2../sayfa5/ repo'da elle duruyor

    def generate(site)
      now = Time.now.to_i
      active_count = site.posts.docs.count do |post|
        post.data['hidden'] != true &&
          post.data['sticky'] != true &&
          post.data['lastDate'].to_i > now
      end

      total_pages = 1
      if active_count > FIRST_PAGE_SIZE
        remaining = active_count - FIRST_PAGE_SIZE
        total_pages = 1 + (remaining.to_f / PAGE_SIZE).ceil
      end

      site.data['dynamic_pagination'] = { 'total_pages' => total_pages }

      ((STATIC_PAGES + 1)..total_pages).each do |page_num|
        lower = FIRST_PAGE_SIZE + (page_num - 2) * PAGE_SIZE
        upper = lower + PAGE_SIZE + 1
        site.pages << PaginatedHomePage.new(site, page_num, lower, upper)
      end
    end
  end

  class PaginatedHomePage < Jekyll::PageWithoutAFile
    def initialize(site, page_num, lower, upper)
      super(site, site.source, "sayfa#{page_num}", 'index.html')

      self.data = {
        'layout' => 'default',
        'title' => "Sayfa #{page_num}",
        'description' => "Güncel edebiyat yarışmalarının #{page_num}. sayfasındasınız."
      }

      self.content = <<~LIQUID
        <section class="p-2">
        \t<h1>Güncel Edebiyat Yarışmaları &ndash; Sayfa #{page_num}</h1>
        \t<hr>

        \t{% capture nowunix %}{{'now' | date: '%s'}}{% endcapture %}
        \t{% assign nowDateInt = nowunix | plus: 0 %}
        \t{% assign counter = 0 %}

        \t{% for post in site.posts %}
        \t\t{% if post.hidden != true and post.sticky != true and post.lastDate > nowDateInt %}
        \t\t\t{% assign counter = counter | plus: 1 %}
        \t\t\t{% if counter > #{lower} and counter < #{upper} %}
        \t\t\t\t{% include postdetail.html %}
        \t\t\t{% endif %}
        \t\t{% endif %}
        \t{% endfor %}

        \t{% include pagination.html current=#{page_num} %}
        </section>
      LIQUID
    end
  end
end
