require 'remote_file_proxy/version'
require 'remote_file_proxy/api'
require 'digest/md5'
require 'socket'

module RemoteFileProxy

  class IORFile
    def initialize(filename, filepath, mode, host, port)
      @filename = filename
      @filepath = filepath
      @internal = File.open filepath, mode
      @md5_before = Digest::MD5.file(filepath).hexdigest 
      $stdout.puts "MD5 Before: #{@md5_before}"
      @closed = false
      @host = host
      @port = port
    end

    def write(content)
      $stdout.puts "Writing #{content} to #{@internal}"
      @internal.write content
      @internal.flush
    end

    def close
      if @closed
        raise IOError, "closed stream"
      end

      @internal.close
      @closed = true

      md5_after = Digest::MD5.file(@filepath).hexdigest
      $stdout.puts "MD5 after: #{md5_after}"

      unless @md5_before == md5_after
        server = RemoteFileProxy::API.new @host, @port
        server.write_file @filename, Pathname.new(@filepath).dirname
      end
    end

    def puts(content)
      @internal.puts content
      @internal.flush
    end

    def gets
      @internal.gets
    end
  end 

  class RFile

    @@temp_folder = File.expand_path("~/.rfile/")
    @@host = "localhost"
    @@port = "50000"

  	UNIMPLEMENTED = [:blockdev?, :chardev?, :chown, :ctime, :expand_path,
  					 :lchown, :link, :mtime, :pipe?, :realdirpath, :realpath,
  					 :socket?, :symlink, :utime]

    def self.method_missing(method_sym, *args, &block)
      raise NoMethodError unless File.public_methods.include? method_sym
      raise NotImplementedError if UNIMPLEMENTED.include? method_sym

      unless File.directory? @@temp_folder
        Dir.mkdir @@temp_folder
      end

      server = RemoteFileProxy::API.new @@host, @@port
      filename = args[0]

      begin
        filepath = server.get_file filename, @@temp_folder # TODO: caching
      rescue RemoteFileProxy::APIError
        if method_sym == :open and args[1] =~ /\w/
          filepath = File.join @@temp_folder, Digest::MD5.hexdigest(filename)
          f = File.open filepath, "w"
          f.close
        else
          raise IOError, "File not found"
        end
      end

      md5_before = Digest::MD5.file(filepath).hexdigest 
      args[0] = filepath

      if method_sym == :open
        return_val = IORFile.new filename, filepath, args[1], @@host, @@port
      else
        return_val = File.send method_sym, *args, &block
      end
      
      md5_after = Digest::MD5.file(filepath).hexdigest

      unless md5_before == md5_after
        server.write_file filename, @@temp_folder
      end

      return return_val
    end

    def self.destroy_cache!
      FileUtils.rm_rf(Dir.glob(File.join(@@temp_folder, "*")))
    end

  end
end
