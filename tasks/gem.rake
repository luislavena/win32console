require 'rubygems/package_task'
require 'hoe'

HOE = Hoe.spec 'win32console' do
  developer 'Gonzalo Garramuno',  'ggarra@advancedsl.com.ar'
  developer 'Justin Bailey',      'jgbailey@gmail.com'
  developer 'Luis Lavena',        'luislavena@gmail.com'

  self.rubyforge_name = 'winconsole'

  spec_extras[:required_ruby_version] = Gem::Requirement.new('> 1.8.5')

  spec_extras[:extensions] = ["ext/Console/extconf.rb"]

  extra_dev_deps << ['rake-compiler', "~> 0.7.0"]
end

file "#{HOE.spec.name}.gemspec" => ['Rakefile', 'tasks/gem.rake', 'lib/sqlite3/version.rb'] do |t|
  puts "Generating #{t.name}"
  File.open(t.name, 'w') { |f| f.puts HOE.spec.to_yaml }
end

desc "Generate or update the standalone gemspec file for the project"
task :gemspec => ["#{HOE.spec.name}.gemspec"]
