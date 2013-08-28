#! /usr/bin/env ruby -w
require "pathname"
require "nokogiri"

def usage
  "Usage: #$0 <username> <password> <path>"
end

abort usage unless ARGV.size == 3
$username, $password, $target_path = ARGV
$target_path = Pathname($target_path).expand_path

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
  id = href.match(/file_id=(?<id>\d+)/)[:id]
  "https://rubytapas.dpdcart.com/feed/download/#{id}/#{filename}"
end

doc = Nokogiri::XML(fetch_feed)
doc.search("item").reverse.each do |item|
  name = item.at("title").text
  ep_number = name.split.first.to_i
  dir_name = "%04d" % ep_number

  desc = Nokogiri::HTML(item.at("description").text)
  downloads = desc.search("a[href*=download]").map { |a|
    [download_url(a[:href], a.text), a.text]
  }

  target_dir = $target_path.join(dir_name)

  target_dir.mkdir unless target_dir.exist?
  unless target_dir.directory?
    warn "#{target_dir} is not a directory, skipping"
    next
  end

  downloads.each do |(url, filename)|
    target_file = target_dir.join(filename)
    if target_file.exist?
      warn "#{filename} already downloaded, skipping"
      next
    end

    command "curl",
      "-u", username_and_password,
      "-o", target_file.to_path,
      "-L",
      url
  end
end
