require 'rubygems'
Gem::manage_gems
require 'rake/gempackagetask'

spec = Gem::Specification.new do |s|
	s.name = "win32console"
	s.summary = "A library giving the Win32 console ANSI escape sequence support."
	s.version = "1.1.1"
	s.author = "Original Library by Gonzalo Garramuno, Gem by Justin Bailey"
	s.email = "ggarra @nospam@ advancedsl.com.ar, jgbailey @nospan@ gmail.com"
	s.homepage = "http://rubyforge.org/projects/winconsole"
	s.rubyforge_project = "http://rubyforge.org/projects/winconsole"
	s.description = <<EOS
This gem packages Gonzalo Garramuno's Win32::Console project, and includes a compiled binary for speed. The Win32::Console project's home can be found at:

  http://rubyforge.org/projects/win32console

The gem project can be found at

  http://rubyforge.org/projects/winconsole
EOS

	s.platform = Gem::Platform::CURRENT
	s.files = FileList["lib/**/*", "test/*", "doc/**/*", "Console*", "*.txt", "Rakefile", "extconf.rb"].to_a

	s.require_path = "lib"
	s.autorequire = "win32console"

	s.has_rdoc = true
	s.extra_rdoc_files = ["README_GEM.txt"]
	s.rdoc_options << '--title' << 'Win32Console Gem -- Gem for Win32::Console Project' <<
                       '--main' << 'README_GEM.txt' <<
                       '--line-numbers'
end

Rake::GemPackageTask.new(spec) do |pkg|
  pkg.need_tar = true
end
