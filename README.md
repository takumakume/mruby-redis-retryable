# mruby-redis_retryable   [![Build Status](https://travis-ci.org/k1low/mruby-redis_retryable.svg?branch=master)](https://travis-ci.org/k1low/mruby-redis_retryable)
RedisRetryable class
## install by mrbgems
- add conf.gem line to `build_config.rb`

```ruby
MRuby::Build.new do |conf|

    # ... (snip) ...

    conf.gem :github => 'k1low/mruby-redis_retryable'
end
```
## example
```ruby
p RedisRetryable.hi
#=> "hi!!"
t = RedisRetryable.new "hello"
p t.hello
#=> "hello"
p t.bye
#=> "hello bye"
```

## License
under the MIT License:
- see LICENSE file
