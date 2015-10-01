##!/usr/bin/jruby

$LOAD_PATH.unshift(File.dirname(__FILE__))

#require "pry"

require "lib/server"
require "modules/logger"



server = Oliver::Server.new(3333)

trap(:INT) {
  server.handler.pool.shutdown
  exit
}

server.logger.info "Server started"
server.start











