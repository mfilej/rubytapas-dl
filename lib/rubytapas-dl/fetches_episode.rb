require "pathname"

class FetchesEpisode
  def self.download(args = {})
    new(args).download
  end

  attr_reader :fetcher, :target, :notifier

  def initialize(args = {})
    @target = Pathname(args.fetch(:target))
    @fetcher = args.fetch(:fetcher)
    @notifier = args.fetch(:notifier) { NullNotifier.new }
  end

  def download
    notifier.download_started
    write_fetched_data do |percent|
      notifier.progress(percent)
    end
    notifier.download_finished
  end

  private

  def write_fetched_data
    target.open("wb") do |file|
      fetcher.each_segment do |segment, percent|
        file.write(segment)
        yield(percent)
      end
    end
  end

  class NullNotifier
    def download_started() end
    def progress(_) end
    def download_finished() end
  end
end
