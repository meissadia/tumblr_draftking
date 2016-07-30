require_relative 'lib/draftking/version'

Gem::Specification.new do |s|
  s.name           = 'tumblr_draftking'
  s.version        = DK::VERSION
  s.authors        = ['Meissa Dia']
  s.email          = ['meissadia@gmail.com']
  s.homepage       = 'https://github.com/meissadia/tumblr_draftking'
  s.license        = 'Apache'
  s.date           = Date.today.to_s

  s.summary        = 'Take the hassle out of managing your tumblr account!'
  s.description    = %(
  Automate a number of tasks for your tumblr Drafts and Queue such as: tagging, stripping
  previous comments and moving Drafts to your Queue.  Visit the homepage for information on
  the latest release or to file a bug report!
  )

  s.files          = Dir.glob('{bin,lib}/**/*') + ['README.md', 'LICENSE', '.yardopts', 'Rakefile']
  s.executables    = s.files.grep(%r{^bin/}).map { |f| File.basename(f) }
  s.test_files     = s.files.grep(%r{^(test|spec|features)/})
  s.require_paths  = ['lib']

  s.platform       = Gem::Platform.local
  s.required_ruby_version = '>= 2.1.0'
  s.add_runtime_dependency     'tumblr_client', '~> 0.8.5'
  s.add_runtime_dependency     'psych', '2.0.8'
  s.add_development_dependency 'minitest', '~>5.9'
  s.add_development_dependency 'rake', '~> 10.4'
end
