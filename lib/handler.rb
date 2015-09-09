require 'benchmark'
require 'thread'
require 'net/http'
require "modules/logger"
require "lib/thread_pool"
require "workers/test"


module Oliver
  class Handler
    include Logging
    attr_accessor :pool

    def initialize
      @pool  = ThreadPool.new(1, 4) do |params|
        Thread.abort_on_exception=true
        a, b = params.split(":")
        par = b.split(" ")
        worker = Object.const_get(a).new
        method = par.shift

        bench = Benchmark.measure {
          begin
            if par.empty?
              logger.info worker.send(method)
            else
              logger.info worker.send(method, *par)
            end
          rescue => e
            logger.error e.message
            e.backtrace.each do |err|
              logger.debug err
            end
          end
        }
        logger.info "Job #{a}:#{method}:#{par} done in #{'%.3f' % bench.real} secs (#{'%.3f' % bench.utime} user/#{'%.3f' % bench.stime} system)"
      end
      @pool.auto_trim!
      @pool.auto_reap!
    end

  end
end