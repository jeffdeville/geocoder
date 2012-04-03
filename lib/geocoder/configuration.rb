require 'socket'

module Geocoder
  class Configuration
    def self.local_ip
      orig, Socket.do_not_reverse_lookup = Socket.do_not_reverse_lookup, true  # turn off reverse DNS resolution temporarily

      UDPSocket.open do |s|
        s.connect '64.233.187.99', 1
        s.addr.last
      end
    ensure
      Socket.do_not_reverse_lookup = orig
    end


    def self.options_and_defaults
      [
        # geocoding service timeout (secs)
        [:timeout, 3],

        # name of geocoding service (symbol)
        [:lookup, :google],

        # ISO-639 language code
        [:language, :en],

        # use HTTPS for lookup requests? (if supported)
        [:use_https, false],

        # HTTP proxy server (user:pass@host:port)
        [:http_proxy, nil],

        # HTTPS proxy server (user:pass@host:port)
        [:https_proxy, nil],

        # API key for geocoding service
        # for Google Premier use a 3-element array: [key, client, channel]
        [:api_key, nil],

        # cache object (must respond to #[], #[]=, and #keys)
        [:cache, nil],

        # prefix (string) to use for all cache keys
        [:cache_prefix, "geocoder:"],

        # enforce a delay before each geocoding call to avoid hitting the google speed penalty
        [:rate_limit, 0.0],
        # google limits calls/sec/ip, so your cache will depend on the machine that is making the call. So the local_ip is used to give each machine it's own, independent lock
        [:local_ip, local_ip],

        # exceptions that should not be rescued by default
        # (if you want to implement custom error handling);
        # supports SocketError and TimeoutError
        [:always_raise, []]
      ]
    end

    # define getters and setters for all configuration settings
    self.options_and_defaults.each do |option, default|
      class_eval(<<-END, __FILE__, __LINE__ + 1)

        @@#{option} = default unless defined? @@#{option}

        def self.#{option}
          @@#{option}
        end

        def self.#{option}=(obj)
          @@#{option} = obj
        end

      END
    end
  end
end
