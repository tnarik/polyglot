module Jekyll

  # Monkey patched to unify the title (remove the language token suffix if there is any)
  # The language token comes from the Front Matter or the default language
  class Page
    def lang
      data[site.lang_field] || site.default_lang
    end

    def title_url_regex
      # File basename matching .{language} -{language} {language}. {language}-
      regex = "([\.\-]#{lang}[\.\-]?)|([\.\-]?#{lang}[\.\-])"
      %r{#{regex}}
    end

    def path_url_regex
      # Path like /{language}/foo , .{language}/foo
      regex = "([\/\.]#{lang}[\/]?)"
      %r{#{regex}}
    end

    def url
      unified_title = url_placeholders[:basename].gsub(title_url_regex, '')
      unified_path = url_placeholders[:path].gsub(path_url_regex, '')

      @url ||= URL.new({
        :template     => template,
        :placeholders => url_placeholders.merge({ path: unified_path, basename: unified_title }),
        :permalink    => permalink,
      }).to_s
    end
  end
end