module Jekyll

  # Monkey patched to unify the title (remove the language token suffix if there is any)
  # The language token comes from the Front Matter or the default language
  class Document
    def lang
      data[site.lang_field] || site.default_lang
    end

    alias_method :read_post_data_orig, :read_post_data
    def read_post_data
      read_post_data_orig
      site.page_lang_vars.each do |v|
        data[v] ||= lang
      end
    end

    def title_url_regex
      # File basename matching .{language} -{language} {language}. {language}-
      regex = "([\.\-]#{lang}[\.\-]?)|([\.\-]?#{lang}[\.\-])"
      %r{#{regex}}
    end

    def path_url_regex
      # Path like bar/{language}/foo , bar.{language}/foo, bar/{language}/fu/foo, bar.{language}/fu/foo
      regex = "([\/\.]#{lang}[\/]?)"
      %r{#{regex}}
    end

    def url
      unified_title = url_placeholders['title'].gsub(title_url_regex, '')
      unified_path = url_placeholders['path'].gsub(path_url_regex, '')

      @url ||= URL.new({
        :template     => url_template,
        :placeholders => url_placeholders.to_h.merge({ 'path' => unified_path, 'title' => unified_title }),
        :permalink    => permalink,
      }).to_s
    end
  end
end