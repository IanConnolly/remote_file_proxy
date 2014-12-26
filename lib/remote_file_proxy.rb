require 'remote_file_proxy/version'
require 'remote_file_proxy/api'
require 'socket'

module RemoteFileProxy
  class RFile

    @@temp_folder = File.expand_path("~/.rfile/")
    @@host = "localhost"
    @@port = "45678"

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
      filename = args[0] # not strictly true, but let's work with it
      filepath = server.get_file filename, @@temp_folder # TODO: caching
      md5_before = Digest::MD5.file(filepath).hexdigest 
      args[0] = filepath
      
      File.send method_sym, *args, &block
      
      md5_after = Digest::MD5.file(filepath).hexdigest

      unless md5_before == md5_after
        server.write_file filename, @@temp_folder
      end
    end

    def self.destroy_cache!
      FileUtils.rm_rf(Dir.glob(File.join(@@temp_folder, "*")))
    end

  end
end
