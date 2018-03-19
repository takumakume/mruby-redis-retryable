##
## RedisRetryable Test
##

HOST         = "127.0.0.1"
PORT         = 6999

assert("RedisRetryable") do
  pid = Process.fork() {
    Exec.execv("/bin/bash", "-l", "-c", "redis-server --port #{PORT} &")
  }

  r = RedisRetryable.new HOST, PORT
  assert_equal "PONG", r.ping
  r.close

  r = RedisRetryable.new HOST, PORT

  pid = Process.fork() {
    Exec.execv("/bin/bash", "-l", "-c", "redis-cli -p #{PORT} shutdown")
  }
  Process.waitpid pid

  pid = Process.fork() {
    Exec.execv("/bin/bash", "-l", "-c", "redis-server --port #{PORT} &")
  }

  assert_equal "PONG", r.ping
  r.close

  pid = Process.fork() {
    Exec.execv("/bin/bash", "-l", "-c", "redis-cli -p #{PORT} shutdown")
  }
  Process.waitpid pid
end
