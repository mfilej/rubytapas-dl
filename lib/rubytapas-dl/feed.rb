require "net/http"

class Feed
  FEED_URL = "https://rubytapas.dpdcart.com/feed"

  def initialize(username, password)
    @username, @password = username, password
    init_net_http
  end

  def body
    raise_if_response_unsuccessful
    response.body
  end

  def raise_if_response_unsuccessful
    response.value
  end

  def response
    @response ||= @http.start { |http| http.request(@request) }
  end

  private

  def init_net_http
    @uri = URI.parse(FEED_URL)
    @http = Net::HTTP.new(@uri.host, @uri.port)
    @http.use_ssl = true
    @request = Net::HTTP::Get.new(@uri.request_uri)
    @request.basic_auth(@username, @password)
  end

end
