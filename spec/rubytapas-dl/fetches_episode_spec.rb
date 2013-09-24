require "rubytapas-dl/fetches_episode"
require "tempfile"

describe FetchesEpisode do
  let(:fetcher) { double "fetcher" }
  let(:file) { Tempfile.new "rubytapas-dl-spec" }

  before do
    fetcher.stub(:each_segment)
      .and_yield("This", 0)
      .and_yield("Is", 50)
      .and_yield("Data!!!", 99)
  end

  it "writes fetched data to the target file" do
    FetchesEpisode.download(fetcher: fetcher, target: file)

    expect(file.read).to eq("ThisIsData!!!")
  end

  it "informs the notifier object about download events" do
    notifier = double "notifier"
    expect(notifier).to receive(:download_started)
    expect(notifier).to receive(:progress).with(0)
    expect(notifier).to receive(:progress).with(50)
    expect(notifier).to receive(:progress).with(99)
    expect(notifier).to receive(:download_finished)

    FetchesEpisode.download(fetcher: fetcher, target: file, notifier: notifier)
  end
end
