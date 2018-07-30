require 'jekyll-polyglotter'

Gem::Specification.new do |s|
  s.required_ruby_version = ">= 2.1.0"

  s.name        = 'jekyll-polyglotter'
  s.version     = Jekyll::Polyglotter::VERSION
  s.license     = 'MIT'

  s.version     = "#{s.version}-alpha-#{ENV['TRAVIS_BUILD_NUMBER']}" if ENV['TRAVIS']
#  s.date        = '2018-07-30'
  s.summary     = 'I18n plugin for Jekyll Blogs'
  s.description = 'Fast open source i18n plugin for Jekyll blogs.'

  s.authors     = ['Samuel Volin', 'Tnarik Innael']
  s.email       = 'tnarik@lecafeautomatique.co.uk'

  s.files       = ['README.md', 'LICENSE.txt'] + Dir['lib/**/*']
  s.homepage    = 'https://github.com/tnarik/polyglotter'

  s.add_runtime_dependency('jekyll', '~> 3')
end
