# find_lost_urls.rb'nin bulduğu kayıp permalink'leri toplu olarak geri getirir:
# her biri için, o permalink'in son canlı olduğu commit'teki tam dosya
# içeriğini geri yazar, archived_to alanını ekler (evergreen sayfaya işaret
# edecek şekilde) ve hangi evergreen dosyaya "Geçmiş Yıllar" satırı eklenmesi
# gerektiğini raporlar (satırı otomatik de ekler, --no-geçmiş ile kapatılabilir).
#
# Kullanım:
#   bundle exec ruby scripts/restore_lost_urls.rb            # dry-run, ne yapacağını yazar
#   bundle exec ruby scripts/restore_lost_urls.rb --apply    # gerçekten uygular

require 'jekyll'

APPLY = ARGV.include?('--apply')

config = Jekyll.configuration('source' => Dir.pwd)
site = Jekyll::Site.new(config)
site.read

live_permalinks = {}
site.posts.docs.each { |doc| live_permalinks[doc.url] = doc.relative_path }

def normalize(permalink)
  p = permalink.to_s.strip.gsub(/^\/+|\/+$/, '')
  "/#{p}"
end

def extract_permalink(content)
  return nil unless content
  match = content.match(/^permalink:\s*"?([^"\n]+?)"?\s*$/)
  match && match[1]
end

evergreen_docs = site.posts.docs.select { |doc| doc.relative_path.start_with?('_posts/evergreen/') }

restored = []

evergreen_docs.each do |doc|
  current_path = doc.relative_path
  log = `git log --follow --name-status --format="COMMIT %H" -- "#{current_path}"`
  next if log.strip.empty?

  path_for_commit = {}
  commit_order = []
  segment_path = current_path
  commit = nil

  log.each_line do |line|
    line = line.rstrip
    if line =~ /^COMMIT (\w+)/
      commit = $1
      path_for_commit[commit] = segment_path
      commit_order << commit
    elsif line =~ /^R\d+\s+(\S+)\s+(\S+)/
      old_path = $1
      segment_path = old_path
    end
  end

  # path_for_commit degerlerinden, dosyanin _posts/evergreen/ disindaki
  # SON (en yeni) konumunu ve o andaki commit'i bul. Ara donemde dosya
  # evergreen/ altina tasinmis ama permalink alani daha sonraki ayri bir
  # commit'te degismis olabilir; boyle durumlarda arsiv sayfasini
  # evergreen/ klasorune degil, gercek tarihli klasorune geri yazmak
  # icin bu "son evergreen-oncesi hal" tercih edilir.
  last_non_evergreen_commit = nil
  last_non_evergreen_path = nil
  commit_order.each do |c|
    path = path_for_commit[c]
    next if path.start_with?('_posts/evergreen/')
    last_non_evergreen_commit = c
    last_non_evergreen_path = path
    break
  end

  # en yeniden en eskiye dogru (git log varsayilan sirasi)
  seen_permalinks = {}
  commit_order.each do |c|
    path = path_for_commit[c]
    content = `git show #{c}:"#{path}" 2>nul`
    next if content.strip.empty?
    perm = extract_permalink(content)
    next unless perm
    norm = normalize(perm)
    next if norm == doc.url
    next if live_permalinks.key?(norm)
    next if seen_permalinks.key?(norm) # sadece en yeni (ilk gorulen) halini al

    if path.start_with?('_posts/evergreen/') && last_non_evergreen_path
      # evergreen/ icindeki ara hal yerine, evergreen'e girmeden onceki
      # son gercek tarihli konumu ve icerigini kullan
      real_content = `git show #{last_non_evergreen_commit}:"#{last_non_evergreen_path}" 2>nul`
      unless real_content.strip.empty?
        c = last_non_evergreen_commit
        path = last_non_evergreen_path
        content = real_content
        real_perm = extract_permalink(content)
        norm = normalize(real_perm) if real_perm
      end
    end

    seen_permalinks[norm] = { commit: c, path: path, content: content }
  end

  seen_permalinks.each do |norm, info|
    restored << {
      evergreen_doc: doc,
      lost_url: norm,
      commit: info[:commit],
      historical_path: info[:path],
      content: info[:content],
    }
  end
end

puts "== #{restored.size} kayip permalink bulundu =="
puts

restored.each do |r|
  target_path = r[:historical_path]
  if File.exist?(target_path)
    puts "ATLA (zaten var): #{target_path}"
    next
  end

  content = r[:content]
  archived_to_url = r[:evergreen_doc].url

  unless content =~ /^archived_to:/m
    close_idx = content.index("\n---", 4)
    raise "front matter kapanisi yok: #{target_path}" unless close_idx
    content = content[0...close_idx] + "\narchived_to: \"#{archived_to_url}\"" + content[close_idx..]
  end

  year = File.basename(target_path)[0..3]
  title = content[/^title:\s*"?([^"\n]+?)"?\s*$/, 1]
  organizer = content[/^organizer:\s*"?([^"\n]+?)"?\s*$/, 1]

  puts "GERI YAZILACAK: #{target_path}"
  puts "  baslik: #{title}"
  puts "  organizer: #{organizer}"
  puts "  evergreen: #{r[:evergreen_doc].data['title']} (#{archived_to_url})"
  puts "  permalink: #{r[:lost_url]}  commit: #{r[:commit]}"
  puts "  evergreen Gecmis Yillar satiri: - [#{year}](#{r[:lost_url]})"

  next unless APPLY

  FileUtils.mkdir_p(File.dirname(target_path))
  File.write(target_path, content, encoding: 'utf-8')

  # evergreen dosyaya Gecmis Yillar satiri ekle
  ev_path = r[:evergreen_doc].relative_path
  ev_text = File.read(ev_path, encoding: 'utf-8')
  line_to_add = "- [#{year}](#{r[:lost_url]})"
  next if ev_text.include?("](#{r[:lost_url]})")

  if ev_text =~ /(### Geçmiş Yıllar\n\n.*?\n\n)(- \[)/m
    ev_text = ev_text.sub(/(### Geçmiş Yıllar\n\n.*?\n\n)(- \[)/m) { "#{$1}#{line_to_add}\n#{$2}" }
  elsif ev_text =~ /### Geçmiş Yıllar\n\n.*\n/
    ev_text = ev_text.sub(/(### Geçmiş Yıllar\n\n.*\n)/) { "#{$1}#{line_to_add}\n" }
  else
    ev_text = ev_text.rstrip + "\n\n### Geçmiş Yıllar\n\n#{line_to_add}\n"
  end
  File.write(ev_path, ev_text, encoding: 'utf-8')
end

puts
puts APPLY ? 'UYGULANDI' : 'DRY-RUN tamamlandi (--apply ile gercek yaz)'
