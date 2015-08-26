#!/usr/local/bin/ruby

require 'dotenv'
require 'logger'
require "thread"
require "pry"

require_relative "server.rb"
require_relative "modules/logger.rb"

#load .env into ENV
Dotenv.load
$:.unshift("lib")
$:.unshift("workers")

module Oliver

  include Logging

  class Run
    def self.server
      server = Server.new(ENV['SERVER_PORT'])
      server.start
      logger.info "Server started"
      server
    end
  end
end

server = Oliver::Run.server


