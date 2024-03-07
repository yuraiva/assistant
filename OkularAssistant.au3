; Okular- зделать заметку
#NoTrayIcon
#include-once
#include <WinAPIEx.au3>
#include <UIAutomate\UIA_Helper.au3>

HotKeySet("^{F12}", "_Exit")
HotKeySet("{INS}", "_OkularMakeNote")

Opt("TrayMenuMode", 1 + 2) ; Не отображать в трее пункты меню по умолчанию (Script Paused/Exit) и не отмечать галочками при выборе.
Opt("TrayOnEventMode", 1) ; Включает режим TrayOnEventMode.

TrayCreateItem("Информация")
TrayItemSetOnEvent(-1, "_Info")

TrayCreateItem("Создать закладку")
TrayItemSetOnEvent(-1, "_OkularMakeNote")

TrayCreateItem("Выход")
TrayItemSetOnEvent(-1, "_Exit")

TraySetState(1) ; Показывает меню трея

While 1
    Sleep(1000) ; Бездействующий цикл
WEnd

Func _Info()
    MsgBox(4096, "Информация", "Автоматизация создания закладок в Okular")
EndFunc

Func _Exit()
    Exit
EndFunc

Func _OkularMakeNote()
	Local $sClip="", $sKeyB="b", $sKeyV="v"
	If Not WinActive("[CLASS:Qt51510QWindowIcon;REGEXPTITLE:- Okular$]") Then Return MsgBox (16+4096,"Помошник Okular", "Чтобы сделать заметку окно Okular должно быть активно")
	ClipPut("")
	Local $sKeyC=_GetKeyboardLayout() <> 0x0409 ? "c" : "c"
	Send("^c")
	$sClip=ClipGet()
	ConsoleWrite($sClip & @CRLF)
	If $sClip  = "" Then
		$sKeyB="и"
		$sKeyV="м"
		Send("^с")
		$sClip=ClipGet()
	EndIf
	If $sClip = "" Then Return MsgBox (16,"Помошник Okular", "Не удалось получить выделенный текст в окне Okular")

	Sleep(500)
	Send("^"&$sKeyB)
	Sleep(500)
	Send("!"&$sKeyB)
	Sleep(500)
	Send("^"&$sKeyV)
	;Sleep(2000)
	;Send("{ENTER}")
EndFunc

Func _GetKeyboardLayout($vWinTitle="[ACTIVE]")
	Local $iRet='0x' & Hex(BitAND(_WinAPI_GetKeyboardLayout(WinGetHandle($vWinTitle)), 0xFFFF), 4)
	ConsoleWrite($iRet & @CRLF)

	Return $iRet
EndFunc

