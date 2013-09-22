require "pathname"

class DownloadNotifier
  attr_reader :target, :output

  def initialize(target, output = $stderr)
    @target = Pathname(target)
    @output = output
  end

  def download_started
    output.puts
  end

  def progress(percent)
    report_progress percent
  end

  def download_finished
    report_progress 100
  end

  private

  def report_progress(percent)
    output.print "\rDownloading #{target.basename} … #{percent}%"
  end
end
