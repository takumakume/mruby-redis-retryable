class RedisRetryable
  def initialize(host, port, timeout = 1)
    @host = host
    @port = port
    @timeout = timeout
    @client = Redis.new(@host, @port, @timeout)
  end

  def method_missing(method, *args)
    begin
      @client.send(method, *args)
    rescue => e
      if e.class == Redis::ConnectionError
        puts "!!!!!!!"
        Sleep::sleep(3)
        @client = Redis.new(@host, @port, @timeout)
        @client.send(method, *args)
      end
    end
  end
end
