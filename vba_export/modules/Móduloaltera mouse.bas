Option Explicit

'Constantes para identificar os diversos tipos de ponteiro do mouse
Public Const IDC_APPSTARTING = 32650&
Public Const IDC_HAND = 32649&
Public Const IDC_ARROW = 32512&
Public Const IDC_CROSS = 32515&
Public Const IDC_IBEAM = 32513&
Public Const IDC_ICON = 32641&
Public Const IDC_NO = 32648&
Public Const IDC_SIZE = 32640&
Public Const IDC_SIZEALL = 32646&
Public Const IDC_SIZENESW = 32643&
Public Const IDC_SIZENS = 32645&
Public Const IDC_SIZENWSE = 32642&
Public Const IDC_SIZEWE = 32644&
Public Const IDC_UPARROW = 32516&
Public Const IDC_WAIT = 32514&

Declare PtrSafe Function LoadCursorBynum Lib "User32" Alias "LoadCursorA" _
(ByVal hInstance As Long, ByVal lpCursorName As Long) As Long

Declare PtrSafe Function SetCursor Lib "User32" _
(ByVal hCursor As Long) As Long

Function MouseCursor(CursorType As Long)
Dim lngRet As Long
lngRet = LoadCursorBynum(0&, CursorType)
lngRet = SetCursor(lngRet)
End Function