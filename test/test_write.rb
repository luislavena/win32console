#!/usr/bin/env ruby
begin
  require 'rubygems'
  require 'term/ansicolor'
  include Term::ANSIColor
rescue LoadError
  puts "You need term-ansicolor gem installed to run this test"
  puts "Please 'gem install term-ansicolor' and try again."
  exit(1)
end

require "benchmark"
require "Win32/Console/ANSI"

Benchmark.bm do |x|
  num = 100
  x.report("#{num} times") {
    0.upto(num) {
      print "\e[2J"

      print red, bold, "Usage as constants:", reset, "\n"

      print clear, "clear", reset, reset, "reset", reset,
        bold, "bold", reset, dark, "dark", reset,
        underscore, "underscore", reset, blink, "blink", reset,
        negative, "negative", reset, concealed, "concealed", reset, "|\n",
        black, "black", reset, red, "red", reset, green, "green", reset,
        yellow, "yellow", reset, blue, "blue", reset, magenta, "magenta", reset,
        cyan, "cyan", reset, white, "white", reset, "|\n",
        on_black, "on_black", reset, on_red, "on_red", reset,
        on_green, "on_green", reset, on_yellow, "on_yellow", reset,
        on_blue, "on_blue", reset, on_magenta, "on_magenta", reset,
        on_cyan, "on_cyan", reset, on_white, "on_white", reset, "|\n\n"
      print "\e[s\e[20P.................."
    }
  }
end
