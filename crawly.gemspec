Gem::Specification.new do |s|
  s.name              = 'crawly'
  s.version           = '0.0.1'
  s.summary           = 'A small crawler for small needs.'
  s.description       = 'Super simple single domain crawler and sitemap builder'
  s.authors           = ['Daniele Spinosa']
  s.email             = ['info@microspino.com']
  s.homepage          = 'https://github.com/microspino/crawly'
  s.license           = 'MIT'
  s.date              = '2015-09-23'

  s.files = `git ls-files`.split("\n")

  s.executables << 'crawly'

  s.add_dependency 'builder'
  s.add_dependency 'redis'
  s.add_dependency 'oga'

  s.add_development_dependency 'minitest', '~> 4.7.3'
end