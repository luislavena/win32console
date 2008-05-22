= Introduction

This gem packages Gonzalo Garramuno's Win32::Console project, and includes a compiled binary for speed. The Win32::Console project's home can be found at:

http://rubyforge.org/projects/win32console
  
To use the gem, just put

  require 'win32console'
  
At the top of your file.

= Example

To output a simple bolded string, try this script:

  require 'rubygems'
  require 'win32console'
  include Win32::Console::ANSI
  include Term::ANSIColor
  
  puts bold << "bolded text" << clear << " and no longer bold."

= Formatting Methods Available

The full list of methods available is found in lib/Term/ansicolor.rb (generated from the @@attributes array):

  clear
  reset # synonym for clear
  bold
  dark
  italic # not widely implemented
  underline
  underscore # synonym for underline
  blink
  rapid_blink # not widely implemented
  negative # no reverse because of String#reverse
  concealed
  strikethrough # not widely implemented

  # The following will set the foreground color
  
  black
  red
  green
  yellow
  blue
  magenta
  cyan
  white

  # The following will set the background color
  
  on_black
  on_red
  on_green
  on_yellow
  on_blue
  on_magenta
  on_cyan
  on_white

The methods are fairly sophisticated. If you don't pass an argument, the appropriate escape sequence is returned. If a string is given, it will be outputted with an escape sequence wrapping it to apply the formatting to just that portion. If a block is given, the escape sequence will wrap the output of the block. Finally, if the Term::ANSIColor module is mixed into an object, and that instance supports to_str, tnen the result of to_str will be wrapped in the escape sequence.
  