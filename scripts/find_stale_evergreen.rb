# "her yıl tekrarlanan..." etiketli evergreen yarışmalardan, dateHuman yılı
# içinde bulunduğumuz yıldan eski olanları (yani bu yıl için henüz yeni bir
# edisyonu eklenmemiş olanları) listeler. yarisma-bul skill'i bu scripti
# kullanır.
#
# Kullanım:
#   bundle exec ruby scripts/find_stale_evergreen.rb

require 'date'

CURRENT_YEAR = Date.today.year

def read_front_matter(path)
  text = File.read(path, encoding: 'utf-8')
  return nil unless text.start_with?("---\n")
  close_idx = text.index("\n---", 4)
  return nil unless close_idx
  text[4...close_idx]
end

def field(fm, name)
  m = fm.match(/^#{name}:\s*"?(.*?)"?\s*$/)
  m && m[1]
end

results = []

Dir.glob('_posts/evergreen/**/*.md').each do |path|
  next if File.basename(path) == 'INDEX.md'
  fm = read_front_matter(path)
  next unless fm
  tags = field(fm, 'tags') || ''
  next unless tags.include?('her yıl tekrarlanan')

  date_human = field(fm, 'dateHuman')
  title = field(fm, 'title')
  permalink = field(fm, 'permalink')
  next unless date_human

  year_match = date_human.match(/(\d{4})\s*$/)
  next unless year_match
  year = year_match[1].to_i

  next if year >= CURRENT_YEAR

  results << { title: title, dateHuman: date_human, year: year, permalink: permalink, path: path }
end

results.sort_by! { |r| r[:year] }

puts "Bugün: #{Date.today} (yıl: #{CURRENT_YEAR})"
puts "Tekrar etmemiş (en eski önce): #{results.size} yarışma\n\n"

results.each do |r|
  puts "- #{r[:title]} — son bilinen: #{r[:dateHuman]} (#{CURRENT_YEAR - r[:year]} yıl önce) — /#{r[:permalink]} — #{r[:path]}"
end
