require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

task :coverage do
  require_relative "spec/coveralls.rb"
end

task spec: :coverage if ENV["COVERAGE"]

task default: :spec
