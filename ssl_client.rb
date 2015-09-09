require "socket"
require "openssl"
#require "pry"



cert_store = OpenSSL::X509::Store.new
cert_store.add_file  '/home/luky/oliver/ssl/certificate.pem'
cert_store.set_default_paths

context = OpenSSL::SSL::SSLContext.new

context.ca_file = '/home/luky/oliver/ssl/ca_cert.pem'
context.cert_store = cert_store
context.verify_mode =  OpenSSL::SSL::VERIFY_PEER


socket = TCPSocket.new '0.0.0.0', 4444
ssl_client = OpenSSL::SSL::SSLSocket.new socket, context
ssl_client.connect

ssl_client.puts "Test:fib 45"
ssl_client.puts "Test:fib 46"
ssl_client.puts "Test:fib 47"
ssl_client.puts "Test:fib 48"
ssl_client.puts "Test:fib 49"
ssl_client.puts "Test:fib 50"
ssl_client.puts "Test:fib 51"
ssl_client.puts "Test:fib 52"
ssl_client.puts "Test:fib 53"
ssl_client.puts "Test:fib 54"
ssl_client.puts "Test:fib 55"
ssl_client.puts "Test:fib 56"
ssl_client.puts "Test:fib 57"
ssl_client.puts "Test:fib 58"
ssl_client.puts "Test:fib 59"
ssl_client.puts "Test:fib 60"
ssl_client.puts "Test:fib 61"
ssl_client.close


#openssl s_client -servername oliver  -connect 0.0.0.0:4444



