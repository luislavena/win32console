require 'hoe'

HOE = Hoe.spec 'win32console' do
  self.version = '1.3.2'

  developer 'Gonzalo Garramuno',  'ggarra@advancedsl.com.ar'
  developer 'Justin Bailey',      'jgbailey@gmail.com'
  developer 'Luis Lavena',        'luislavena@gmail.com'

  self.rubyforge_name = 'winconsole'

  spec_extras[:required_ruby_version] = Gem::Requirement.new('>= 1.8.6')

  spec_extras[:extensions] = ["ext/Console_ext/extconf.rb"]

  extra_rdoc_files.push *FileList['extra/*.rdoc']

  spec_extras[:rdoc_options] = proc do |rdoc_options|
    rdoc_options << "--exclude" << "ext"
  end

  extra_dev_deps.push(
    ['rake-compiler', "~> 0.7.0"],
    ['mocha', '>= 0.10.5'],
    ['rspec', '>= 2.9.0'],
    ['rspec-core', '>= 2.9.0']
  )
end

file "#{HOE.spec.name}.gemspec" => ['Rakefile', 'tasks/gem.rake'] do |t|
  puts "Generating #{t.name}"
  File.open(t.name, 'w') { |f| f.puts HOE.spec.to_yaml }
end

desc "Generate or update the standalone gemspec file for the project"
task :gemspec => ["#{HOE.spec.name}.gemspec"]
