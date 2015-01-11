unit WinRawInput;

interface

uses
  Windows;

type
  USHORT = Word;
  LONG   = LongInt;
  INT    = Integer;
  HANDLE = THandle;
  QWORD  = UInt64; 

const
  WM_INPUT               = $00FF;
  WM_INPUT_DEVICE_CHANGE = $00FE;

  //WM_INPUT / wParam
  RIM_INPUT     = 0;
  RIM_INPUTSINK = 1;

  //WM_INPUT_DEVICE_CHANGE / wParam
  GIDC_ARRIVAL = 1;
  GIDC_REMOVAL = 2;

  //RAWINPUTDEVICE.dwFlags
  RIDEV_APPKEYS      = $00000400;
  RIDEV_CAPTUREMOUSE = $00000200;
  RIDEV_DEVNOTIFY    = $00002000;
  RIDEV_EXCLUDE      = $00000010;
  RIDEV_EXINPUTSINK  = $00001000;
  RIDEV_INPUTSINK    = $00000100;
  RIDEV_NOHOTKEYS    = $00000200;
  RIDEV_NOLEGACY     = $00000030;
  RIDEV_PAGEONLY     = $00000020;
  RIDEV_REMOVE       = $00000001;

  //RAWINPUTDEVICELIST.dwType, RAWINPUTHEADER.dwType, RID_DEVICE_INFO.dwType
  RIM_TYPEHID      = 2;
  RIM_TYPEKEYBOARD = 1;
  RIM_TYPEMOUSE    = 0;

  //RAWMOUSE.usFlags
  MOUSE_ATTRIBUTES_CHANGED = $04;
  MOUSE_MOVE_RELATIVE      = $00;
  MOUSE_MOVE_ABSOLUTE      = $01;
  MOUSE_VIRTUAL_DESKTOP    = $02;

  //RAWMOUSE.usButtonFlags
  RI_MOUSE_LEFT_BUTTON_DOWN   = $0001;
  RI_MOUSE_LEFT_BUTTON_UP     = $0002;
  RI_MOUSE_MIDDLE_BUTTON_DOWN = $0010;
  RI_MOUSE_MIDDLE_BUTTON_UP   = $0020;
  RI_MOUSE_RIGHT_BUTTON_DOWN  = $0004;
  RI_MOUSE_RIGHT_BUTTON_UP    = $0008;
  RI_MOUSE_BUTTON_1_DOWN      = RI_MOUSE_LEFT_BUTTON_DOWN;
  RI_MOUSE_BUTTON_1_UP        = RI_MOUSE_LEFT_BUTTON_UP;
  RI_MOUSE_BUTTON_2_DOWN      = RI_MOUSE_RIGHT_BUTTON_DOWN;
  RI_MOUSE_BUTTON_2_UP        = RI_MOUSE_RIGHT_BUTTON_UP;
  RI_MOUSE_BUTTON_3_DOWN      = RI_MOUSE_MIDDLE_BUTTON_DOWN;
  RI_MOUSE_BUTTON_3_UP        = RI_MOUSE_MIDDLE_BUTTON_UP;
  RI_MOUSE_BUTTON_4_DOWN      = $0040;
  RI_MOUSE_BUTTON_4_UP        = $0080;
  RI_MOUSE_BUTTON_5_DOWN      = $0100;
  RI_MOUSE_BUTTON_5_UP        = $0200;
  RI_MOUSE_WHEEL              = $0400;

  //RAWKEYBOARD.Flags
  RI_KEY_BREAK = 1;
  RI_KEY_E0    = 2;
  RI_KEY_E1    = 4;
  RI_KEY_MAKE  = 0;


  //GetRawInputData / uiCommand
  RID_HEADER = $10000005;
  RID_INPUT  = $10000003;

  //GetRawInputDeviceInfo / uiCommand
  RIDI_DEVICENAME    = $20000007;
  RIDI_DEVICEINFO    = $2000000b;
  RIDI_PREPARSEDDATA = $20000005;


//==============================================================================

type
  HRAWINPUT = THandle;

//------------------------------------------------------------------------------

  tagRAWINPUTDEVICE = record
    usUsagePage:  USHORT;
    usUsage:      USHORT;
    dwFlags:      DWORD;
    hwndTarget:   HWND;
  end;
  
   RAWINPUTDEVICE = tagRAWINPUTDEVICE;
  TRAWINPUTDEVICE = tagRAWINPUTDEVICE;   
  PRAWINPUTDEVICE = ^TRAWINPUTDEVICE;
 LPRAWINPUTDEVICE = ^TRAWINPUTDEVICE;

  TRAWINPUTDEVICEARRAY = Array[0..High(Word)] of TRAWINPUTDEVICE;
  PRAWINPUTDEVICEARRAY = ^TRAWINPUTDEVICEARRAY;

//------------------------------------------------------------------------------

  tagRAWINPUTDEVICELIST = record
    hDevice:  HANDLE;
    dwType:   DWORD;
  end;

   RAWINPUTDEVICELIST = tagRAWINPUTDEVICELIST;
  TRAWINPUTDEVICELIST = tagRAWINPUTDEVICELIST;
  PRAWINPUTDEVICELIST = ^TRAWINPUTDEVICELIST;

//------------------------------------------------------------------------------

  tagRAWINPUTHEADER = record
    dwType:   DWORD;
    dwSize:   DWORD;
    hDevice:  HANDLE;
    wParam:   WPARAM;
  end;

   RAWINPUTHEADER = tagRAWINPUTHEADER;
  TRAWINPUTHEADER = tagRAWINPUTHEADER;
  PRAWINPUTHEADER = ^TRAWINPUTHEADER;

//------------------------------------------------------------------------------

  tagRAWMOUSE = record
    usFlags:  USHORT;
    case Integer of
      0:  (ulButtons: ULONG);
      1:  (usButtonFlags: USHORT;
           usButtonsData: USHORT;
    ulRawButtons:       ULONG;
    lLastX:             LONG;
    lLastY:             LONG;
    ulExtraInformation: ULONG);
  end;

   RAWMOUSE = tagRAWMOUSE;
  TRAWMOUSE = tagRAWMOUSE;
  PRAWMOUSE = ^TRAWMOUSE;
 LPRAWMOUSE = ^TRAWMOUSE;

//------------------------------------------------------------------------------

  tagRAWKEYBOARD = record
    MakeCode:         USHORT;
    Flags:            USHORT;
    Reserved:         USHORT;
    VKey:             USHORT;
    Message:          UINT;
    ExtraInformation: ULONG;
  end;

   RAWKEYBOARD = tagRAWKEYBOARD;
  TRAWKEYBOARD = tagRAWKEYBOARD;
  PRAWKEYBOARD = ^TRAWKEYBOARD;
 LPRAWKEYBOARD = ^TRAWKEYBOARD;

//------------------------------------------------------------------------------

  tagRAWHID = record
    dwSizeHid:  DWORD;
    dwCount:    DWORD;
    bRawData:   Byte;
  end;

   RAWHID = tagRAWHID;
  TRAWHID = tagRAWHID;
  PRAWHID = ^TRAWHID;
 LPRAWHID = ^TRAWHID; 

//------------------------------------------------------------------------------

  tagRAWINPUT = record
    header: RAWINPUTHEADER;
    case Integer of
      RIM_TYPEMOUSE:   (mouse:     RAWMOUSE);
      RIM_TYPEKEYBOARD:(keyboard:  RAWKEYBOARD);
      RIM_TYPEHID:     (hid:       RAWHID);
  end;
  
   RAWINPUT = tagRAWINPUT;
  TRAWINPUT = tagRAWINPUT;
  PRAWINPUT = ^TRAWINPUT;
 LPRAWINPUT = ^TRAWINPUT;

 PPRAWINPUT = ^PRAWINPUT;

//------------------------------------------------------------------------------

  tagRID_DEVICE_INFO_MOUSE = record
    dwId:                 DWORD;
    dwNumberOfButtons:    DWORD;
    dwSampleRate:         DWORD;
    fHasHorizontalWheel:  BOOL;
  end;

   RID_DEVICE_INFO_MOUSE = tagRID_DEVICE_INFO_MOUSE;
  TRID_DEVICE_INFO_MOUSE = tagRID_DEVICE_INFO_MOUSE;
  PRID_DEVICE_INFO_MOUSE = ^TRID_DEVICE_INFO_MOUSE;

//------------------------------------------------------------------------------

  tagRID_DEVICE_INFO_KEYBOARD = record
    dwType:                 DWORD;
    dwSubType:              DWORD;
    dwKeyboardMode:         DWORD;
    dwNumberOfFunctionKeys: DWORD;
    dwNumberOfIndicators:   DWORD;
    dwNumberOfKeysTotal:    DWORD;
  end;

   RID_DEVICE_INFO_KEYBOARD = tagRID_DEVICE_INFO_KEYBOARD;
  TRID_DEVICE_INFO_KEYBOARD = tagRID_DEVICE_INFO_KEYBOARD;
  PRID_DEVICE_INFO_KEYBOARD = ^TRID_DEVICE_INFO_KEYBOARD;

//------------------------------------------------------------------------------

  tagRID_DEVICE_INFO_HID = record
    dwVendorId:       DWORD;
    dwProductId:      DWORD;
    dwVersionNumber:  DWORD;
    usUsagePage:      USHORT;
    usUsage:          USHORT;
  end;

   RID_DEVICE_INFO_HID = tagRID_DEVICE_INFO_HID;
  TRID_DEVICE_INFO_HID = tagRID_DEVICE_INFO_HID;
  PRID_DEVICE_INFO_HID = ^TRID_DEVICE_INFO_HID;

//------------------------------------------------------------------------------

  tagRID_DEVICE_INFO = record
    cbSize: DWORD;
    case dwType: DWORD of
      RIM_TYPEMOUSE:   (mouse:    RID_DEVICE_INFO_MOUSE);
      RIM_TYPEKEYBOARD:(keyboard: RID_DEVICE_INFO_KEYBOARD);
      RIM_TYPEHID:     (hid:      RID_DEVICE_INFO_HID);
  end;

   RID_DEVICE_INFO = tagRID_DEVICE_INFO;
  TRID_DEVICE_INFO = tagRID_DEVICE_INFO;
  PRID_DEVICE_INFO = ^TRID_DEVICE_INFO;
 LPRID_DEVICE_INFO = ^TRID_DEVICE_INFO;  

//==============================================================================

Function DefRawInputProc(
            paRawInput:   PPRAWINPUT;
            nInput:       INT;
            cbSizeHeader: UINT): LRESULT; stdcall; external user32;

//------------------------------------------------------------------------------

Function GetRawInputBuffer(
            pData:        PRAWINPUT;
            pcbSize:      PUINT;
            cbSizeHeader: UINT): UINT; stdcall; external user32;

//------------------------------------------------------------------------------

Function GetRawInputData(
            hRawInput:    HRAWINPUT;
            uiCommand:    UINT;
            pData:        Pointer;
            pcbSize:      PUINT;
            cbSizeHeader: UINT): UINT; stdcall; external user32;

//------------------------------------------------------------------------------

Function GetRawInputDeviceInfo(
            hDevice:    THandle;
            uiCommand:  UINT;
            pData:      Pointer;
            pcbSize:    PUINT): UINT; stdcall; external user32 name{$IFDEF UNICODE}'GetRawInputDeviceInfoW'{$ELSE}'GetRawInputDeviceInfoA'{$ENDIF};

Function GetRawInputDeviceInfoA(
            hDevice:    THandle;
            uiCommand:  UINT;
            pData:      Pointer;
            pcbSize:    PUINT): UINT; stdcall; external user32 name 'GetRawInputDeviceInfoA';

Function GetRawInputDeviceInfoW(
            hDevice:    THandle;
            uiCommand:  UINT;
            pData:      Pointer;
            pcbSize:    PUINT): UINT; stdcall; external user32 name 'GetRawInputDeviceInfoW';

//------------------------------------------------------------------------------

Function GetRawInputDeviceList(
            pRawInputDeviceLis: PRAWINPUTDEVICELIST;
            puiNumDevices:      PUINT;
            cbSize:             UINT): UINT; stdcall; external user32;

//------------------------------------------------------------------------------

Function GetRegisteredRawInputDevices(
            pRawInputDevices: PRAWINPUTDEVICE;
            puiNumDevices:    PUINT;
            cbSize:           UINT): UINT; stdcall; external user32;

//------------------------------------------------------------------------------

Function RegisterRawInputDevices(
            pRawInputDevices: PRAWINPUTDEVICE;
            uiNumDevices:     UINT;
            cbSize:           UINT): BOOL; stdcall; external user32;

//==============================================================================

Function GET_RAWINPUT_CODE_WPARAM(wParam: WPARAM): WPARAM;
Function NEXTRAWINPUTBLOCK(ptr: PRAWINPUT): PRAWINPUT;

implementation

Function GET_RAWINPUT_CODE_WPARAM(wParam: WPARAM): WPARAM;
begin
Result := wParam and $FF;
end;

Function RAWINPUT_ALIGN(x: Pointer): Pointer;
begin
{$IFDEF x64}
{%H-}Result := Pointer((NativeInt(x) + SizeOf(QWORD) - 1) and not (SizeOf(QWORD) - 1));
{$ELSE}
{%H-}Result := Pointer((NativeInt(x) + SizeOf(DWORD) - 1) and not (SizeOf(DWORD) - 1));
{$ENDIF}
end;

Function NEXTRAWINPUTBLOCK(ptr: PRAWINPUT): PRAWINPUT;
begin
{%H-}Result := PRAWINPUT(RAWINPUT_ALIGN(Pointer(NativeInt(ptr) + ptr^.header.dwSize)));
end;

end.
