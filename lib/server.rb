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
      # Create keys:
      # => key = OpenSSL::PKey::RSA.new 2048
      # => open 'private_key.pem', 'w' do |io| io.write key.to_pem end
      # => open 'public_key.pem', 'w' do |io| io.write key.public_key.to_pem end
      #cipher = OpenSSL::Cipher.new 'AES-128-CBC'
      #pass_phrase = "oliver server"

      #key_pem     = File.read 'private_key.pem'
      #key_secure  = OpenSSL::PKey::RSA.new key_pem, pass_phrase

      #key  = OpenSSL::PKey::RSA.new key_pem File.read 'private_key.pem'
      #cert =  OpenSSL::X509::Certificate.new File.read 'certificate.pem'
      context = OpenSSL::SSL::SSLContext.new
      context.cert = OpenSSL::X509::Certificate.new File.read 'certificate.pem'
      context.key  = OpenSSL::PKey::RSA.new key_pem File.read 'private_key.pem'
      ssl_server = OpenSSL::SSL::SSLServer.new tcp_server, context
      server_loop(server)
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
            logger.info "Accepted connection from #{client.peeraddr[2]}"
          else
            input = socket.gets
            if !input
              logger.info "Client on #{socket.peeraddr[2]} disconnected."
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
