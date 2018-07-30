require 'rspec/helper'
require 'ostruct'
# rubocop:disable BlockLength, LineLength
describe Page do
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
    @page = Page.new(@site, @site.source, "", "page.md")

    @title_url_regex = @page.title_url_regex
    @path_url_regex = @page.path_url_regex
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
        expect match "/#{lang}/foobar"
        expect match "/#{lang}.foobar"
        expect match "/#{lang}.folder/foobar"
        expect match "/folder.#{lang}/foobar"
        expect match "/#{lang}"
        expect match "/foobar/#{lang}"
      end
    end
    it 'expect not match natural unfortunate urls' do
      expect(@path_url_regex).to_not match 'people/karen/'
      expect(@path_url_regex).to_not match 'verbs/gasp/'
      expect(@path_url_regex).to_not match 'products/kefr/'
      expect(@path_url_regex).to_not match 'properties/beachside/foode'
    end
  end

end
