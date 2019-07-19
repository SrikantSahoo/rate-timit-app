require "redis"

REDIS = Redis.new(Rails.application.config_for(:redis))

REDIS.flushdb if Rails.env.test?