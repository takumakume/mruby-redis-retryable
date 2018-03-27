class Redis
  class Retryable
    attr_accessor :tries, :sleep

    def initialize(host, port, timeout = 1)
      @host = host
      @port = port
      @timeout = timeout
      @tries = 3
      @sleep = 1 # 1s
      @pass = nil
      @client = Redis.new(@host, @port, @timeout)
    end

    def auth(pass)
      @pass = pass
      @client.send(:auth, pass)
    end

    def exec
      method_missing(:exec)
    end

    def method_missing(method, *args)
      try = 0
      begin
        @client = Redis.new(@host, @port, @timeout) if try > 0
        @client.send('auth', @pass) if @pass
        @client.send(method, *args)
      rescue => e
        if e.class == Redis::ConnectionError
          if try < @tries
            try += 1
            Sleep::sleep(@sleep)
            retry
          else
            raise Redis::Retryable::RetryError, "Redis##{method} try #{@tries} times faild. \"#{e.message}\""
          end
        end
        raise e
      end
    end
  end
end
