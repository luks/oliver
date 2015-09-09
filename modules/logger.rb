require 'logger'

module Logging
  def self.included(base)
    class << base
      def logger
        @logger ||= Logger.new('/home/luky/Documents/ruby/wwrt-ebook/code/oliver/log/oliver.log')
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