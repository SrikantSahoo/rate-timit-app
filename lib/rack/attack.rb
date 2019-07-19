module Rack
  class Attack
    attr_reader :app
    attr_reader :rule

    def initialize(app)
      @app = app
      @rule = YAML.load_file("#{Rails.root}/config/limit-rules.yml")[Rails.env]
    end

    def call(env)
      request = Rack::Request.new(env)
      client_ip env['REMOTE_ADDR']
      allowed?(request) ? block_request(request) : app.call(env)
    end

    private

    def client_ip(ip=nil)
      @client_ip ||= ip
    end

    def allowed?(request)
      REDIS.exists("request_count:#{client_ip}") ? true : track_request(request)
    rescue
      Rails.logger.warn 'Unable to access Redis!'
      false
    end

    def throttle(request)
      REDIS.multi do
        REDIS.set("request_count:#{client_ip}", true, ex: rule['timespan'])
        REDIS.del(client_ip)
      end
    end

    def track_request(request)
      rate = REDIS.pipelined do
        REDIS.incr(client_ip)
        REDIS.expire(client_ip, rule['timespan'])
        REDIS.get(client_ip)
      end.last.to_i

      throttle(request) if rate >= rule['max_requests']
      
      false
    end

    def block_request(request)
      time_left = REDIS.ttl("request_count:#{client_ip}")
      [429, {}, ["Rate limit exceeded. Try again in #{time_left} seconds."]]
    end
  end
end