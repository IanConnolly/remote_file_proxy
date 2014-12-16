require 'socket'

module RemoteFileProxy

  class APIError < StandardError
  end

  class API
    def initialize(host, port)
      @server = TCPServer.new host, port
    end

    def get_file(filename, folder)
      message = "REQUEST FILENAME=#{filename}\n"

      header = @server.gets

      # Response is: FILE CONTENT-LENGTH=[len-in-bytes]\n[file]
      # or: ERROR MESSAGE=[msg]\n

      if header.split()[0] == 'ERROR'
        raise APIError, "Error: #{header.split()[1].split('=')[1]}"
      end

      content_length = header.split()[1].split('=')[1]
      file_contents = @server.recv(content_length.to_i)
      
      new_filename = File.join(folder, filename)

      f = File.open(new_filename, "w")
      f.write file_contents
      f.close

      new_filename
    end

  end

end