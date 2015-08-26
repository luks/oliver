require "socket"
require "thread"
require_relative "handler"
require_relative "modules/logger.rb"

module Oliver
  class Server
    include Logging
    attr_accessor :server, :handler

    def initialize(port)
      @server = TCPServer.open(port)
      @handler = Handler.new
      trap(:INT) { exit }
    end

    def start
      Thread.new { server_loop }
      handler.spawn_workers
    end

    def server_loop
      sockets = [server]
      while true
        ready = select(sockets)
        readable = ready[0]
        readable.each do |socket|
          # Loop through readable sockets
          if socket == server
            # If the server socket is ready
            client = server.accept
            # Accept a new client
            sockets << client
            # Add it to the set of sockets
            # Tell the client what and where it has connected.
            client.puts "Handler service v0.01 running on #{Socket.gethostname}"
            # And log the fact that the client connected
            logger.info "Accepted connection from #{client.peeraddr[2]}"
          else
            # Otherwise, a client is ready
            input = socket.gets
            # Read input from the client
            # If no input, the client has disconnected
            if !input
              logger.info "Client on #{socket.peeraddr[2]} disconnected."
              sockets.delete(socket)
              # Stop monitoring this socket
              socket.close
              # Close it
              next
              # And go on to the next
            end
            socket.puts "Handler service acceppt command #{input}"# So reverse input and send it back
            handler.queue.push(input.chop!)
          end
        end
      end
    end
  end
end