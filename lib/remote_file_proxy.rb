require "remote_file_proxy/version"

module RemoteFileProxy
  class RFile

  	UNIMPLEMENTED = [:blockdev?, :chardev?, :chown, :ctime, :expand_path,
  					 :lchown, :link, :mtime, :pipe?, :realdirpath, :realpath,
  					 :socket?, :symlink, :utime]

    def self.method_missing(method_sym, *args, &block)
      raise NoMethodError unless File.public_methods.include? method_sym
      raise NotImplementedError if UNIMPLEMENTED.include? method_sym

      # set up connection to the filesystem
      # find the file
      # pull it to client disk in temp folder
      # call File's underlying method, but alter the filename arg
      File.send method_sym, *args, &block
    end
  end
end
