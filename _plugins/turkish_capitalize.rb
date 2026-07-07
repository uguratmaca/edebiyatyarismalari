# Liquid's built-in `capitalize` filter uppercases "i" as the ASCII dotless "I"
# and downcases the rest of the string. Neither behavior is what we want here:
# Turkish orthography requires the dotted "İ" (e.g. "ilkokul" -> "İlkokul", not
# "Ilkokul"), and some option labels are already intentionally mixed-case
# (e.g. "Online/Web Sitesi") so the remainder must be left untouched.
module Jekyll
  module TurkishCapitalizeFilter
    def tr_capitalize(input)
      text = input.to_s
      return text if text.empty?

      first = text[0] == "i" ? "İ" : text[0].upcase
      first + text[1..-1].to_s
    end
  end
end

Liquid::Template.register_filter(Jekyll::TurkishCapitalizeFilter)
