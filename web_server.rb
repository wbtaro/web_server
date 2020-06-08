# frozen_string_literal: true

require "socket"
require_relative "server_thread"

begin
  tcp_server = TCPServer.open("localhost", 8001)
  puts "waiting for request..."
  server_thread = ServerThread.new(tcp_server)
  server_thread.respond
rescue => e
  puts e.message
ensure
  server.close
end
