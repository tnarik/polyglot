include Process
module Jekyll
  class Site
    attr_reader :default_lang, :languages, :exclude_from_localization, :lang_vars, :lang_field, :page_lang_vars
    attr_accessor :file_langs, :active_lang

    def prepare
      @file_langs = {}
      fetch_languages
      @parallel_localization = config.fetch('parallel_localization', true)
      @exclude_from_localization = config.fetch('exclude_from_localization', [])
      @isolate_languages = config.fetch('isolate_languages', false)
      @all_docs = {}
      @lang_field = config.fetch('lang_field', 'lang')

    end

    def fetch_languages
      @default_lang = config.fetch('default_lang', 'en')
      @languages = config.fetch('languages', ['en'])
      @keep_files += (@languages - [@default_lang])
      @active_lang = @default_lang
      @lang_vars = config.fetch('lang_vars', [])
      @page_lang_vars = config.fetch('page_lang_vars', [])
    end

    alias_method :process_orig, :process
    def process
      prepare
      all_langs = (@languages + [@default_lang]).uniq
      if @parallel_localization
        pids = {}
        all_langs.each do |lang|
          pids[lang] = fork do
            process_language lang
          end
        end
        Signal.trap('INT') do
          all_langs.each do |lang|
            puts "Killing #{pids[lang]} : #{lang}"
            kill('INT', pids[lang])
          end
        end
        all_langs.each do |lang|
          waitpid pids[lang]
          detach pids[lang]
        end
      else
        all_langs.each do |lang|
          process_language lang
        end
      end
    end


    # Unified configuration
    def description
      if config.fetch('description', '').is_a?(Hash)
        @description ||= config['description'].has_key?(active_lang)? config['description'][active_lang] : config['description'][@default_lang]
      else
        @description ||= config.fetch('description', '')
      end
    end

    def title
      if config.fetch('title', '').is_a?(Hash)
        @title ||= config['title'].has_key?(active_lang)? config['title'][active_lang] : config['title'][@default_lang]
      else
        @title ||= config.fetch('title', '')
      end
    end

    # This allows injecting runtime 'config values' (or site.* liquid tags)
    alias_method :site_payload_orig, :site_payload
    def site_payload
      payload = site_payload_orig
      payload['site']['default_lang'] = default_lang
      payload['site']['languages'] = languages
      payload['site']['active_lang'] = active_lang
      payload['site']['all_docs'] = @all_docs

      payload['site']['description'] = description
      payload['site']['title'] = title

      lang_vars.each do |v|
        payload['site'][v] = active_lang
      end
      payload
    end

    def process_language(lang)
      @active_lang = lang
      config['active_lang'] = @active_lang
      lang_vars.each do |v|
        config[v] = @active_lang
      end
      if @active_lang == @default_lang
      then process_default_language
      else process_active_language
      end
    end

    def process_default_language
      old_include = @include
      process_orig
      @include = old_include
    end

    def process_active_language
      old_dest = @dest
      old_exclude = @exclude
      @file_langs = {}
      @dest = @dest + '/' + @active_lang
      @exclude += @exclude_from_localization
      process_orig
      @dest = old_dest
      @exclude = old_exclude
    end

    # assigns natural permalinks to documents and cascades prioritizing documents with
    # active_lang languages (except for, optionally, posts and HTML pages)
    def coordinate_documents(docs)
      approved = {}
      docs.each do |doc|
        lang = doc.data[@lang_field] || @default_lang
        @all_docs[doc.url] ||= []
        @all_docs[doc.url] << lang
        @all_docs[doc.url].uniq!
        @all_docs[doc.url].sort!

        if @isolate_languages
          # posts/HTML pages are only approved for the active language (no mixing of languages)
          next if (doc.is_a?(Jekyll::Document) || doc.is_a?(Jekyll::Page) && doc.html? ) && lang != @active_lang
        end
        # otherwise use whatever we have, giving priority to the default and active languages
        next if @file_langs[doc.url] == @active_lang
        next if @file_langs[doc.url] == @default_lang && lang != @active_lang
        approved[doc.url] = doc
        @file_langs[doc.url] = lang
      end
      approved.values
    end

    # performs any necessary operations on the documents before rendering them
    def process_documents(docs)
      # Inject the language token in the URLs (except for the default language)
      unless @active_lang == @default_lang
        url = config.fetch('url', false)
        rel_regex = relative_url_regex
        abs_regex = absolute_url_regex(url)
        docs.each do |doc|
          relativize_urls(doc, rel_regex)
          if url
          then relativize_absolute_urls(doc, abs_regex, url)
          end
        end
      end

      # Remove the language token for the default languages
      rel_regex = relative_url_regex([@default_lang])
      abs_regex = absolute_url_regex(url, [@default_lang])
      docs.each do |doc|
        unrelativize_urls(doc, rel_regex)
        if url
        then unrelativize_absolute_urls(doc, abs_regex, url)
        end
      end
    end

    # a regex that matches relative urls in a html document
    # matches href="baseurl/foo/bar-baz" and others like it
    # avoids matching excluded files
    def relative_url_regex(langs = [])
      exclude_regex = ''
      (@exclude + @languages.reject { |l| langs.include?(l) }).each do |x|
        exclude_regex += "(?!#{x}\/)"
      end

      strip_regex = ''
      langs.each do |x|
        strip_regex += "(?:#{x}\/)?"
      end

      %r{href=\"?#{@baseurl}\/#{strip_regex}((?:#{exclude_regex}[^,'\"\s\/?\.#]+\.?)*(?:\/[^\]\[\)\(\"\'\s]*)?)\"}
    end

    def absolute_url_regex(url, langs = [])
      exclude_regex = ''
      (@exclude + @languages.reject { |l| langs.include?(l) }).each do |x|
        exclude_regex += "(?!#{x}\/)"
      end

      strip_regex = ''
      langs.each do |x|
        strip_regex += "(?:#{x}\/)?"
      end

      %r{href=\"?#{url}#{@baseurl}\/#{strip_regex}((?:#{exclude_regex}[^,'\"\s\/?\.#]+\.?)*(?:\/[^\]\[\)\(\"\'\s]*)?)\"}
    end

    def relativize_urls(doc, regex)
      doc.output.gsub!(regex, "href=\"#{@baseurl}/#{@active_lang}/" + '\1"')
    end

    def relativize_absolute_urls(doc, regex, url)
      doc.output.gsub!(regex, "href=\"#{url}#{@baseurl}/#{@active_lang}/" + '\1"')
    end

    def unrelativize_urls(doc, regex)
      doc.output.gsub!(regex, "href=\"#{@baseurl}/" + '\1"')
    end

    def unrelativize_absolute_urls(doc, regex, url)
      doc.output.gsub!(regex, "href=\"#{url}#{@baseurl}/" + '\1"')
    end

  end
end
