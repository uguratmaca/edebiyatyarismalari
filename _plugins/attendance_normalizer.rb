# Front matter `attendance` values are free text ("E-Posta", "E-posta", "Websitesi",
# "Kargo/Posta/Elden", "Posta ya da Elden" ...) with ~170 distinct spellings across
# the posts. This filter buckets them into a fixed set of categories so they can be
# used as a filter facet (a post can belong to more than one category at once).
module Jekyll
  module AttendanceNormalizerFilter
    EPOSTA_PATTERN = /e[\s\-]?post\w*|e[\s\-]?mail/.freeze

    OTHER_CATEGORIES = {
      "Online/Web Sitesi" => /web ?sitesi|wesitesi|online|internet sitesi|e-?devlet|çevrimiçi/,
      "Kargo/Posta" => /kargo|posta|ptt|aps\b/,
      "Elden" => /elden|şahsen|yüz ?yüze|teslim/,
      "Okul/Kurum" => /okul|müdürl|müftül|milli eğitim|öğretmen|veli|kurum|danışman|konsoloslu|bilgi evi|gençlik merkezi/,
      "Sosyal Medya" => /instagram|facebook|twitter|whatsapp|telegram|sosyal medya|mesaj/
    }.freeze

    def normalize_attendance(input)
      return [] if input.nil? || input.to_s.strip.empty?

      text = input.to_s.gsub("İ", "i").downcase
      matched = []

      # "e-posta" contains "posta", so it must be matched and stripped first —
      # otherwise every email-only submission would also match Kargo/Posta.
      if text =~ EPOSTA_PATTERN
        matched << "E-posta"
        text = text.gsub(EPOSTA_PATTERN, "")
      end

      OTHER_CATEGORIES.each { |name, regex| matched << name if text =~ regex }
      matched.empty? ? ["Diğer"] : matched
    end
  end
end

Liquid::Template.register_filter(Jekyll::AttendanceNormalizerFilter)
