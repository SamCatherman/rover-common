module SNT
  module Webhook
    class Configuration
      attr_accessor :api_endpoint, :open_timeout, :read_timeout

      def self.defaults
        @defaults ||= {
          api_endpoint: "http://localhost:9001/webhooks/ping",
          open_timeout: 5,
          read_timeout: 5
        }
      end

      def initialize
        puts "INITIALIZING......."
        self.class.defaults.each do |key, value|
          puts "setting key: #{key} to val: #{value}"
          instance_variable_set("@#{key}", value)
        end
      end
    end

    def self.config
      puts "initializing......"
      @config ||= Configuration.new
    end

    def self.configure
      yield config
    end
  end
end
