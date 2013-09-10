#! /usr/bin/env ruby
# TODO:
# curl -> nethttp
# handle http error codes

require "pathname"
require "optparse"
require "rexml/document"

$LOAD_PATH.unshift File.expand_path("../lib/rubytapas-dl", __FILE__)
require "episode"
require "feed"
require "tapas"

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

def username_and_password
  "#$username:#$password"
end
feed_episodes = Tapas.new($username, $password)

feed_episodes.each do |episode|
  target_dir = $target_path.join(episode.directory_name)

  target_dir.mkdir unless target_dir.exist?
  unless target_dir.directory?
    warn "#{target_dir} is not a directory, skipping"
    next
  end

  episode.files.each do |link|
    target_file = target_dir.join(link.filename)
    if target_file.exist?
      if options[:recent]
        warn "#{link.filename} already downloaded, stopping"
        puts "Done updating."
        exit
      else
        warn "#{link.filename} already downloaded, skipping"
        next
      end
    end

    command "curl",
      "-u", username_and_password,
      "-o", target_file.to_path,
      "-L",
      link.download_url
  end
end
