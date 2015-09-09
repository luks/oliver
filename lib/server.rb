require "socket"
require "openssl"
require "thread"
require "modules/logger"
require "lib/handler"


module Oliver
  class Server
    include Logging
    attr_accessor :handler

    def initialize(port)
      @handler = Handler.new
    end

    def tcp_server
      server = TCPServer.open(3333)
      server_loop(server)
    end

    def ssl_server
      tcp_server = TCPServer.open(4444)
      context = OpenSSL::SSL::SSLContext.new

      context.cert = OpenSSL::X509::Certificate.new File.read 'ssl/certificate.pem'
      context.key  = OpenSSL::PKey::RSA.new File.read 'ssl/private_key.pem'

      ssl_server = OpenSSL::SSL::SSLServer.new tcp_server, context

      begin
        server_loop(ssl_server)
      rescue OpenSSL::SSL::SSLError => e
        logger.error "Openssl error #{e}"
      end
    end

    def start
      Thread.new { tcp_server }
      Thread.new { ssl_server }
      while true
        sleep(1)
      end
    end

    def server_loop(server)
      sockets = [server]
      while true
        ready = select(sockets)
        readable = ready[0]
        readable.each do |socket|

          if socket == server
            client = server.accept
            sockets << client
            client.puts "Handler service v0.01 running on #{Socket.gethostname}"
          else
            input = socket.gets
            if !input
              sockets.delete(socket)
              socket.close
              next
            end
            socket.puts "Handler service acceppt command #{input}"# So reverse input and send it back
            handler.pool << input.chop!
          end

        end
      end
    end
  end
end
