# Rake tasks to run rspec tests

require 'rubygems'
require 'rspec'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new do |t|
  t.pattern ='spec/{unit,integration}/**/*_spec.rb'
  t.fail_on_error = true
end
