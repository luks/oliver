##!/usr/bin/jruby

$LOAD_PATH.unshift(File.dirname(__FILE__))


#require 'dotenv'
#require "pry"

require "lib/server"
require "modules/logger"



server = Oliver::Server.new(3333)

trap(:INT) {
  server.handler.pool.shutdown
  exit
}
#ctrl-c
# trap(:SIGINT) {
#   puts "Ignoring SIGINT"
# }

server.logger.info "Server started"
server.start











