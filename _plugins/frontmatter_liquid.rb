# Allows Liquid tags (e.g. {{ site.year }}) inside page front matter values
# such as title/description/headline, so shared values like the current
# year only need to be updated in _config.yml.
Jekyll::Hooks.register :site, :pre_render do |site, payload|
  site.pages.each do |page|
    page.data.each do |key, value|
      next unless value.is_a?(String) && value.include?("{{")

      page.data[key] = Liquid::Template.parse(value).render!(payload)
    end
  end
end
