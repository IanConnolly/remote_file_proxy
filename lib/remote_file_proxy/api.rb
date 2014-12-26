require 'socket'

module RemoteFileProxy

  class APIError < StandardError
  end

  class API
    def initialize(host, port)
      @server = TCPSocket.new host, port
    end

    def get_file(filename, folder)
      message = "REQUEST FILENAME=#{filename}"
      @server.puts message
      puts "Sending: #{message} to #{@server}"
      header = @server.gets
      puts "Received: #{header}"

      # Response is: FILE CONTENT-LENGTH=[len-in-bytes]\n[file]
      # or: ERROR MESSAGE=[msg]\n

      if header.split()[0] == 'ERROR'
        raise APIError, "Error: #{header.split()[1].split('=')[1]}"
      end

      content_length = header.split()[1].split('=')[1]
      file_contents = @server.recv(content_length.to_i)
      
      new_filename = File.join(folder, filename.hash)

      f = File.open(new_filename, "w")
      f.write file_contents
      f.close

      new_filename
    end

    def write_file(filename, folder)
      filepath = File.join(folder, filename.hash)
      file_contents = File.read filepath
      file_length = File.size filepath
      @server.puts "WRITE NAME=#{filename} CONTENT_LENGTH=#{file_length}"
      @server.puts file_contents
    end

  end

end