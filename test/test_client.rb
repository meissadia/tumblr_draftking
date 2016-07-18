require_relative 'test_helper'

class TestClient < Minitest::Test
  def test_client
    assert /^tumblr_draftking\s(\d*.)*\d$/.match(DK::Client.version)
  end
end
