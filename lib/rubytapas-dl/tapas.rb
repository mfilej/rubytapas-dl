require "rss"
require_relative "episode"
require_relative "feed"

class Tapas
  def initialize(username, password)
    @username, @password = username, password
  end

  def each
    items.each do |item|
      yield Episode.new(item)
    end
  end

  private

  def items
    RSS::Parser.parse(feed.body).items
  end

  def feed
    Feed.new(@username, @password)
  end
end

