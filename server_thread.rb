# frozen_string_literal: true

require "date"

BASE_PATH = "./www"
NOT_FOUND_CONTENT = "/404_not_found.html"

class ServerThread
  def initialize(server)
    @server = server
  end

  def response
    while true
      Thread.start(@server.accept) do |socket|
        path = parse_path_from_request(socket)
        puts path + " is requested"

        respond_header(socket, path)
        respond_content(socket, path)

        socket.close
      end
    end
  end

  private
    def content_type(ext)
      content_type_map = {
        html: "text/html",
        htm:  "text/html",
        txt:  "text/plain",
        css:  "text/css",
        png:  "image/png",
        jpg:  "image/jpeg",
        jpeg: "image/jpeg",
        gif:  "image/gif"
      }
      content_type_map[ext.intern]
    end

    def parse_path_from_request(socket)
      while line = socket.gets do
        break if line == "\r\n"
        path = line.split(" ")[1] if line.match?(/^GET .*/)
      end
      path == "/" ? "/index.html" : path
    end

    def respond_header(socket, path)
      if content_exist(path)
        socket.puts("HTTP/1.1 200 OK")
      else
        socket.puts("HTTP/1.1 404 Not Found")
      end
      socket.puts("Date: " + Time.now.getutc.strftime("%a, %d %m %Y %H:%M:%S") + " GMT")
      socket.puts("Server: modoki/0.1")
      socket.puts("Connection: close")
      socket.puts("Content-type: " + content_type(path.split(".")[-1]))
      socket.puts("")
    end

    def respond_content(socket, path)
      path = NOT_FOUND_CONTENT if !content_exist(path)
      File.open(BASE_PATH + path) do |file|
        content = file.read
        socket.write(content)
      end
    end

    def content_exist(path)
      File.exist?(BASE_PATH + path)
    end
end
