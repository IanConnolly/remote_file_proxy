require 'minitest/unit'
require "minitest/autorun"
require 'minitest/pride'

require "remote_file_proxy/api"

class APITest < Minitest::Unit::TestCase

  def setup
    @mocked_socket = Minitest::Mock.new
    @file_size = 7
  end

  def test_error
    @mocked_socket.expect(:gets, "ERROR MESSAGE=test\n", [])

    TCPServer.stub :new, @mocked_socket do
      api = RemoteFileProxy::API.new "host", 90
      assert_raises RemoteFileProxy::APIError do
        api.get_file "notimportant", "/usr"
      end 
    end

    @mocked_socket.verify
  end

  def test_file_recv
    @mocked_socket.expect(:gets, "FILE CONTENT-LENGTH=#{@file_size}\n", [])
    @mocked_socket.expect(:recv, 'thisis7B', [@file_size])

    file = Minitest::Mock.new
    file.expect(:write, nil, ['thisis7B'])
    file.expect(:close, nil, [])


    TCPServer.stub :new, @mocked_socket do
      api = RemoteFileProxy::API.new "host", 90
      File.stub :open, file do
        new_filename = api.get_file "file", "folder"
        assert_equal new_filename, File.join("folder", "file")
        file.verify
      end
    end

    @mocked_socket.verify
  end

end

