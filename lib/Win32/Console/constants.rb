# The WINDOWS constants

module Win32
  class Console
    module Constants
      STD_INPUT_HANDLE          = 0xFFFFFFF6
      STD_OUTPUT_HANDLE         = 0xFFFFFFF5
      STD_ERROR_HANDLE          = 0xFFFFFFF4
      INVALID_HANDLE_VALUE      = 0xFFFFFFFF
      GENERIC_READ              = 0x80000000
      GENERIC_WRITE             = 0x40000000
      FILE_SHARE_READ           = 0x00000001
      FILE_SHARE_WRITE          = 0x00000002
      CONSOLE_TEXTMODE_BUFFER   = 0x00000001
  
      FOREGROUND_BLUE           = 0x0001
      FOREGROUND_GREEN          = 0x0002
      FOREGROUND_RED            = 0x0004
      FOREGROUND_INTENSITY      = 0x0008
      BACKGROUND_BLUE           = 0x0010
      BACKGROUND_GREEN          = 0x0020
      BACKGROUND_RED            = 0x0040
      BACKGROUND_INTENSITY      = 0x0080
  
      ENABLE_PROCESSED_INPUT    = 0x0001
      ENABLE_LINE_INPUT         = 0x0002
      ENABLE_ECHO_INPUT         = 0x0004
      ENABLE_WINDOW_INPUT       = 0x0008
      ENABLE_MOUSE_INPUT        = 0x0010
      ENABLE_PROCESSED_OUTPUT   = 0x0001
      ENABLE_WRAP_AT_EOL_OUTPUT = 0x0002
  
      KEY_EVENT                 = 0x0001
      MOUSE_EVENT               = 0x0002
      WINDOW_BUFFER_SIZE_EVENT  = 0x0004
      MENU_EVENT                = 0x0008
      FOCUS_EVENT               = 0x0010
  
      CAPSLOCK_ON               = 0x0080
      ENHANCED_KEY              = 0x0100
      NUMLOCK_ON                = 0x0020
      SHIFT_PRESSED             = 0x0010
      LEFT_CTRL_PRESSED         = 0x0008
      RIGHT_CTRL_PRESSED        = 0x0004
      LEFT_ALT_PRESSED          = 0x0002
      RIGHT_ALT_PRESSED         = 0x0001
      SCROLLLOCK_ON             = 0x0040
  
      MOUSE_WHEELED             = 0x0004
      DOUBLE_CLICK              = 0x0002
      MOUSE_MOVED               = 0x0001
  
      FROM_LEFT_1ST_BUTTON_PRESSED    = 0x0001
      FROM_LEFT_2ND_BUTTON_PRESSED    = 0x0004
      FROM_LEFT_3RD_BUTTON_PRESSED    = 0x0008
      FROM_LEFT_4TH_BUTTON_PRESSED    = 0x0010
      RIGHTMOST_BUTTON_PRESSED        = 0x0002
  
      CTRL_C_EVENT              = 0x0000
      CTRL_BREAK_EVENT          = 0x0001
      CTRL_CLOSE_EVENT          = 0x0002
      CTRL_LOGOFF_EVENT         = 0x0005
      CTRL_SHUTDOWN_EVENT       = 0x0006
    end
  end
end