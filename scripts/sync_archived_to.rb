# Evergreen yarışma postlarının "Geçmiş Yıllar" bölümünde listelediği eski
# postların archived_to alanını, evergreen sayfaya işaret edecek şekilde
# senkronize eder. Ayrıca evergreen karşılığı olmayan, birden fazla yıla
# yayılmış olası tekrarlanan yarışma serilerini raporlar (bunlar otomatik
# düzeltilmez, elle evergreen'e taşınmalı).
#
# Kullanım:
#   bundle exec ruby scripts/sync_archived_to.rb            # sadece rapor
#   bundle exec ruby scripts/sync_archived_to.rb --fix       # eksik archived_to alanlarını yazar

require 'jekyll'

FIX = ARGV.include?('--fix')

config = Jekyll.configuration('source' => Dir.pwd)
site = Jekyll::Site.new(config)
site.read

url_to_doc = {}
site.posts.docs.each { |doc| url_to_doc[doc.url] = doc }

def normalize_link(link)
  link = link.sub(/\?.*$/, '')
  link = link + '/' unless link.end_with?('/') || link.end_with?('.html')
  link
end

def lookup(url_to_doc, link)
  candidates = [link, normalize_link(link), link.sub(%r{/+$}, ''), link.sub(%r{/+$}, '') + '/']
  candidates.each { |c| return url_to_doc[c] if url_to_doc[c] }
  nil
end

evergreen_docs = site.posts.docs.select { |doc| doc.relative_path.start_with?('_posts/evergreen/') }

to_fix = []
mismatches = []
unresolved = []

evergreen_docs.each do |doc|
  target_url = doc.url
  links = doc.content.scan(/\]\((\/[^\s\)]+)\)/).flatten.uniq

  links.each do |link|
    old_doc = lookup(url_to_doc, link)
    if old_doc.nil?
      unresolved << [doc.relative_path, link]
      next
    end
    next if old_doc.relative_path == doc.relative_path

    current = old_doc.data['archived_to']
    if current.nil?
      to_fix << [old_doc.relative_path, target_url]
    elsif current != target_url
      mismatches << [old_doc.relative_path, current, target_url]
    end
  end
end

puts "== Eksik archived_to (evergreen 'Geçmiş Yıllar' listesinde var, dosyada yok): #{to_fix.size} =="
to_fix.each { |path, url| puts "  #{path} -> #{url}" }

puts
puts "== Uyuşmayan archived_to (var ama farklı bir hedefe işaret ediyor, elle kontrol et): #{mismatches.size} =="
mismatches.each { |path, current, expected| puts "  #{path}: mevcut=#{current} beklenen=#{expected}" }

puts
puts "== Çözülemeyen linkler (evergreen sayfada var ama karşılığı bulunamadı): #{unresolved.size} =="
unresolved.each { |path, link| puts "  #{path} -> #{link}" }

if FIX && to_fix.any?
  puts
  puts "== Düzeltiliyor... =="
  to_fix.each do |path, url|
    text = File.read(path, encoding: 'utf-8')
    raise "front matter bulunamadı: #{path}" unless text.start_with?("---\n")

    close_idx = text.index("\n---", 4)
    raise "front matter kapanışı bulunamadı: #{path}" unless close_idx

    insertion_point = close_idx + 1
    new_text = text[0...insertion_point] + "archived_to: \"#{url}\"\n" + text[insertion_point..]
    File.write(path, new_text, encoding: 'utf-8')
    puts "  yazildi: #{path}"
  end
end

# --- Evergreen karsiligi olmayan olasi tekrarlanan seriler ---

def normalize_title(title)
  t = title.to_s.downcase
  t = t.gsub(/\b(19|20)\d{2}\b/, '')      # yil
  t = t.gsub(/\b\d+\s*\.?\s*(inci|ıncı|üncü|uncu|nci)\b/, '') # sirali sayilar (7.,7'inci)
  t = t.gsub(/[^\p{L}\p{N}]+/, ' ').strip
  t.split.sort.join(' ')
end

non_evergreen = site.posts.docs.reject { |doc| doc.relative_path.start_with?('_posts/evergreen/') }

groups = Hash.new { |h, k| h[k] = [] }
non_evergreen.each do |doc|
  organizer = doc.data['organizer'].to_s.strip.downcase
  next if organizer.empty?
  key = [organizer, normalize_title(doc.data['title'])]
  groups[key] << doc
end

candidates = groups.select { |_, docs| docs.size >= 2 }

puts
puts "== Evergreen karsiligi olmayan olasi tekrarlanan seriler: #{candidates.size} =="
candidates.each do |(organizer, _), docs|
  already_archived = docs.all? { |d| d.data['archived_to'] }
  next if already_archived
  sorted = docs.sort_by { |d| d.data['lastDate'].to_i }
  puts "  [#{organizer}] #{sorted.map { |d| "#{d.data['title']} (#{d.relative_path})" }.join(' | ')}"
end
