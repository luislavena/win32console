# use rake-compiler for building the extension
require 'rake/extensiontask'

Rake::ExtensionTask.new('Console_ext', HOE.spec) do |ext|
  # place extension binaries inside lib/X.Y
  if RUBY_PLATFORM =~ /mingw|mswin/
    RUBY_VERSION =~ /(\d+.\d+)/
    ext.lib_dir = "lib/#{$1}"
  end
end
