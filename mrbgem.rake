MRuby::Gem::Specification.new('mruby-redis-retryable') do |spec|
  spec.license = 'MIT'
  spec.authors = "Ken'ichiro Oyama"
  spec.add_dependency 'mruby-redis'

  spec.add_test_dependency 'mruby-io', github: "pyama86/mruby-io"
  spec.add_test_dependency 'mruby-process'
  spec.add_test_dependency 'mruby-print'
  spec.add_test_dependency 'mruby-exec'
end
