# use rake-compiler for building the extension
require 'rake/extensiontask'

Rake::ExtensionTask.new('Console_ext', HOE.spec) do |ext|
  # FIXME: enable cross compilation to build fat binaries
  unless RUBY_PLATFORM =~ /mingw|mswin/ then
    ext.cross_compile = true
    ext.cross_platform = ['i386-mingw32', 'i386-mswin32-60']
  end

  # place extension binaries inside lib/X.Y
  if RUBY_PLATFORM =~ /mingw|mswin/
    RUBY_VERSION =~ /(\d+.\d+)/
    ext.lib_dir = "lib/#{$1}"
  end
end
