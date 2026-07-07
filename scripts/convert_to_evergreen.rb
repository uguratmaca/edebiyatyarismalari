# Bir defalık toplu dönüşüm: doğrulanmış, gerçekten yıldan yıla tekrarlanan
# yarışma serilerini _posts/evergreen/ formatına taşır. Her grup için:
#   - en güncel post evergreen'e taşınır (title/description/excerpt'teki yıl temizlenir)
#   - varsa eski bir postun zaten kullandığı "temiz" (yılsız) permalink evergreen'e devredilir;
#     o eski postun permalink'ine yıl eklenir (çakışma olmasın diye)
#   - diğer tüm eski postlara archived_to eklenir
#   - evergreen sayfanın sonuna "Geçmiş Yıllar" bölümü eklenir
#   - _posts/evergreen/INDEX.md'ye alfabetik satır eklenir
#
# Bu, README.md'deki "Yeni bir yarışmayı ilk kez evergreen'e çevirmek" adımlarının
# otomasyonudur. Manifest elle, her postun içeriği okunarak hazırlandı.
#
# Kullanım:
#   bundle exec ruby scripts/convert_to_evergreen.rb            # dry-run, ne yapacağını yazar
#   bundle exec ruby scripts/convert_to_evergreen.rb --apply    # gerçekten uygular

require 'jekyll'
require 'fileutils'

APPLY = ARGV.include?('--apply')

GROUPS = [
  {
    name: "Dr.Kamil Furtun Öykü Yarışması",
    dir: "hikaye", tag: "her yıl tekrarlanan hikaye",
    base: "_posts/2026/ocak/2026-01-11-dr-kamil-furtun.md",
    new_slug: "dr-kamil-furtun-oyku-yarismasi",
    title_subs: [["Dr.Kamil Furtun Öykü Yarışması 2026", "Dr.Kamil Furtun Öykü Yarışması"]],
    older: [
      { path: "_posts/2024/aralik/2024-12-17-dr-kamil-furtun.md", takes_new_slug: true, renamed_suffix: "2025" },
      { path: "_posts/2022/kasim/2022-11-12-kamil-furtun-oyku-yarismasi.md" },
    ],
  },
].freeze

config = Jekyll.configuration('source' => Dir.pwd)
site = Jekyll::Site.new(config)
site.read
url_to_doc = {}
site.posts.docs.each { |doc| url_to_doc[doc.url] = doc }

def read_front_matter(path)
  text = File.read(path, encoding: 'utf-8')
  raise "front matter yok: #{path}" unless text.start_with?("---\n")
  close_idx = text.index("\n---", 4)
  raise "front matter kapanışı yok: #{path}" unless close_idx
  fm_text = text[4...close_idx]
  body = text[(close_idx + 5)..]
  [fm_text, body]
end

def set_permalink(path, new_permalink)
  fm_text, body = read_front_matter(path)
  if fm_text =~ /^permalink:.*$/
    fm_text = fm_text.sub(/^permalink:.*$/, "permalink: \"#{new_permalink}\"")
  else
    fm_text = "permalink: \"#{new_permalink}\"\n" + fm_text
  end
  File.write(path, "---\n#{fm_text}\n---\n#{body}", encoding: 'utf-8') if APPLY
end

def add_archived_to(path, target_url)
  fm_text, body = read_front_matter(path)
  return if fm_text =~ /^archived_to:/
  fm_text = fm_text.chomp + "\narchived_to: \"#{target_url}\"\n"
  File.write(path, "---\n#{fm_text}---\n#{body}", encoding: 'utf-8') if APPLY
end

index_entries = []

GROUPS.each do |g|
  puts "=== #{g[:name]} ==="
  base_doc = url_to_doc.values.find { |d| d.relative_path == g[:base] }
  raise "base bulunamadi: #{g[:base]}" unless base_doc

  new_permalink = g[:new_slug]

  # Cakisma kontrolu + temiz permalink devri
  donor = g[:older].find { |o| o[:takes_new_slug] }
  if donor
    donor_doc = url_to_doc.values.find { |d| d.relative_path == donor[:path] }
    raise "donor bulunamadi: #{donor[:path]}" unless donor_doc
    old_permalink = donor_doc.data['permalink'] || donor_doc.url.sub(%r{^/}, '').sub(%r{/$}, '')
    unless old_permalink == new_permalink || old_permalink.sub(%r{/$}, '') == new_permalink
      puts "  UYARI: donor permalink (#{old_permalink}) yeni slug (#{new_permalink}) ile eslesmiyor, yine de devam."
    end
    renamed = "#{new_permalink}-#{donor[:renamed_suffix]}"
    puts "  #{donor[:path]}: permalink '#{old_permalink}' -> '#{renamed}' (eski, evergreen'e devretti)"
    set_permalink(donor[:path], renamed)
  end

  evergreen_dir = File.join('_posts', 'evergreen', g[:dir])
  new_filename = File.basename(g[:base]).sub(/^(\d{4}-\d{2}-\d{2})-.*$/) { "#{$1}-#{g[:new_slug]}.md" }
  new_path = File.join(evergreen_dir, new_filename)

  text = File.read(g[:base], encoding: 'utf-8')
  g[:title_subs].each { |from, to| text = text.gsub(from, to) }

  unless text =~ /^permalink:/m
    text = text.sub(/^---\n/, "---\npermalink: \"#{new_permalink}\"\n")
  else
    text = text.sub(/^permalink:.*$/, "permalink: \"#{new_permalink}\"")
  end

  unless text =~ /^tags:.*#{Regexp.escape(g[:tag])}/
    text = text.sub(/^tags:\s*\[/, "tags: [#{g[:tag]}, ")
  end

  # Gecmis Yillar bolumu
  older_sorted = g[:older].map do |o|
    doc = url_to_doc.values.find { |d| d.relative_path == o[:path] }
    raise "eski post bulunamadi: #{o[:path]}" unless doc
    perm = o[:takes_new_slug] ? "#{new_permalink}-#{o[:renamed_suffix]}" : (doc.data['permalink'] || doc.url.sub(%r{^/}, '').sub(%r{/$}, ''))
    { year: doc.date.year, permalink: perm.sub(%r{/$}, ''), old_url: doc.url }
  end.sort_by { |o| -o[:year] }

  gecmis = "\n\n### Geçmiş Yıllar\n\n#{g[:name]}'nın önceki dönemlerine aşağıdan ulaşabilirsiniz:\n\n"
  gecmis += older_sorted.map { |o| "- [#{o[:year]}](/#{o[:permalink]}/)" }.join("\n")
  text = text.rstrip + gecmis + "\n"

  puts "  yeni evergreen dosyasi: #{new_path}"
  puts "  yeni permalink: #{new_permalink}"

  if APPLY
    FileUtils.mkdir_p(evergreen_dir)
    File.write(new_path, text, encoding: 'utf-8')
    File.delete(g[:base])
  end

  new_url = "/#{new_permalink}/"
  older_sorted.each do |o|
    puts "  archived_to ekleniyor: #{o[:old_url]} -> #{new_url}"
  end
  g[:older].each do |o|
    add_archived_to(o[:path], new_url)
  end

  index_entries << "- **#{g[:name]}** — [dosya](#{File.basename(new_path)}) · `/#{new_permalink}`"
end

if APPLY
  index_path = '_posts/evergreen/INDEX.md'
  lines = File.read(index_path, encoding: 'utf-8').lines
  header_end = lines.index { |l| l.start_with?('- ') } || lines.length
  new_lines = (lines[0...header_end] + (lines[header_end..] + index_entries.map { |e| e + "\n" })).flatten
  bullets = new_lines.select { |l| l.start_with?('- ') }
  rest = new_lines - bullets
  bullets_sorted = bullets.sort_by { |l| l.sub(/^- \*\*/, '').downcase }
  File.write(index_path, (rest + bullets_sorted).join, encoding: 'utf-8')
  puts "\nINDEX.md guncellendi (#{index_entries.size} yeni satir, alfabetik siralandi)."
end

puts "\n#{APPLY ? 'UYGULANDI' : 'DRY-RUN tamamlandi (--apply ile gercek yaz)'}"
