#! /usr/bin/env ruby
require "pathname"
require "optparse"
require "rexml/document"

options = {
  recent: false
}
optparse = OptionParser.new do |opts|
  opts.banner = "Usage: #$0 -u USERNAME -p PASSWORD [-r] <TARGET>"

  opts.on "-u", "--username USERNAME", "RubyTapas username (required)" do |username|
    options[:username] = username
  end

  opts.on "-p", "--password PASSWORD", "RubyTapas password (required)" do |password|
    options[:password] = password
  end

  opts.on "-r", "--recent-only", "Only download recent episodes" do |recent|
    options[:recent] = recent
  end

  opts.on "-h", "--help", "Show usage" do |help|
    warn opts
    exit
  end

end

optparse.parse!
options[:target] = ARGV.first

missing = [:username, :password, :target].find { |arg| options[arg].nil? }
if missing
  warn "Missing argument: #{missing.upcase}"
  warn optparse
  abort
end

$username = options[:username]
$password = options[:password]
$target_path = Pathname(options[:target]).expand_path

abort "Error: path '#$target_path' does not exist" unless $target_path.exist?
abort "Error: path '#$target_path' is not a directory" unless $target_path.directory?

def command(*args)
  warn "Command: #{args.join ' '}"
  success = system(*args)
  abort "Error: command failed with exit status #$?" unless success
end

def capture(*args)
  warn "Command: #{args.join ' '}"
  result = IO.popen(args) { |io| io.read }
  abort "Error: command failed with exit status #{$?.exitstatus}" unless $?.success?
  result
end

def feed_url
  "https://rubytapas.dpdcart.com/feed"
end

def username_and_password
  "#$username:#$password"
end

def fetch_feed
  capture "curl",
    "-u", username_and_password,
    "-s",
    feed_url
end

def download_url(href, filename)
  id = href[/file_id=(\d+)/, 1]
  "https://rubytapas.dpdcart.com/feed/download/#{id}/#{filename}"
end

def feed_episodes
  doc = REXML::Document.new(fetch_feed)
  REXML::XPath.each(doc.root, "channel/item")
end

def episode_title(item)
  REXML::XPath.first(item, "title").get_text.to_s
end

def episode_description(item)
  REXML::XPath.first(item, "description").text
end

def episode_links(item)
  doc = REXML::Document.new(episode_description(item))
  REXML::XPath.each(doc, "//a[contains(@href, 'subscriber/download?file_id')]").map do |a|
    [a.attribute("href").to_s, a.text]
  end
end

feed_episodes.each do |item|
  name = episode_title(item)
  ep_number = name.split.first.to_i
  dir_name = "%04d" % ep_number

  target_dir = $target_path.join(dir_name)

  target_dir.mkdir unless target_dir.exist?
  unless target_dir.directory?
    warn "#{target_dir} is not a directory, skipping"
    next
  end

  episode_links(item).each do |(url, filename)|
    target_file = target_dir.join(filename)
    if target_file.exist?
      if options[:recent]
        warn "#{filename} already downloaded, stopping"
        puts "Done updating."
        exit
      else
        warn "#{filename} already downloaded, skipping"
        next
      end
    end

    command "curl",
      "-u", username_and_password,
      "-o", target_file.to_path,
      "-L",
      download_url(url, filename)
  end
end
