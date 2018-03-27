##
## Redis::Retryable Test
##

HOST         = "127.0.0.1"
PORT         = 6998
SECURED_PORT = 6999

assert("Redis.new can not reconnect") do
  # 1. Start redis-server
  pid = Process.fork() {
    Exec.execv("/bin/bash", "-l", "-c", "redis-server --port #{PORT} &")
  }
  Process.waitpid pid
  Sleep::sleep(1)

  # 2. Redis.new
  r = Redis.new HOST, PORT
  assert_equal "PONG", r.ping

  # 3. Stop and Start redis-server
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

  # 4. Raise error
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
  # 1.
  pid = Process.fork() {
    Exec.execv("/bin/bash", "-l", "-c", "redis-server --port #{PORT} &")
  }
  Process.waitpid pid
  Sleep::sleep(1)

  # 2.
  r = Redis::Retryable.new HOST, PORT
  assert_equal "PONG", r.ping

  # 3.
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

  # 4.
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

assert("Redis::Retryable.new can re-auth") do
  # 1.
  pid = Process.fork() {
    Exec.execv("/bin/bash", "-l", "-c", "redis-server --port #{SECURED_PORT} --requirepass 'secret' &")
  }
  Process.waitpid pid
  Sleep::sleep(1)

  # 2.
  r = Redis::Retryable.new HOST, SECURED_PORT
  assert_equal r.auth("secret"), "OK"
  assert_equal "PONG", r.ping

  # 3.
  pid = Process.fork() {
    Exec.execv("/bin/bash", "-l", "-c", "redis-cli -p #{SECURED_PORT} -a secret shutdown")
  }
  Process.waitpid pid
  Sleep::sleep(1)
  pid = Process.fork() {
    Exec.execv("/bin/bash", "-l", "-c", "redis-server --port #{SECURED_PORT} --requirepass 'secret' &")
  }
  Process.waitpid pid
  Sleep::sleep(1)

  # 4.
  assert_equal "PONG", r.ping
  r.close

  pid = Process.fork() {
    Exec.execv("/bin/bash", "-l", "-c", "redis-cli -p #{SECURED_PORT} -a secret shutdown")
  }
  Process.waitpid pid
  Sleep::sleep(1)
end
