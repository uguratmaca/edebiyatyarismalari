# jekyll-last-modified-at spawns one `git log` subprocess per post/page
# (2000+ posts here), which dominates build time. This does the same lookup
# with a single `git log` call for the whole repo, cached per build.
module Jekyll
  module FastLastModifiedAt
    class << self
      def lookup(site_source)
        @lookup ||= {}
        @lookup[site_source] ||= build_lookup(site_source)
      end

      def build_lookup(site_source)
        table = {}
        timestamp = nil

        Dir.chdir(site_source) do
          IO.popen(["git", "log", "--name-only", "--no-renames", "--pretty=format:%x00%ct"]) do |io|
            io.each_line do |line|
              line.chomp!
              next if line.empty?

              if line.start_with?("\0")
                timestamp = line.delete_prefix("\0").to_i
              else
                table[line] ||= timestamp
              end
            end
          end
        end

        table
      rescue Errno::ENOENT, IOError
        table
      end

      def for_item(item)
        table = lookup(item.site.source)
        unix_time = table[item.relative_path]
        unix_time ||= File.mtime(item.path).to_i if File.exist?(item.path)
        unix_time ||= Time.now.to_i
        Time.at(unix_time)
      end
    end

    def self.add_hook
      proc { |item| item.data["last_modified_at"] = FastLastModifiedAt.for_item(item) }
    end

    Jekyll::Hooks.register(:posts, :post_init, &add_hook)
    Jekyll::Hooks.register(:pages, :post_init, &add_hook)
    Jekyll::Hooks.register(:documents, :post_init, &add_hook)
  end
end
