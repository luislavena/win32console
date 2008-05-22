
# The actual api to access windows functions
module Win32
  class Console
    class API
      require 'Win32API'

      class << self

        def constant(t)
          begin
            return Win32::Console::Constants.const_get(t)
          rescue
            return nil
          end
        end

       def AllocConsole()
         @AllocConsole ||= Win32API.new( "kernel32", "AllocConsole", [], 'l' )
         @AllocConsole.call()
       end

        def CreateConsoleScreenBuffer( dwDesiredAccess, dwShareMode, dwFlags )
          @CreateConsoleScreenBuffer ||= Win32API.new( "kernel32", "CreateConsoleScreenBuffer", ['l', 'l', 'p', 'l', 'p'], 'l' )
          @CreateConsoleScreenBuffer.call( dwDesiredAccess, dwShareMode, nil, dwFlags, nil )
        end

       def FillConsoleOutputAttribute( hConsoleOutput, wAttribute, nLength, col, row )
         @FillConsoleOutputAttribute ||= Win32API.new( "kernel32", "FillConsoleOutputAttribute", ['l', 'i', 'l', 'l', 'p'], 'l' )
         dwWriteCoord = (row << 16) + col
         lpNumberOfAttrsWritten = ' ' * 4
         @FillConsoleOutputAttribute.call( hConsoleOutput, wAttribute, nLength, dwWriteCoord, lpNumberOfAttrsWritten )
         return lpNumberOfAttrsWritten.unpack('L')
       end

       def FillConsoleOutputCharacter( hConsoleOutput, cCharacter, nLength, col, row )
         @FillConsoleOutputCharacter ||= Win32API.new( "kernel32", "FillConsoleOutputCharacter", ['l', 'i', 'l', 'l', 'p'], 'l' )
          dwWriteCoord = (row << 16) + col
          lpNumberOfAttrsWritten = ' ' * 4
         @FillConsoleOutputCharacter.call( hConsoleOutput, cCharacter, nLength, dwWriteCoord, lpNumberOfAttrsWritten )
          return lpNumberOfAttrsWritten.unpack('L')
       end

       def FlushConsoleInputBuffer( hConsoleInput )
         @FlushConsoleInputBuffer ||= Win32API.new( "kernel32", "FillConsoleInputBuffer", ['l'], 'l' )
         @FlushConsoleInputBuffer.call( hConsoleInput )
       end

       def FreeConsole()
         @FreeConsole ||= Win32API.new( "kernel32", "FreeConsole", [], 'l' )
         @FreeConsole.call()
       end

       def GenerateConsoleCtrlEvent( dwCtrlEvent, dwProcessGroupId )
         @GenerateConsoleCtrlEvent ||= Win32API.new( "kernel32", "GenerateConsoleCtrlEvent", ['l', 'l'], 'l' )
         @GenerateConsoleCtrlEvent.call( dwCtrlEvent, dwProcessGroupId )
       end

       def GetConsoleCP()
         @GetConsoleCP ||= Win32API.new( "kernel32", "GetConsoleCP", [], 'l' )
         @GetConsoleCP.call()
       end

       def GetConsoleCursorInfo( hConsoleOutput )
         @GetConsoleCursorInfo ||= Win32API.new( "kernel32", "GetConsoleCursorInfo", ['l', 'p'], 'l' )
          lpConsoleCursorInfo = ' ' * 8
         @GetConsoleCursorInfo.call( hConsoleOutput, lpConsoleCursorInfo )
          return lpConsoleCursorInfo.unpack('LL')
       end

        def GetConsoleMode( hConsoleHandle )
          @GetConsoleMode ||= Win32API.new( "kernel32", "GetConsoleMode", ['l', 'p'], 'l' )
          lpMode = ' ' * 4
          @GetConsoleMode.call( hConsoleHandle, lpMode )
          return lpMode.unpack('L').first
        end

       def GetConsoleOutputCP()
         @GetConsoleOutputCP ||= Win32API.new( "kernel32", "GetConsoleOutputCP", [], 'l' )
         @GetConsoleOutputCP.call()
       end

       def GetConsoleScreenBufferInfo( hConsoleOutput )
         @GetConsoleScreenBufferInfo ||= Win32API.new( "kernel32", "GetConsoleScreenBufferInfo", ['l', 'p'], 'l' )
          lpBuffer = ' ' * 22
         @GetConsoleScreenBufferInfo.call( hConsoleOutput, lpBuffer )
          return lpBuffer.unpack('SSSSSssssSS')
       end

       def GetConsoleTitle()
          @GetConsoleTitle ||= Win32API.new( "kernel32", "GetConsoleTitle", ['p', 'l'], 'l' )
          nSize = 120
          lpConsoleTitle = ' ' * nSize
          @GetConsoleTitle.call( lpConsoleTitle, nSize )
          return lpConsoleTitle.strip
        end

       def GetConsoleWindow()
         @GetConsoleWindow ||= Win32API.new( "kernel32", "GetConsoleWindow",[], 'l' )
         @GetConsoleWindow.call()
       end

        def GetLargestConsoleWindowSize( hConsoleOutput )
          @GetLargestConsoleWindowSize ||= Win32API.new( "kernel32", "GetLargestConsoleWindowSize", ['l'], 'l' )
          coord = @GetLargestConsoleWindowSize.call( hConsoleOutput )
          x = coord >> 16
          y = coord & 0x0000ffff
          return [x,y]
        end

        def GetNumberOfConsoleInputEvents( hConsoleInput )
          @GetNumberOfConsoleInputEvents ||= Win32API.new( "kernel32", "GetNumberOfConsoleInputEvents", ['l', 'p'], 'l' )
          lpcNumberOfEvents = 0
          @GetNumberOfConsoleInputEvents.call( hConsoleInput, lpcNumberOfEvents )
          return lpcNumberOfEvents
        end

        def GetNumberOfConsoleMouseButtons( )
          @GetNumberOfConsoleMouseButtons ||= Win32API.new( "kernel32", "GetNumberOfConsoleMouseButtons", ['p'], 'l' )
          lpNumberOfMouseButtons = 0
          @GetNumberOfConsoleMouseButtons.call( lpNumberOfMouseButtons )
          return lpNumberOfMouseButtons
        end

       def GetStdHandle( nStdHandle )
         @GetStdHandle ||= Win32API.new( "kernel32", "GetStdHandle", ['l'], 'l' )
         @GetStdHandle.call( nStdHandle )
       end

        # <<HandlerRoutine>> : This is not an actual API function, just a concept description in the SDK.

        def PeekConsoleInput( hConsoleInput )
          @PeekConsoleInput ||= Win32API.new( "kernel32", "PeekConsoleInput", ['l', 'p', 'l', 'p'], 'l' )
          lpNumberOfEventsRead = ' ' * 4
          lpBuffer = ' ' * 20
          nLength  = 20
          @PeekConsoleInput.call( hConsoleInput, lpBuffer, nLength, lpNumberOfEventsRead )
          type = lpBuffer.unpack('s')[0]

          case type
          when KEY_EVENT
            return lpBuffer.unpack('sSSSSCS')
          when MOUSE_EVENT
            return lpBuffer.unpack('sSSSS')
          when WINDOW_BUFFER_SIZE_EVENT
            return lpBuffer.unpack('sS')
          when MENU_EVENT
            return lpBuffer.unpack('sS')
          when FOCUS_EVENT
            return lpBuffer.unpack('sS')
          else
            return []
          end
        end

        def ReadConsole( hConsoleInput, lpBuffer, nNumberOfCharsToRead )
          @ReadConsole ||= Win32API.new( "kernel32", "ReadConsole", ['l', 'p', 'l', 'p', 'p'], 'l' )
          lpBuffer = ' ' * nNumberOfCharsToRead unless lpBuffer
          lpNumberOfCharsRead = ' ' * 4
          lpReserved = ' ' * 4
          @ReadConsole.call( hConsoleInput, lpBuffer, nNumberOfCharsToRead, lpNumberOfCharsRead, lpReserved )
          return lpNumberOfCharsRead.unpack('L')
        end

        def ReadConsoleInput( hConsoleInput )
          @ReadConsoleInput ||= Win32API.new( "kernel32", "ReadConsoleInput", ['l', 'p', 'l', 'p'], 'l' )
          lpNumberOfEventsRead = ' ' * 4
          lpBuffer = ' ' * 20
          nLength  = 20
          @ReadConsoleInput.call( hConsoleInput, lpBuffer, nLength,
                                    lpNumberOfEventsRead )
          type = lpBuffer.unpack('s')[0]

          case type
          when KEY_EVENT
            return lpBuffer.unpack('sSSSSCS')
          when MOUSE_EVENT
            return lpBuffer.unpack('sSSSS')
          when WINDOW_BUFFER_SIZE_EVENT
            return lpBuffer.unpack('sS')
          when MENU_EVENT
            return lpBuffer.unpack('sS')
          when FOCUS_EVENT
            return lpBuffer.unpack('sS')
          else
            return []
          end
        end

        def ReadConsoleOutput( hConsoleOutput, lpBuffer, cols, rows, bufx, bufy, left, top, right, bottom )
          @ReadConsoleOutput ||= Win32API.new( "kernel32", "ReadConsoleOutput", ['l', 'p', 'l', 'l', 'p'], 'l' )
          dwBufferSize  = cols * rows * 4
          lpBuffer = ' ' * dwBufferSize
          dwBufferCoord = (bufy << 16) + bufx
          lpReadRegion  = [ left, top, right, bottom ].pack('ssss')
          @ReadConsoleOutput.call( hConsoleOutput, lpBuffer, dwBufferSize,
                                     dwBufferCoord, lpReadRegion )
        end

        def ReadConsoleOutputAttribute( hConsoleOutput, nLength, col, row )
          @ReadConsoleOutputAttribute ||= Win32API.new( "kernel32", "ReadConsoleOutputAttribute", ['l', 'p', 'l', 'l', 'p'], 'l' )
          lpAttribute = ' ' * nLength
          dwReadCoord = (row << 16) + col
          lpNumberOfAttrsRead = ' ' * 4
          @ReadConsoleOutputAttribute.call( hConsoleOutput, lpAttribute, nLength, dwReadCoord, lpNumberOfAttrsRead )
          return lpAttribute
        end

        def ReadConsoleOutputCharacter( hConsoleOutput, lpCharacter, nLength,  col, row )
          @ReadConsoleOutputCharacter ||= Win32API.new( "kernel32", "ReadConsoleOutputCharacter", ['l', 'p', 'l', 'l', 'p'], 'l' )
          dwReadCoord = (row << 16) + col
          lpNumberOfCharsRead = ' ' * 4
          @ReadConsoleOutputCharacter.call( hConsoleOutput, lpCharacter, nLength, dwReadCoord, lpNumberOfCharsRead )
          return lpNumberOfCharsRead.unpack('L')
        end

        def ScrollConsoleScreenBuffer( hConsoleOutput, left1, top1, right1, bottom1,col, row, char, attr, left2, top2, right2, bottom2 )
          @ScrollConsoleScreenBuffer ||= Win32API.new( "kernel32", "ScrollConsoleScreenBuffer", ['l', 'p', 'p', 'l', 'p'], 'l' )
          lpScrollRectangle = [left1, top1, right1, bottom1].pack('ssss')
          lpClipRectangle   = [left2, top2, right2, bottom2].pack('ssss')
          dwDestinationOrigin = (row << 16) + col
          lpFill = [char, attr].pack('ss')
          @ScrollConsoleScreenBuffer.call( hConsoleOutput, lpScrollRectangle, lpClipRectangle, dwDestinationOrigin, lpFill )
        end

        def SetConsoleActiveScreenBuffer( hConsoleOutput )
          @SetConsoleActiveScreenBuffer ||= Win32API.new( "kernel32", "SetConsoleActiveScreenBuffer", ['l'], 'l' )
          @SetConsoleActiveScreenBuffer.call( hConsoleOutput )
        end

        # <<SetConsoleCtrlHandler>>:  Will probably not be implemented.

        def SetConsoleCP( wCodePageID )
          @SetConsoleCP ||= Win32API.new( "kernel32", "SetConsoleCP", ['l'], 'l' )
          @SetConsoleCP.call( wCodePageID )
        end

        def SetConsoleCursorInfo( hConsoleOutput, col, row )
          @SetConsoleCursorInfo ||= Win32API.new( "kernel32", "SetConsoleCursorInfo", ['l', 'p'], 'l' )
          lpConsoleCursorInfo = [size,visi].pack('LL')
          @SetConsoleCursorInfo.call( hConsoleOutput, lpConsoleCursorInfo )
        end

        def SetConsoleCursorPosition( hConsoleOutput, col, row )
          @SetConsoleCursorPosition ||= Win32API.new( "kernel32", "SetConsoleCursorPosition", ['l', 'p'], 'l' )
          dwCursorPosition = (row << 16) + col
          @SetConsoleCursorPosition.call( hConsoleOutput, dwCursorPosition )
        end

        def SetConsoleMode( hConsoleHandle, lpMode )
          @SetConsoleMode ||= Win32API.new( "kernel32", "SetConsoleMode", ['l', 'p'], 'l' )
          @SetConsoleMode.call( hConsoleHandle, lpMode )
        end

        def SetConsoleOutputCP( wCodePageID )
          @SetConsoleOutputCP ||= Win32API.new( "kernel32", "GetConsoleOutputCP", ['l'], 'l' )
          @SetConsoleOutputCP.call( wCodePageID )
        end

        def SetConsoleScreenBufferSize( hConsoleOutput, col, row )
          @SetConsoleScreenBufferSize ||= Win32API.new( "kernel32", "SetConsoleScreenBufferSize", ['l', 'l'], 'l' )
          dwSize = (row << 16) + col
          @SetConsoleScreenBufferSize.call( hConsoleOutput, dwSize )
        end

        def SetConsoleTextAttribute( hConsoleOutput, wAttributes )
          @SetConsoleTextAttribute ||= Win32API.new( "kernel32", "SetConsoleTextAttribute", ['l', 'i'], 'l' )
          @SetConsoleTextAttribute.call( hConsoleOutput, wAttributes )
        end

        def SetConsoleTitle( lpConsoleTitle )
          @SetConsoleTitle ||= Win32API.new( "kernel32", "SetConsoleTitle", ['p'], 'l' )
          @SetConsoleTitle.call( lpConsoleTitle )
        end

        def SetConsoleWindowInfo( hConsoleOutput, bAbsolute, left, top, right, bottom )
          @SetConsoleWindowInfo ||= Win32API.new( "kernel32", "SetConsoleWindowInfo", ['l', 'l', 'p'], 'l' )
          lpConsoleWindow = [ left, top, right, bottom ].pack('ssss')
          @SetConsoleWindowInfo.call( hConsoleOutput, bAbsolute, lpConsoleWindow )
        end

        def SetStdHandle( nStdHandle, hHandle )
          @SetStdHandle ||= Win32API.new( "kernel32", "SetStdHandle", ['l', 'l'], 'l' )
          @SetStdHandle.call( nStdHandle, hHandle )
        end

        def WriteConsole( hConsoleOutput, lpBuffer )
          @WriteConsole ||= Win32API.new( "kernel32", "WriteConsole", ['l', 'p', 'l', 'p', 'p'], 'l' )
          nNumberOfCharsToWrite = lpBuffer.length()
          lpNumberOfCharsWritten = ' ' * 4
          lpReserved = ' ' * 4
          @WriteConsole.call( hConsoleOutput, lpBuffer, nNumberOfCharsToWrite, lpNumberOfCharsWritten,  lpReserved )
          return lpNumberOfCharsWritten
        end

        def WriteFile( hConsoleOutput, lpBuffer )
          @WriteFile ||= Win32API.new( "kernel32", "WriteFile", ['l', 'p', 'l', 'p', 'p'], 'l' )
          nNumberOfBytesToWrite = lpBuffer.length()
          lpNumberOfBytesWritten = ' ' * 4
          lpReserved = nil
          @WriteFile.call( hConsoleOutput, lpBuffer, nNumberOfBytesToWrite, lpNumberOfBytesWritten,  lpReserved )
          return lpNumberOfBytesWritten.unpack('L')
        end

        def WriteConsoleInput( hConsoleInput, lpBuffer )
          @WriteConsoleInput ||= Win32API.new( "kernel32", "WriteConsoleInput", ['l', 'p', 'l', 'p'], 'l' )
          @WriteConsoleInput.call( hConsoleInput, lpBuffer, nLength,  lpNumberOfEventsWritten )
        end

        # @@ Todo: Test this
        def WriteConsoleOutput( hConsoleOutput, buffer, cols, rows, bufx, bufy, left, top, right, bottom )
          @WriteConsoleOutput ||= Win32API.new( "kernel32", "WriteConsoleOutput", ['l', 'p', 'l', 'l', 'p'], 'l' )
          lpBuffer = buffer.flatten.pack('ss' * buffer.length() * 2)
          dwBufferSize = (buffer.length() << 16) + 2
          dwBufferCoord = (row << 16) + col
          lpWriteRegion = [ left, top, right, bottom ].pack('ssss')
          @WriteConsoleOutput.call( hConsoleOutput, lpBuffer, dwBufferSize, dwBufferCoord, lpWriteRegion )
        end

        def WriteConsoleOutputAttribute( hConsoleOutput, lpAttribute, col, row )
          @WriteConsoleOutputAttribute ||= Win32API.new( "kernel32", "WriteConsoleOutputAttribute", ['l', 'p', 'l', 'l', 'p'], 'l' )
          nLength = lpAttribute.length()
          dwWriteCoord = (row << 16) + col
          lpNumberOfAttrsWritten = ' ' * 4
          @WriteConsoleOutputAttribute.call( hConsoleOutput, lpAttribute, nLength, dwWriteCoord, lpNumberOfAttrsWritten )
          return lpNumberOfAttrsWritten.unpack('L')
        end

        def WriteConsoleOutputCharacter( hConsoleOutput, lpCharacter, col, row )
          @WriteConsoleOutputCharacter ||= Win32API.new( "kernel32", "WriteConsoleOutputCharacter", ['l', 'p', 'l', 'l', 'p'], 'l' )
          nLength = lpCharacter.length()
          dwWriteCoord = (row << 16) + col
          lpNumberOfCharsWritten = ' ' * 4
          @WriteConsoleOutputCharacter.call( hConsoleOutput, lpCharacter, nLength, dwWriteCoord, lpNumberOfCharsWritten )
          return lpNumberOfCharsWritten.unpack('L')
        end

      end
    end
  end

end