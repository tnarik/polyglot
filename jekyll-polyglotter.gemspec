Gem::Specification.new do |s|
  s.name        = 'jekyll-polyglotter'
  s.version     = '1.4.0'
  s.date        = '2018-07-30'
  s.summary     = 'I18n plugin for Jekyll Blogs'
  s.description = 'Fast open source i18n plugin for Jekyll blogs.'
  s.authors     = ['Samuel Volin', 'Tnarik Innael']
  s.email       = 'tnarik@lecafeautomatique.co.uk'
  s.files       = ['README.md', 'LICENSE.txt'] + Dir['lib/**/*']
  s.homepage    = 'https://github.com/tnarik/polyglotter'
  s.license     = 'MIT'
  s.add_runtime_dependency('jekyll', '>= 3.0')
end
