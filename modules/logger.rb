module Logging
  def self.included(base)
    class << base
      def logger
        @logger ||= Logger.new(ENV['LOG_TO'])
      end

      def logger=(logger)
        @logger = logger
      end
    end
  end

  def logger
    self.class.logger
  end
end