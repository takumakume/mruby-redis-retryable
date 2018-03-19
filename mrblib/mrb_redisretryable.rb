class Redis
  class Retryable
    attr_accessor :retry_times, :retry_duration

    def initialize(host, port, timeout = 1)
      @host = host
      @port = port
      @timeout = timeout
      @retry_times = 3
      @retry_sleep = 1 # 1s
      @client = Redis.new(@host, @port, @timeout)
    end

    def method_missing(method, *args)
      try = 0
      begin
        @client = Redis.new(@host, @port, @timeout) if try > 0
        @client.send(method, *args)
      rescue => e
        if e.class == Redis::ConnectionError
          if try < @retry_times
            try += 1
            Sleep::sleep(@retry_sleep)
            retry
          else
            raise Redis::Retryable::RetryError, "Redis#{method} try #{@retry_times} times faild."
          end
        end
        raise e
      end
    end
  end
end
