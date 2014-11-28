require "remote_file_proxy/version"

module RemoteFileProxy
  class RFile
    def self.method_missing(method_sym, *args, &block)
      raise NoMethodError unless File.public_methods.include? method_sym
      File.send method_sym, *args, &block
    end
  end
end
