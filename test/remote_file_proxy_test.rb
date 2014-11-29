require "minitest/autorun"

require "remote_file_proxy"

class RFPTest < Minitest::Unit::TestCase

  def test_proxy
    assert RemoteFileProxy::RFile.exists? "test/remote_file_proxy_test.rb"
  end

  def test_no_method_on_file
    assert_raises NoMethodError do
      RemoteFileProxy::RFile.methodthatdoesntexist
    end
  end

  def test_not_implemented
  	assert_raises NotImplementedError do
  		RemoteFileProxy::RFile.socket? "test/remote_file_proxy_test.rb"
  	end
  end
end