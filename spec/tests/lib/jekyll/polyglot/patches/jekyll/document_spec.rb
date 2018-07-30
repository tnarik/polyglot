require 'rspec/helper'
require 'ostruct'
# rubocop:disable BlockLength, LineLength
describe Document do
  before do
    @config = Jekyll::Configuration::DEFAULTS.dup
    @langs = ['en', 'sp', 'fr', 'de']
    @default_lang = 'en'
    @exclude_from_localization = ['javascript', 'images', 'css']
    @config['langs'] = @langs
    @config['default_lang'] = @default_lang
    @config['exclude_from_localization'] = @exclude_from_localization
    @parallel_localization = @config['parallel_localization'] || true
    @site = Site.new(
      Jekyll.configuration(
        'languages'                 => @langs,
        'default_lang'              => @default_lang,
        'exclude_from_localization' => @exclude_from_localization,
        'source'                    => fixtures_path
      )
    )
    @site.prepare
    @document = Document.new(@site.in_source_dir('_posts/2001-01-01-post.md'),
                 :site       => @site,
                 collection: @site.posts).tap(&:read)

    @title_url_regex = @document.title_url_regex
    @path_url_regex = @document.path_url_regex
  end

  describe @title_url_regex do
    it 'must match common filenames documented' do
      @langs.each do |lang|
        expect match "/foobar-#{lang}"
        expect match "foobar.#{lang}"
      end
    end
    it 'expect not match natural unfortunate urls' do
      expect(@title_url_regex).to_not match 'people/karen/foobaren/'
      expect(@title_url_regex).to_not match 'verbs/gasp/foobarsp'
      expect(@title_url_regex).to_not match 'products/kefr/foobarfr.html'
      expect(@title_url_regex).to_not match 'properties/beachside/foode'
    end
  end

  describe @path_url_regex do
    it 'must match common filenames documented' do
      @langs.each do |lang|
        expect match "/#{lang}/foobar-#{lang}"
        expect match "/#{lang}/foobar"
        expect match "/#{lang}.folder/foobar.#{lang}"
        expect match "/folder.#{lang}/foobar.#{lang}"
      end
    end
    it 'expect not match natural unfortunate urls' do
      expect(@path_url_regex).to_not match 'people/karen/'
      expect(@path_url_regex).to_not match 'people/karen/'
      expect(@path_url_regex).to_not match 'verbs/gasp/'
      expect(@path_url_regex).to_not match 'products/kefr/'
      expect(@path_url_regex).to_not match 'properties/beachside/foode'
    end
  end

end
