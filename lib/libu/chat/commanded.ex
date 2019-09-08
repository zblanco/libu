defmodule Libu.Chat.Commanded do
  use Commanded.Application,
    otp_app: :libu

  router Libu.Chat.Router
end
