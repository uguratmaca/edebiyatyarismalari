# 2018 döneminden kalma, hem `description` (<60 karakter) hem `excerpt`
# (yoksa/<30 karakter) açısından zayıf postlar için gövdeden otomatik bir
# açıklama üretip `description`/`excerpt` alanlarını doldurur. Bu postlar
# şu anda meta description'da generic site.description'a düşüyor (bkz.
# _includes/head.html) — hepsi aynı meta description'ı paylaşıyor.
#
# Kullanım:
#   ruby scripts/backfill_old_descriptions.rb          # dry-run, ne değişecek gösterir
#   ruby scripts/backfill_old_descriptions.rb --apply   # gerçekten yazar

require 'yaml'

APPLY = ARGV.include?('--apply')
MIN_DESC = 60
MIN_EXCERPT = 30
TARGET_LEN = 155

def front_matter_and_body(text)
  return nil unless text.start_with?("---\n")
  close_idx = text.index("\n---", 4)
  return nil unless close_idx
  fm = text[4...close_idx]
  body = text[(close_idx + 4)..-1].to_s.sub(/\A\s*\n/, '')
  [fm, body]
end

def field(fm, name)
  m = fm.match(/^#{name}:\s*"?(.*?)"?\s*$/)
  m && m[1]
end

def build_description(body)
  text = body.dup
  # Sadece link olan satırları at (ör. "[Detaylar ve Başvuru için](...)")
  text = text.lines.reject { |l| l.strip =~ /\A\[.*\]\(https?:\/\// }.join
  # Markdown linklerini düz metne çevir: [metin](url){...} -> metin
  text = text.gsub(/\[([^\]]*)\]\([^)]*\)(\{[^}]*\})*/, '\1')
  # Kalın/italik işaretlerini temizle
  text = text.gsub(/[*_#]/, '')
  # Başlıktaki "Son Başvuru Tarihi: ... ." ve "Toplam ödül: ... ." cümlelerini at
  text = text.sub(/\A\s*Son Başvuru Tarihi:[^.]*\.\s*/i, '')
  text = text.sub(/\A\s*Toplam ödül:[^.]*\.\s*/i, '')
  text = text.gsub(/\r/, '').gsub(/\n+/, ' ').gsub(/\s+/, ' ').strip

  return nil if text.empty?

  if text.length <= TARGET_LEN
    truncated = text
  else
    cut = text[0, TARGET_LEN]
    last_dot = cut.rindex('. ')
    if last_dot && last_dot > MIN_DESC
      truncated = cut[0..last_dot].strip
    else
      last_space = cut.rindex(' ')
      truncated = (last_space ? cut[0...last_space] : cut).strip + '…'
    end
  end
  truncated
end

results = []

Dir.glob('_posts/**/*.md').each do |path|
  text = File.read(path, encoding: 'utf-8')
  fm, body = front_matter_and_body(text)
  next unless fm && body

  desc = field(fm, 'description')
  excerpt = field(fm, 'excerpt')
  desc_ok = desc && desc.length >= MIN_DESC
  excerpt_ok = excerpt && excerpt.length >= MIN_EXCERPT
  next if desc_ok || excerpt_ok

  new_desc = build_description(body)
  next unless new_desc && new_desc.length >= MIN_DESC

  escaped = new_desc.gsub('\\', '\\\\').gsub('"', '\\"')

  results << { path: path, old: desc, new: new_desc, escaped: escaped }
end

puts "Bulunan: #{results.size} post\n\n"

results.each do |r|
  puts "#{r[:path]}"
  puts "  eski: #{r[:old].inspect}"
  puts "  yeni: #{r[:new]}"
  puts
end

if APPLY
  results.each do |r|
    text = File.read(r[:path], encoding: 'utf-8')
    if text =~ /^description:.*$/
      text = text.sub(/^description:.*$/, "description: \"#{r[:escaped]}\"")
    else
      text = text.sub(/^title:.*$/) { |m| "#{m}\ndescription: \"#{r[:escaped]}\"" }
    end
    if text =~ /^excerpt:.*$/
      text = text.sub(/^excerpt:.*$/, "excerpt: \"#{r[:escaped]}\"")
    else
      text = text.sub(/^description:.*$/) { |m| "#{m}\nexcerpt: \"#{r[:escaped]}\"" }
    end
    File.write(r[:path], text, encoding: 'utf-8')
  end
  puts "#{results.size} dosya güncellendi."
else
  puts "Dry-run tamamlandı. Uygulamak için: ruby scripts/backfill_old_descriptions.rb --apply"
end
