# Win32::Console:  an object implementing the Win32 API Console functions
# Copyright (C) 2003 Gonzalo Garramuno (ggarramuno@aol.com)
#
# Original Win32API_Console was:
# Copyright (C) 2001 Michael L. Semon (mlsemon@sega.net)

# support multiple ruby version (fat binaries under windows)
begin
  require 'Console_ext'
rescue LoadError
  RUBY_VERSION =~ /(\d+.\d+)/
  require "#{$1}/Console_ext"
end

module Win32
  class Console

    VERSION = '1.0'

    include Win32::Console::Constants

    def initialize( t = nil )
      if t and ( t == STD_INPUT_HANDLE or t == STD_OUTPUT_HANDLE or
                 t == STD_ERROR_HANDLE )
        @handle = API.GetStdHandle( t )
      else
        param1 = GENERIC_READ    | GENERIC_WRITE
        param2 = FILE_SHARE_READ | FILE_SHARE_WRITE
        @handle = API.CreateConsoleScreenBuffer( param1, param2,
                                                 CONSOLE_TEXTMODE_BUFFER )
      end

      # Preserve original attribute setting, so Cls can use it
      if (t == STD_OUTPUT_HANDLE or t == STD_ERROR_HANDLE) and not redirected?
        @attr_default = self.Attr
      end
    end

    def Display
      return API.SetConsoleActiveScreenBuffer(@handle)
    end

    def Select(type)
      return API.SetStdHandle(type,@handle)
    end

    def Title(title = nil)
      if title
        return API.SetConsoleTitle(title)
      else
        return API.GetConsoleTitle()
      end
    end

    def WriteChar(s, col, row)
      API.WriteConsoleOutputCharacter( @handle, s, col, row )
    end

    def ReadChar(size, col, row)
      buffer = ' ' * size
      if API.ReadConsoleOutputCharacter( @handle, buffer, size, col, row )
        return buffer
      else
        return nil
      end
    end

    def WriteAttr(attr, col, row)
      API.WriteConsoleOutputAttribute( @handle, attr, col, row )
    end

    def ReadAttr(size, col, row)
      x = API.ReadConsoleOutputAttribute( @handle, size, col, row )
      return x.unpack('c'*size)
    end

    def Cursor(*t)
      col, row, size, visi = t
      if col
        row = -1 if !row
        if col < 0 or row < 0
          curr_col, curr_row = API.GetConsoleScreenBufferInfo(@handle)
          col = curr_col if col < 0
          row = curr_row if row < 0
        end
        API.SetConsoleCursorPosition( @handle, col, row )
        if size and visi
          curr_size, curr_visi = API.GetConsoleCursorInfo( @handle )
          size = curr_size if size < 0
          visi = curr_visi if visi < 0
          size = 1 if size < 1
          size = 99 if size > 99
          API.SetConsoleCursorInfo( @handle, size, visi )
        end
      else
        d, d, curr_col, curr_row = API.GetConsoleScreenBufferInfo(@handle)
        curr_size, curr_visi = API.GetConsoleCursorInfo( @handle )
        return [ curr_col, curr_row, curr_size, curr_visi ]
      end
    end

    def Write(s)
      API.WriteConsole( @handle, s )
    end

    def WriteFile(s)
      API.WriteFile( @handle, s)
    end

    def ReadRect( left, top, right, bottom )
      col = right  - left + 1
      row = bottom - top  + 1
      size = col * row
      buffer = ' ' * size * 4
      if API.ReadConsoleOutput( @handle, buffer, col, row, 0, 0,
                               left, top, right, bottom )
        #return buffer.unpack('US'*size)  # for unicode
        return buffer.unpack('axS'*size)  # for ascii
      else
        return nil
      end
    end

    def WriteRect( buffer, left, top, right, bottom )
      col = right  - left + 1
      row = bottom - top  + 1
      API.WriteConsoleOutput( @handle, buffer, col, row, 0, 0,
                             left, top, right, bottom )
    end

    def Scroll( left1, top1, right1, bottom1,
               col, row, char, attr,
               left2, top2, right2, bottom2 )
      API.ScrollConsoleScreenBuffer(@handle, left1, top1, right1, bottom1,
                                    col, row, char, attr,
                                    left2, top2, right2, bottom2)
    end

    def MaxWindow(flag = nil)
      if !flag
        info = API.GetConsoleScreenBufferInfo(@handle)
        return info[9], info[10]
      else
        return API.GetLargestConsoleWindowSize(@handle)
      end
    end

    def Info()
      return API.GetConsoleScreenBufferInfo( @handle )
    end

    def GetEvents()
      return API.GetNumberOfConsoleInputEvents(@handle)
    end

    def Flush()
      return API.FlushConsoleInputBuffer(@handle)
    end

    def InputChar(number = nil)
      number = 1 unless number
      buffer = ' ' * number
      if API.ReadConsole(@handle, buffer, number) == number
        return buffer
      else
        return nil
      end
    end

    def Input()
      API.ReadConsoleInput(@handle)
    end

    def PeekInput()
      API.PeekConsoleInput(@handle)
    end

    def Mode(mode = nil)
      if mode
        mode = mode.pack('L') if mode === Array
        API.SetConsoleMode(@handle, mode)
      else
        begin
          x =  API.GetConsoleMode(@handle)
          return x
        rescue
          return 9999
        end
      end
    end

    def Echo(flag = nil)
      if flag.nil?
        (self.Mode & ENABLE_ECHO_INPUT) == ENABLE_ECHO_INPUT
      elsif flag
        self.Mode(self.Mode |  ENABLE_ECHO_INPUT)
      else
        self.Mode(self.Mode & ~ENABLE_ECHO_INPUT)
      end
    end

    def WriteInput(*t)
      API.WriteConsoleInput(@handle, *t)
    end

    def Attr(*attr)
      if attr.size > 0
        API.SetConsoleTextAttribute( @handle, attr[0] )
      else
        info = API.GetConsoleScreenBufferInfo( @handle )
        return info[4]
      end
    end

    def DefaultBold # Foreground Intensity
      self.Attr[3] == 1
    end

    def DefaultUnderline # Background Intensity
      self.Attr[7] == 1
    end

    def DefaultForeground
      a = self.Attr
      (0..2).map{|i| a[i] }.inject(0){|num, bit| (num << 1) + bit }
    end

    def DefaultBackground
      a = self.Attr
      (4..6).map{|i| a[i] }.inject(0){|num, bit| (num << 1) + bit }
    end

    def Size(*t)
      if t.size == 0
        col, row = API.GetConsoleScreenBufferInfo(@handle )
        return [col, row]
      else
        row = -1 if !t[1]
        col = -1 if !t[0]
        if col < 0 or row < 0
          curr_col, curr_row = Size()
          col = curr_col if col < 0
          row = curr_row if row < 0
        end
        API.SetConsoleScreenBufferSize(@handle, row, col)
      end
    end

    def Window(*t)
      if t.size != 5
        info = API.GetConsoleScreenBufferInfo( @handle )
        return info[5..8]
      else
        API.SetConsoleWindowInfo(@handle, t[0], t[1], t[2], t[3], t[4])
      end
    end

    def FillAttr(attr, number = 1, col = -1, row = -1)
      if col < 0 or row < 0
        d, d, curr_col, curr_row = API.GetConsoleScreenBufferInfo(@handle)
        col = curr_col if col < 0
        row = curr_row if row < 0
      end
      API.FillConsoleOutputAttribute(@handle, attr, number, col, row)
    end

    def FillChar(char, number, col = -1, row = -1)
      if col < 0 or row < 0
        d, d, curr_col, curr_row = API.GetConsoleScreenBufferInfo(@handle)
        col = curr_col if col < 0
        row = curr_row if row < 0
      end
      API.FillConsoleOutputCharacter(@handle, char[0], number, col, row)
    end

    def Cls()
      attr = @attr_default || ATTR_NORMAL
      x, y = Size()
      left, top, right , bottom = Window()
      vx = right  - left
      vy = bottom - top
      FillChar(' ', x*y, 0, 0)
      FillAttr(attr, x*y, 0, 0)
      Cursor(0,0)
      Window(1,0,0,vx,vy)
    end

    # Return true if console is redirected or piped and no longer is outputing
    # to the normal console.
    #
    # This can be used to determine if normal console operations will be
    # available.
    def redirected?
      self.Mode > 31
    end

    def Console.Free()
      API.FreeConsole()
    end

    def Console.Alloc()
      API.AllocConsole()
    end

    def Console.MouseButtons()
      API.GetNumberOfConsoleMouseButtons()
    end

    def Console.InputCP(codepage=nil)
      if codepage
        API.SetConsoleCP(codepage)
      else
        return API.GetConsoleCP()
      end
    end

    def Console.OutputCP(codepage=nil)
      if codepage
        API.SetConsoleOutputCP(codepage)
      else
        return API.GetConsoleOutputCP()
      end
    end

    def Console.GenerateCtrlEvent( type=nil, pid=nil )
      type = API.constant('CTRL_C_EVENT') if type == nil
      pid  = 0 if pid == nil
      API.GenerateConsoleCtrlEvent(type, pid)
    end

  end
end


FG_BLACK        = 0
FG_BLUE         = Win32::Console::API.constant("FOREGROUND_BLUE")
FG_LIGHTBLUE    = Win32::Console::API.constant("FOREGROUND_BLUE")|
                  Win32::Console::API.constant("FOREGROUND_INTENSITY")
FG_RED          = Win32::Console::API.constant("FOREGROUND_RED")
FG_LIGHTRED     = Win32::Console::API.constant("FOREGROUND_RED")|
                  Win32::Console::API.constant("FOREGROUND_INTENSITY")
FG_GREEN        = Win32::Console::API.constant("FOREGROUND_GREEN")
FG_LIGHTGREEN   = Win32::Console::API.constant("FOREGROUND_GREEN")|
                  Win32::Console::API.constant("FOREGROUND_INTENSITY")
FG_MAGENTA      = Win32::Console::API.constant("FOREGROUND_RED")|
                  Win32::Console::API.constant("FOREGROUND_BLUE")
FG_LIGHTMAGENTA = Win32::Console::API.constant("FOREGROUND_RED")|
                  Win32::Console::API.constant("FOREGROUND_BLUE")|
                  Win32::Console::API.constant("FOREGROUND_INTENSITY")
FG_CYAN         = Win32::Console::API.constant("FOREGROUND_GREEN")|
                  Win32::Console::API.constant("FOREGROUND_BLUE")
FG_LIGHTCYAN    = Win32::Console::API.constant("FOREGROUND_GREEN")|
                  Win32::Console::API.constant("FOREGROUND_BLUE")|
                  Win32::Console::API.constant("FOREGROUND_INTENSITY")
FG_BROWN        = Win32::Console::API.constant("FOREGROUND_RED")|
                  Win32::Console::API.constant("FOREGROUND_GREEN")
FG_YELLOW       = Win32::Console::API.constant("FOREGROUND_RED")|
                  Win32::Console::API.constant("FOREGROUND_GREEN")|
                  Win32::Console::API.constant("FOREGROUND_INTENSITY")
FG_GRAY         = Win32::Console::API.constant("FOREGROUND_RED")|
                  Win32::Console::API.constant("FOREGROUND_GREEN")|
                  Win32::Console::API.constant("FOREGROUND_BLUE")
FG_WHITE        = Win32::Console::API.constant("FOREGROUND_RED")|
                  Win32::Console::API.constant("FOREGROUND_GREEN")|
                  Win32::Console::API.constant("FOREGROUND_BLUE")|
                  Win32::Console::API.constant("FOREGROUND_INTENSITY")

BG_BLACK        = 0
BG_BLUE         = Win32::Console::API.constant("BACKGROUND_BLUE")
BG_LIGHTBLUE    = Win32::Console::API.constant("BACKGROUND_BLUE")|
                  Win32::Console::API.constant("BACKGROUND_INTENSITY")
BG_RED          = Win32::Console::API.constant("BACKGROUND_RED")
BG_LIGHTRED     = Win32::Console::API.constant("BACKGROUND_RED")|
                  Win32::Console::API.constant("BACKGROUND_INTENSITY")
BG_GREEN        = Win32::Console::API.constant("BACKGROUND_GREEN")
BG_LIGHTGREEN   = Win32::Console::API.constant("BACKGROUND_GREEN")|
                  Win32::Console::API.constant("BACKGROUND_INTENSITY")
BG_MAGENTA      = Win32::Console::API.constant("BACKGROUND_RED")|
                  Win32::Console::API.constant("BACKGROUND_BLUE")
BG_LIGHTMAGENTA = Win32::Console::API.constant("BACKGROUND_RED")|
                  Win32::Console::API.constant("BACKGROUND_BLUE")|
                  Win32::Console::API.constant("BACKGROUND_INTENSITY")
BG_CYAN         = Win32::Console::API.constant("BACKGROUND_GREEN")|
                  Win32::Console::API.constant("BACKGROUND_BLUE")
BG_LIGHTCYAN    = Win32::Console::API.constant("BACKGROUND_GREEN")|
                  Win32::Console::API.constant("BACKGROUND_BLUE")|
                  Win32::Console::API.constant("BACKGROUND_INTENSITY")
BG_BROWN        = Win32::Console::API.constant("BACKGROUND_RED")|
                  Win32::Console::API.constant("BACKGROUND_GREEN")
BG_YELLOW       = Win32::Console::API.constant("BACKGROUND_RED")|
                  Win32::Console::API.constant("BACKGROUND_GREEN")|
                  Win32::Console::API.constant("BACKGROUND_INTENSITY")
BG_GRAY         = Win32::Console::API.constant("BACKGROUND_RED")|
                  Win32::Console::API.constant("BACKGROUND_GREEN")|
                  Win32::Console::API.constant("BACKGROUND_BLUE")
BG_WHITE        = Win32::Console::API.constant("BACKGROUND_RED")|
                  Win32::Console::API.constant("BACKGROUND_GREEN")|
                  Win32::Console::API.constant("BACKGROUND_BLUE")|
                  Win32::Console::API.constant("BACKGROUND_INTENSITY")

ATTR_NORMAL  = FG_GRAY  | BG_BLACK
ATTR_INVERSE = FG_BLACK | BG_GRAY

include Win32::Console::Constants
