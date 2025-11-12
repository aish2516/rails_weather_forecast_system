class Rack::Attack
  throttle("requests by ip", limit: 5, period: 60.seconds) do |req|
    req.ip
  end
end