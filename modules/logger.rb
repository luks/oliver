require 'logger'


module Logging
  def self.included(base)
    class << base

      def logger
        file = open("/home/luky/Documents/ruby/wwrt-ebook/code/oliver/log/oliver.log", (File::WRONLY | File::APPEND | File::CREAT)); file.sync = true
        @logger ||= Logger.new(file)
        @logger.formatter = proc do |severity, datetime, progname, msg|
          #{}"#{severity} [#{datetime.strftime('%A %d/%m/%Y %H:%M:%S ')} ##{Process.pid} ##{Thread.current.object_id}]: #{msg}\n"
          "#{severity} #{datetime.strftime('%d/%m %H:%M:%S %L')}: #{msg}\n"
        end
        @logger
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