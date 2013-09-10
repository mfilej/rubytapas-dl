require "rubytapas-dl/episode"

describe Episode do

  def Episode(title)
    Episode.new(double("item", title: title))
  end

  it "returns a sanitized directory name" do
    expect(Episode("125 And/Or").directory_name).to eq("125 AndOr")
    expect(Episode("044 #one?").directory_name).to eq("044 one")
    expect(Episode("010 Finding $HOME").directory_name).to eq("010 Finding HOME")
  end

  it "extracts links from the description" do
    item = double "item", description: RSS_ITEM_DESCRIPTION
    files = Episode.new(item).files
    expect(files[0].download_url).to eq("https://rubytapas.dpdcart.com/feed/download/1602/130-rake-file-lists.html")
    expect(files[0].filename).to eq("130-rake-file-lists.html")
    expect(files[1].download_url).to eq("https://rubytapas.dpdcart.com/feed/download/1603/130-rake-file-lists.mp4")
    expect(files[1].filename).to eq("130-rake-file-lists.mp4")
    expect(files[2].download_url).to eq("https://rubytapas.dpdcart.com/feed/download/1604/130-rake-file-lists.rb")
    expect(files[2].filename).to eq("130-rake-file-lists.rb")
    expect(files[3].download_url).to eq("https://rubytapas.dpdcart.com/feed/download/1605/Rakefile")
    expect(files[3].filename).to eq("Rakefile")
  end

  RSS_ITEM_DESCRIPTION = "<div class=\"blog-entry\">\n          <div class=\"blog-content\"><p>As we continue our series on Rake, today we look at the Rake::FileList and how it can help us find the files we need and ignore the ones we don't.</p>\n          </div>\n          <h3>Attached Files</h3>\n          <ul>\n          <li><a href=\"https://rubytapas.dpdcart.com/subscriber/download?file_id=1602\">130-rake-file-lists.html</a></li>\n<li><a href=\"https://rubytapas.dpdcart.com/subscriber/download?file_id=1603\">130-rake-file-lists.mp4</a></li>\n<li><a href=\"https://rubytapas.dpdcart.com/subscriber/download?file_id=1604\">130-rake-file-lists.rb</a></li>\n<li><a href=\"https://rubytapas.dpdcart.com/subscriber/download?file_id=1605\">Rakefile</a></li>\n</ul></div>"
end
