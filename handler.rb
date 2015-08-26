require 'benchmark'
require 'thread'
require 'net/http'
require_relative "modules/logger.rb"


module Oliver
  class Handler
    include Logging
    attr_accessor :queue, :workers
    CONCURRENCY = 4
    def initialize
      @queue = Queue.new
    end

    def spawn_workers
      workers = CONCURRENCY.times.map do
        Thread.new do
          begin
            while job = queue.pop
              logger.info handle(job)
            end
          rescue ThreadError => e
            logger.error "Thread error occured: #{e}"
          end
        end
      end
      workers.map(&:join)
    end

    def handle(job)
      random_comic_url = []
      case job
        when "test1"
          response = Net::HTTP.get_response('dynamic.xkcd.com', '/random/comic/')
          random_comic_url = response['Location']
          sleep(5)
        when "test2"
          response = Net::HTTP.get_response('dynamic.xkcd.com', '/random/comic/')
          random_comic_url = response['Location']
          sleep(5)
        when "test3"
          response = Net::HTTP.get_response('dynamic.xkcd.com', '/random/comic/')
          random_comic_url = response['Location']
          sleep(5)
        when "test4"
          response = Net::HTTP.get_response('dynamic.xkcd.com', '/random/comic/')
          random_comic_url = response['Location']
          sleep(5)
        when "test5"
          response = Net::HTTP.get_response('dynamic.xkcd.com', '/random/comic/')
          random_comic_url = response['Location']
          sleep(5)
        when "test6"
          response = Net::HTTP.get_response('dynamic.xkcd.com', '/random/comic/')
          random_comic_url = response['Location']
          sleep(5)
        when "test7"
          response = Net::HTTP.get_response('dynamic.xkcd.com', '/random/comic/')
          random_comic_url = response['Location']
          sleep(5)
        when "test8"
          response = Net::HTTP.get_response('dynamic.xkcd.com', '/random/comic/')
          random_comic_url = response['Location']
          sleep(5)
        when "test9"
          response = Net::HTTP.get_response('dynamic.xkcd.com', '/random/comic/')
          random_comic_url = response['Location']
          sleep(5)
        when "test10"
          response = Net::HTTP.get_response('dynamic.xkcd.com', '/random/comic/')
          random_comic_url = response['Location']
          sleep(5)
        when "test11"
          response = Net::HTTP.get_response('dynamic.xkcd.com', '/random/comic/')
          random_comic_url = response['Location']
          sleep(5)
        when "test12"
          response = Net::HTTP.get_response('dynamic.xkcd.com', '/random/comic/')
          random_comic_url = response['Location']

        end
      return "#{job} : #{random_comic_url}"
    end
  end
end