class Redis
  class Retryable
    def initialize(host, port, timeout = 1)
      @host = host
      @port = port
      @timeout = timeout
      @retry_times = 3
      @retry_duration = 1000000 # 1s
      @client = Redis.new(@host, @port, @timeout)
    end

    def method_missing(method, *args)
      try = 0
      begin
        try += 1
        @client.send(method, *args)
      rescue => e
        if e.class == Redis::ConnectionError
          if try < @retry_times
            Sleep::usleep(@retry_duration)
            @client = Redis.new(@host, @port, @timeout)
            retry
          # else
          #   raise Redis::Retryable::RetryError
          end
        end
        raise e
      end
    end
  end
end
