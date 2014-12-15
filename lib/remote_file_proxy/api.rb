require 'socket'

module RemoteFileProxy

  class APIError < StandardError
  end

  class API
    def initialize(host, port)
      @server = TCPSocket.new host, port
    end

    def get_file(filename, folder)
      message = "REQUEST FILENAME=#{filename}\n"

      header = s.gets

      # Response is: FILE CONTENT-LENGTH=[len-in-bytes]\n[file]
      # or: ERROR MESSAGE=[msg]\n

      if header.split()[0] == 'ERROR'
        raise StandardError, "Error: #{header.split()[1].split('=')[1]}"
      end

      content_length = header.split()[1].split('=')[1]
      file_contents = s.recv(content_length)
      
      new_filename = File.join(folder, filename)
      File.open(new_filename, "w") do |f|
        f.write file_contents
      end

      new_filename
    end

  end

end