require "rexml/document"

class Episode
  LINKS_SELECTOR = "//a[contains(@href, 'subscriber/download?file_id')]"
  SAFE_FILENAME = /[^-_.() [:alnum:]+]/

  def initialize(item)
    @item = item
  end

  def directory_name
    @item.title.gsub SAFE_FILENAME, ""
  end

  def files
    download_links.map { |link| Link.new(link)  }
  end

  private

  def download_links
    REXML::XPath.each(description, LINKS_SELECTOR)
  end

  def description
    REXML::Document.new(@item.description)
  end

  class Link
    def initialize(document)
      @document = document
    end

    def download_url
      "https://rubytapas.dpdcart.com/feed/download/#{id}/#{filename}"
    end

    def id
      href[/file_id=(\d+)/, 1]
    end

    def filename
      @document.text
    end

    def href
      @document.attribute("href").to_s
    end
  end
end
