MRuby::Build.new do |conf|
  toolchain :gcc
  conf.gembox 'default'
  conf.gem github: 'pyama86/mruby-io'
  conf.gem github: 'iij/mruby-process'
  conf.gem github: 'matsumoto-r/mruby-redis'
  conf.gem github: 'matsumoto-r/mruby-sleep'
  conf.gem github: 'haconiwa/mruby-exec'
  conf.gem File.expand_path(File.dirname(__FILE__))
  conf.enable_test
end
