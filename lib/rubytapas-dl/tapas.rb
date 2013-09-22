require "rss"
require_relative "episode"

class Tapas
  def initialize(body)
    @body = body
  end

  def each
    items.each do |item|
      yield Episode.new(item)
    end
  end

  private

  def items
    RSS::Parser.parse(@body).items
  end
end

