= Win32::Console

* http://rubyforge.org/projects/winconsole
* http://github.com/luislavena/win32console
* http://rdoc.info/projects/luislavena/win32console

== DESCRIPTION

Win32::Console allows controling the windows command line terminal
thru an OO-interface. This allows you to query the terminal (find
its size, characters, attributes, etc). The interface and functionality
should be identical to Perl's counterpart.

A port of Perl's Win32::Console and Win32::Console::ANSI modules.

This gem packages Gonzalo Garramuno's Win32::Console project, and includes
a compiled binary for speed. The Win32::Console project's home can be
found at:

  http://rubyforge.org/projects/win32console

== FEATURES

Win32::Console::ANSI is a class derived from IO that seamlessly
translates ANSI Esc control character codes into Windows' command.exe
or cmd.exe equivalents.

To ease usage, you can use in combination with term-ansicolor gem and avoid
writing ANSI codes manually.

== EXAMPLES

To output a simple bolded string, try this script:

  require 'rubygems'
  require 'win32console'
  include Win32::Console::ANSI
  include Term::ANSIColor

  puts bold << "bolded text" << clear << " and no longer bold."

== INSTALL

  gem install win32console

== DEVELOPERS:

After checking out the source, run:

  $ rake newb

This task will install any missing dependencies, run the tests/specs,
and generate the RDoc.
