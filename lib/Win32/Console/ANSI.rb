# encoding: utf-8

#
# Win32::Console::ANSI
#
# Copyright 2004 - Gonzalo Garramuno
# Licensed under GNU General Public License or Perl's Artistic License
#
# Based on Perl's Win32::Console::ANSI
# Copyright (c) 2003 Jean-Louis Morel <jl_morel@bribes.org>
# Licensed under GNU General Public License or Perl's Artistic License
#
require "Win32/Console"


module Kernel

  # Kernel#putc is equivalent to $stdout.putc, but
  # it doesn't use $stdout.putc.  We redefine it to do that
  # so that it will buffer the escape sequences properly.
  # See Win32::Console::ANSI::IO#putc
  remove_method :putc
  def putc(int)
    $stdout.putc(int)
  end

end

module Win32
  class Console
    module ANSI

      class IO < IO

        VERSION = '0.05'
        DEBUG = nil

        require "win32/registry"

        include Win32::Console::Constants

        FD_STD_MAP = {
          :stdout => [1, STD_OUTPUT_HANDLE],
          :stderr => [2, STD_ERROR_HANDLE]
        }

        # @todo: encode is another perl module
        EncodeOk = false

        # Retrieving the codepages
        cpANSI = nil
        Win32::Registry::HKEY_LOCAL_MACHINE.open('SYSTEM\CurrentControlSet\Control\Nls\CodePage' ) { |reg|
          cpANSI = reg['ACP']
        }

        STDERR.puts "Unable to read Win codepage #{cpANSI}" if DEBUG && !cpANSI


        cpANSI = 'cp'+(cpANSI ? cpANSI : '1252')      # Windows codepage
        OEM = Win32::Console::OutputCP()
        cpOEM = 'cp' + OEM.to_s                       # DOS codepage
        @@cp = cpANSI + cpOEM

        STDERR.puts "EncodeOk=#{EncodeOk} cpANSI=#{cpANSI} "+
          "cpOEM=#{cpOEM}" if DEBUG

        @@color = { 30 => 0,                                               # black foreground
              31 => FOREGROUND_RED,                                  # red foreground
              32 => FOREGROUND_GREEN,                                # green foreground
              33 => FOREGROUND_RED|FOREGROUND_GREEN,                 # yellow foreground
              34 => FOREGROUND_BLUE,                                 # blue foreground
              35 => FOREGROUND_BLUE|FOREGROUND_RED,                  # magenta foreground
              36 => FOREGROUND_BLUE|FOREGROUND_GREEN,                # cyan foreground
              37 => FOREGROUND_RED|FOREGROUND_GREEN|FOREGROUND_BLUE, # white foreground
              40 => 0,                                               # black background
              41 => BACKGROUND_RED,                                  # red background
              42 => BACKGROUND_GREEN,                                # green background
              43 => BACKGROUND_RED|BACKGROUND_GREEN,                 # yellow background
              44 => BACKGROUND_BLUE,                                 # blue background
              45 => BACKGROUND_BLUE|BACKGROUND_RED,                  # magenta background
              46 => BACKGROUND_BLUE|BACKGROUND_GREEN,                # cyan background
              47 => BACKGROUND_RED|BACKGROUND_GREEN|BACKGROUND_BLUE, # white background
        }

        def initialize(fd_std = :stdout)
          fd, handle = FD_STD_MAP[fd_std]
          super(fd, 'w')
          @Out = Win32::Console.new(handle)
          @x = @y = 0           # to save cursor position

          # None of these calls will work, when we are redirected
          unless redirected?
            @default_foreground = @Out.DefaultForeground
            @default_background = @Out.DefaultBackground
            @default_bold       = @Out.DefaultBold
            @default_underline  = @Out.DefaultUnderline
          end

          @foreground = @default_foreground
          @background = @default_background
          @bold       = @default_bold
          @underline  = @default_underline
          @revideo =
          @concealed = nil
          @conv = 1        # char conversion by default
          @buffer = []
          STDERR.puts "Console Mode=#{@Out.Mode}" if DEBUG
        end

        # this redefined #putc buffers escape sequences but passes
        # other values to #write as normal.
        def putc(int)
          int = int.ord if RUBY_VERSION >= "1.9"
          if @buffer.empty?
            # match \e
            unless int == 27
              write(int.chr)
            else
              @buffer << int
            end
          else
            @buffer << int
            case int
            # match m, J, L, M, @, P, A, B, C, D, E, F, G, H, f, s, u, U, K, X
            when 109, 74, 76, 77, 64, 80, 65, 66, 67, 68, 
                  69, 70, 71, 72, 102, 115, 117, 85, 75, 88
              write(@buffer.pack("c*"))
              @buffer.clear
            end
          end
        end

        # #write checks if $stdout is going to the console
        # or if it's being redirected.
        # When to the console, it passes the string to
        # _PrintString to be parsed for escape codes.
        #
        # When redirected, it passes to WriteFile to allow escape
        # codes and all to be output.  The application that is
        # handling the redirected IO should handle coloring.
        # For Ruby applications, this means requiring Win32Conole again.
        def write(*s)
          if redirected?
            s.each{ |x| @Out.WriteFile(x.dup.to_s) }
          else
            s.each{ |x| _PrintString(x) }
          end
        end

        # Returns true if output is being redirected to something other then a
        # terminal.
        #
        # For now just checks the status of Win32::Console#redirected?
        def redirected?
          @Out.redirected?
        end

        private

        def _PrintString(t)
          s = t.dup.to_s
          while s != ''
            if s.sub!( /([^\e]*)?\e([\[\(])([0-9\;\=]*)([a-zA-Z@])(.*)/, '\5')
              @Out.Write((_conv("#$1")))
              if $2 == '['
                case $4
                when 'm'        # ESC[#;#;....;#m Set display attributes
                  attributs = $3.split(';')
                  attributs.push(nil) unless attributs  # ESC[m == ESC[;m ==...==ESC[0m
                  attributs.each do |attr|
                    atv = attr.to_i
                    case atv
                    when 0  # ESC[0m reset
                      @foreground = @default_foreground
                      @background = @default_background
                      @bold       = @default_bold
                      @underline  = @default_underline
                      @revideo =
                      @concealed = nil
                    when 1
                      @bold = 1
                    when 21
                      @bold = nil
                    when 4
                      @underline = 1
                    when 24
                      @underline = nil
                    when 7
                      @revideo = 1
                    when 27
                      @revideo = nil
                    when 8
                      @concealed = 1
                    when 28
                      @concealed = nil
                    when 30..37
                      @foreground = atv - 30
                    when 40..47
                      @background = atv - 40
                    end
                  end

                  if @revideo
                    attribut = @@color[40+@foreground] |
                      @@color[30+@background]
                  else
                    attribut = @@color[30+@foreground] |
                      @@color[40+@background]
                  end
                  attribut |= FOREGROUND_INTENSITY if @bold
                  attribut |= BACKGROUND_INTENSITY if @underline
                  @Out.Attr(attribut)
                when 'J'
                  if !$3 or $3 == ''  # ESC[0J from cursor to end of display
                    info = @Out.Info()
                    s = ' ' * ((info[1]-info[3]-1)*info[0]+info[0]-info[2]-1)
                    @Out.WriteChar(s, info[2], info[3])
                    @Out.Cursor(info[2], info[3])
                  elsif $3 == '1' # ESC[1J erase from start to cursor.
                    info = @Out.Info()
                    s = ' ' * (info[3]*info[0]+info[2]+1)
                    @Out.WriteChar(s, 0, 0)
                    @Out.Cursor(info[2], info[3])
                  elsif $3 == '2' # ESC[2J Clear screen and home cursor
                    @Out.Cls()
                    @Out.Cursor(0, 0)
                  else
                    STDERR.print "\e#$2#$3#$4" if DEBUG # if ESC-code not implemented
                  end
                when 'K'
                  info = @Out.Info()
                  if !$3 or $3 == ''                  # ESC[0K Clear to end of line
                    s = ' ' * (info[7]-info[2]+1)
                    @Out.Write(s)
                    @Out.Cursor(info[2], info[3])
                  elsif $3=='1'   # ESC[1K Clear from start of line to cursor
                    s = ' '*(info[2]+1)
                    @Out.WriteChar(s, 0, info[3])
                    @Out.Cursor(info[2], info[3])
                  elsif $3=='2'   # ESC[2K Clear whole line.
                    s = ' '* info[0]
                    @Out.WriteChar(s, 0, info[3])
                    @Out.Cursor(info[2], info[3])
                  end
                when 'L'  # ESC[#L Insert # blank lines.
                  n = $3 == ''? 1 : $3.to_i  # ESC[L == ESC[1L
                  info = @Out.Info()
                  @Out.Scroll(0, info[3], info[0]-1, info[1]-1,
                              0, info[3] + n.to_i,
                               ' '[0], @Out.Attr(),
                               0, 0, 10000, 10000)
                  @Out.Cursor(info[2], info[3])
                when 'M'   # ESC[#M Delete # line.
                  n = $3 == ''? 1 : $3.to_i  # ESC[M == ESC[1M
                  info = @Out.Info();
                  @Out.Scroll(0, info[3]+n, info[0]-1, info[1]-1,
                              0, info[3],
                              ' '[0], @Out.Attr(),
                              0, 0, 10000, 10000)
                  @Out.Cursor(info[2], info[3])
                when 'P'   # ESC[#P Delete # characters.
                  n = $3 == ''? 1 : $3.to_i  # ESC[P == ESC[1P
                  info = @Out.Info()
                  n = info[0]-info[2] if info[2]+n > info[0]-1
                  @Out.Scroll(info[2]+n, info[3] , info[0]-1, info[3],
                              info[2], info[3],
                              ' '[0], @Out.Attr(),
                              0, 0, 10000, 10000)
                  s = ' ' * n
                  @Out.Cursor(info[0]-n, info[3])
                  @Out.Write(s)
                  @Out.Cursor(info[2], info[3])
                when '@'      # ESC[#@ Insert # blank Characters
                  s = ' ' * $3.to_i
                  info = @Out.Info()
                  s << @Out.ReadChar(info[7]-info[2]+1, info[2], info[3])
                  s = s[0..-($3.to_i)]
                  @Out.Write(s);
                  @Out.Cursor(info[2], info[3])
                when 'A'     # ESC[#A Moves cursor up # lines
                  (x, y) = @Out.Cursor()
                  n = $3 == ''? 1 : $3.to_i;  # ESC[A == ESC[1A
                  @Out.Cursor(x, y-n)
                when 'B'    # ESC[#B Moves cursor down # lines
                  (x, y) = @Out.Cursor()
                  n = $3 == ''? 1 : $3.to_i;  # ESC[B == ESC[1B
                  @Out.Cursor(x, y+n)
                when 'C'    # ESC[#C Moves cursor forward # spaces
                  (x, y) = @Out.Cursor()
                  n = $3 == ''? 1 : $3.to_i;  # ESC[C == ESC[1C
                  @Out.Cursor(x+n, y)
                when 'D'    # ESC[#D Moves cursor back # spaces
                  (x, y) = @Out.Cursor()
                  n = $3 == ''? 1 : $3.to_i;  # ESC[D == ESC[1D
                  @Out.Cursor(x-n, y)
                when 'E'    # ESC[#E Moves cursor down # lines, column 1.
                  x, y = @Out.Cursor()
                  n = $3 == ''? 1 : $3.to_i;  # ESC[E == ESC[1E
                  @Out.Cursor(0, y+n)
                when 'F'    # ESC[#F Moves cursor up # lines, column 1.
                  x, y = @Out.Cursor()
                  n = $3 == ''? 1 : $3.to_i;  # ESC[F == ESC[1F
                  @Out.Cursor(0, y-n)
                when 'G'   # ESC[#G Moves cursor column # in current row.
                  x, y = @Out.Cursor()
                  n = $3 == ''? 1 : $3.to_i;  # ESC[G == ESC[1G
                  @Out.Cursor(n-1, y)
                when 'f' # ESC[#;#f Moves cursor to line #, column #
                  y, x = $3.split(';')
                  x = 1 unless x    # ESC[;5H == ESC[1;5H ...etc
                  y = 1 unless y
                  @Out.Cursor(x.to_i-1, y.to_i-1) # origin (0,0) in DOS console
                when 'H' # ESC[#;#H  Moves cursor to line #, column #
                  y, x = $3.split(';')
                  x = 1 unless x    # ESC[;5H == ESC[1;5H ...etc
                  y = 1 unless y
                  @Out.Cursor(x.to_i-1, y.to_i-1) # origin (0,0) in DOS console
                when 's'       # ESC[s Saves cursor position for recall later
                  (@x, @y) = @Out.Cursor()
                when 'u'       # ESC[u Return to saved cursor position
                  @Out.Cursor(@x, @y)
                when 'U'     # ESC(U no mapping
                  @conv = nil
                when 'K'     # ESC(K mapping if it exist
                  @Out.OutputCP(OEM)      # restore original codepage
                  @conv = 1
                when 'X'     # ESC(#X codepage **EXPERIMENTAL**
                  @conv = nil
                  @Out.OutputCP($3)
                else
                  STDERR.puts "\e#$2#$3#$4 not implemented" if DEBUG # ESC-code not implemented
                end
              end
            else
              @Out.Write(_conv(s))
              s=''
            end
          end
        end

        def _conv(s)
          if @concealed
            s.gsub!( /\S/,' ')
          end
          return s
        end

      end

# end print overloading

    end
  end
end

$stdout = Win32::Console::ANSI::IO.new(:stdout)
$stderr = Win32::Console::ANSI::IO.new(:stderr)
