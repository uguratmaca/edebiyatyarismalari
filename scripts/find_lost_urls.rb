# Evergreen dönüşümlerinde bazı postlar, eski dosyaları archived_to ile
# arşivlemek yerine doğrudan yeniden adlandırılarak (git rename) evergreen'e
# taşındı. Bu durumda o dosyanın o ana kadar kullandığı permalink'ler siteden
# tamamen kayboluyor (bkz. hasibe-ayten-siir-odulu-2025, dr-kamil-furtun-
# oyku-yarismasi-2026, millet-dernegi-duzyazi-yarismasi-2025, sukru-bilgic-
# oyku-odulu-2025 vakaları).
#
# Bu script her evergreen dosyanın git geçmişini (rename'ler dahil) tarar,
# o dosyanın bugüne kadar front matter'da kullandığı tüm permalink'leri
# toplar ve hangilerinin artık hiçbir canlı post tarafından kullanılmadığını
# (yani 404 verdiğini) raporlar.
#
# Kullanım:
#   bundle exec ruby scripts/find_lost_urls.rb

require 'jekyll'

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

findings = []

evergreen_docs.each do |doc|
  current_path = doc.relative_path
  log = `git log --follow --name-status --format="COMMIT %H" -- "#{current_path}"`
  next if log.strip.empty?

  path_for_commit = {}
  segment_path = current_path
  commit = nil

  log.each_line do |line|
    line = line.rstrip
    if line =~ /^COMMIT (\w+)/
      commit = $1
      path_for_commit[commit] = segment_path
    elsif line =~ /^R\d+\s+(\S+)\s+(\S+)/
      old_path = $1
      segment_path = old_path
    end
  end

  historical_permalinks = {}
  path_for_commit.each do |c, path|
    content = `git show #{c}:"#{path}" 2>nul`
    next if content.strip.empty?
    perm = extract_permalink(content)
    next unless perm
    historical_permalinks[normalize(perm)] ||= []
    historical_permalinks[normalize(perm)] << c
  end

  current_url = doc.url
  lost = historical_permalinks.keys.reject do |url|
    url == current_url || live_permalinks.key?(url)
  end

  next if lost.empty?

  findings << { path: current_path, current_url: current_url, lost: lost }
end

puts "== Evergreen postlarda kaybolmuş olabilecek eski permalink'ler: #{findings.size} =="
puts
findings.each do |f|
  puts "#{f[:path]} (güncel: #{f[:current_url]})"
  f[:lost].each { |url| puts "  KAYIP: #{url}" }
  puts
end

puts "Not: Bu bir aday listesidir. Her biri elle kontrol edilmeli (bazı permalink'ler" \
     " kasıtlı olarak değiştirilmiş/hiç yayınlanmamış olabilir)."
