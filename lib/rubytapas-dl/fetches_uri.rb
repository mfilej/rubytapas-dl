require "net/http"

class FetchesURI
  USER_AGENT = "rubytapas-dl/1.0 (https://github.com/mfilej/rubytapas-dl)"

  def initialize(uri, username=nil, password=nil)
    @uri = URI.parse(uri)

    @http = Net::HTTP.new(@uri.host, @uri.port)
    @http.use_ssl = uri.start_with? "https://"

    @request = Net::HTTP::Get.new(@uri.request_uri)
    @request.basic_auth(username, password) if username && password
    @request["User-Agent"] = USER_AGENT
  end

  def body
    start_http_request do |response|
      return response.body
    end
  end

  def each_segment
    start_http_request do |response, length|
      response.enum_for(:read_body).inject(0) do |position, segment|
        yield segment, percent_done(position, length)
        position + segment.length
      end
    end
  end

  private

  def percent_done(position, length)
    return 100 unless length
    position * 100 / length
  end

  def start_http_request
    @http.start do |http|
      http.request(@request) do |response|
        response.value # raise if response unsuccessful
        yield response, response.content_length
      end
    end
  end
end
