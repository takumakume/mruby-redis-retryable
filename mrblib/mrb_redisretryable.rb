class RedisRetryable
  def initialize(host, port, timeout = 1)
    @host = host
    @port = port
    @timeout = timeout
    @retry_duration = 3000000 # 3s
    @client = Redis.new(@host, @port, @timeout)
  end

  def method_missing(method, *args)
    begin
      @client.send(method, *args)
    rescue => e
      if e.class == Redis::ConnectionError
        Sleep::usleep(@retry_duration)
        @client = Redis.new(@host, @port, @timeout)
        @client.send(method, *args)
      end
    end
  end
end
