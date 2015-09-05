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
    CONCURRENCY = 4

    def initialize
      @queue = Queue.new
      @pool  = ThreadPool.new(1, 4) do |params|
        #handle(*params)
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

    def handle(*job)
      i = 0
      1000000.times do |t|
        i+=1
      end
      i
    end

    def handle2(job)
      random_comic_url = []
      case job
        when "test1"
          response = Net::HTTP.get_response('dynamic.xkcd.com', '/random/comic/')
          random_comic_url = response['Location']
        when "test2"
          response = Net::HTTP.get_response('dynamic.xkcd.com', '/random/comic/')
          random_comic_url = response['Location']
        when "test3"
          response = Net::HTTP.get_response('dynamic.xkcd.com', '/random/comic/')
          random_comic_url = response['Location']
        when "test4"
          response = Net::HTTP.get_response('dynamic.xkcd.com', '/random/comic/')
          random_comic_url = response['Location']
        when "test5"
          response = Net::HTTP.get_response('dynamic.xkcd.com', '/random/comic/')
          random_comic_url = response['Location']
        when "test6"
          response = Net::HTTP.get_response('dynamic.xkcd.com', '/random/comic/')
          random_comic_url = response['Location']
        when "test7"
          response = Net::HTTP.get_response('dynamic.xkcd.com', '/random/comic/')
          random_comic_url = response['Location']
        when "test8"
          response = Net::HTTP.get_response('dynamic.xkcd.com', '/random/comic/')
          random_comic_url = response['Location']
        when "test9"
          response = Net::HTTP.get_response('dynamic.xkcd.com', '/random/comic/')
          random_comic_url = response['Location']
        when "test10"
          response = Net::HTTP.get_response('dynamic.xkcd.com', '/random/comic/')
          random_comic_url = response['Location']
        when "test11"
          response = Net::HTTP.get_response('dynamic.xkcd.com', '/random/comic/')
          random_comic_url = response['Location']
        when "test12"
          response = Net::HTTP.get_response('dynamic.xkcd.com', '/random/comic/')
          random_comic_url = response['Location']

        end
       return random_comic_url
    end
  end
end