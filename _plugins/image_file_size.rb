# feed.xml's <enclosure> needs a real byte length — Mailchimp's *|RSSITEM:IMAGE|*
# merge tag appears to treat length="0" as an invalid enclosure and returns
# nothing. This precomputes each post's front-matter `image` file size at
# build time so feed.xml can emit an accurate length.
require "uri"

module Jekyll
  module ImageFileSize
    def self.for_item(item)
      image = item.data["image"]
      return nil if image.nil? || image.empty?

      path = URI.parse(image).path
      full_path = File.join(item.site.source, path)
      File.exist?(full_path) ? File.size(full_path) : nil
    rescue URI::InvalidURIError
      nil
    end

    Jekyll::Hooks.register(:site, :post_read) do |site|
      site.posts.docs.each do |post|
        post.data["image_bytes"] = ImageFileSize.for_item(post)
      end
    end
  end
end
