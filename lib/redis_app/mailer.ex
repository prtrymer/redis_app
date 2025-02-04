defmodule RedisApp.Mailer do
  use Swoosh.Mailer, otp_app: :redis_app
end
