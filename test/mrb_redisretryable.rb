##
## Redis::Retryable Test
##

HOST         = "127.0.0.1"
PORT         = 6999

assert("Redis.new can not reconnect") do
  pid = Process.fork() {
    Exec.execv("/bin/bash", "-l", "-c", "redis-server --port #{PORT} &")
  }
  Process.waitpid pid
  Sleep::sleep(1)

  r = Redis.new HOST, PORT
  assert_equal "PONG", r.ping
  r.close

  r = Redis.new HOST, PORT

  pid = Process.fork() {
    Exec.execv("/bin/bash", "-l", "-c", "redis-cli -p #{PORT} shutdown")
  }
  Process.waitpid pid
  Sleep::sleep(1)

  pid = Process.fork() {
    Exec.execv("/bin/bash", "-l", "-c", "redis-server --port #{PORT} &")
  }
  Process.waitpid pid
  Sleep::sleep(1)

  begin
    r.ping
  rescue => e
    assert_equal Redis::ConnectionError, e.class
  end

  pid = Process.fork() {
    Exec.execv("/bin/bash", "-l", "-c", "redis-cli -p #{PORT} shutdown")
  }
  Process.waitpid pid
  Sleep::sleep(1)
end

assert("Redis::Retryable.new can reconnect") do
  pid = Process.fork() {
    Exec.execv("/bin/bash", "-l", "-c", "redis-server --port #{PORT} &")
  }
  Process.waitpid pid
  Sleep::sleep(1)

  r = Redis::Retryable.new HOST, PORT
  assert_equal "PONG", r.ping
  r.close

  r = Redis::Retryable.new HOST, PORT

  pid = Process.fork() {
    Exec.execv("/bin/bash", "-l", "-c", "redis-cli -p #{PORT} shutdown")
  }
  Process.waitpid pid
  Sleep::sleep(1)

  pid = Process.fork() {
    Exec.execv("/bin/bash", "-l", "-c", "redis-server --port #{PORT} &")
  }
  Process.waitpid pid
  Sleep::sleep(1)

  assert_equal "PONG", r.ping
  r.close

  pid = Process.fork() {
    Exec.execv("/bin/bash", "-l", "-c", "redis-cli -p #{PORT} shutdown")
  }
  Process.waitpid pid
  Sleep::sleep(1)
end

assert("If Redis is stopped, Redis::Retryable raise Redis::Retryable::RetryError") do
  pid = Process.fork() {
    Exec.execv("/bin/bash", "-l", "-c", "redis-server --port #{PORT} &")
  }
  Process.waitpid pid
  Sleep::sleep(1)

  r = Redis::Retryable.new HOST, PORT

  pid = Process.fork() {
    Exec.execv("/bin/bash", "-l", "-c", "redis-cli -p #{PORT} shutdown")
  }
  Process.waitpid pid
  Sleep::sleep(1)

  begin
    r.ping
  rescue => e
    assert_equal Redis::Retryable::RetryError, e.class
  end
end
