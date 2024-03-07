
#NoTrayIcon
#include-once
#include <ScreenCapture.au3>
#include <TrayConstants.au3>
#include <_FileDirList.au3>
;~ #include <Misc.au3>; IsPressed()
;~ #include <WinAPIEx.au3>; _WinAPI_GetKeyboardLayout, _WinAPI_SetKeyboardLayout
#include <_Keyboard.au3>

HotKeySet("^{F12}", "ExitScript")
HotKeySet("{INS}", "ToMakeSnapshot")

Opt("SendKeyDelay", 0)
Local $sPath=IniRead('WebPageSave.ini', 'general', 'Path', @DesktopDir)
Local $hWindow, $sFileName, $sWinTitle

Opt("TrayMenuMode", 1 + 2)
Opt("TrayOnEventMode", 1)


TrayCreateItem("Выбор папки сохранения")
TrayItemSetOnEvent(-1, "SaveFolderSelect")

TrayCreateItem("Выбрать окно")
TrayItemSetOnEvent(-1, "SelectWindow")

TrayCreateItem("Сделать снимок")
TrayItemSetOnEvent(-1, "ToMakeSnapshot")

TrayCreateItem("Выход")
TrayItemSetOnEvent(-1, "ExitScript")


TraySetState(1) ; Показывает меню трея

While 1
	Sleep(200) ; бездействующий цикл
WEnd

Func ExitScript()
    Exit
EndFunc

Func SelectWindow()
	While 1
		Sleep(50)
		if _IsPressed("1") Then
			$hWindow = WinGetHandle("[ACTIVE]")
			$sWinTitle=WinGetTitle($hWindow)
			TraySetToolTip($sWinTitle)
			TrayTip("Сохранение снимоков", "Выбрано окно: "&$sWinTitle, 5, 1)
			Return
		EndIf
	WEnd
EndFunc


Func ToMakeSnapshot()
	WinActivate($hWindow)
	If Not WinWaitActive($hWindow, "",2) Then
		MsgBox(16,'Сохранение снимоков', 'Не найдено окно: '&$sWinTitle)
		Return
	EndIf

	Local $clip=ClipGet()
	Send("{F6}")
	Send("{CTRLDOWN}{INS}{CTRLUP}")
	Local $sUrl=ClipGet()
	ClipPut($clip)

	Send("{CTRLDOWN}")
	_SendMinimizedVK($hWindow,"s")
	Send("{CTRLUP}")
;~ 	Send("^s")


	Local $aFiles=_FileDirList($sPath&"\WebPageSnapshots","*", 2); 2 - folders search
	Local $hWnd=WinWaitActive("[TITLE:Сохранение;CLASS:#32770]", "",2)
	If Not $hWnd Then Return
	Sleep(300)

	ControlCommand($hWnd,"","[CLASSNN:ComboBox2]","SelectString", 'Webpage, Single File (*.mhtml)')
	Sleep(300)
	$sFileName=ControlGetText($hWnd, "", "[CLASSNN:Edit1]")
	$sDirPath=$sPath&"\WebPageSnapshots\Snapshot_"&(IsArray($aFiles) ? $aFiles[0] : "")
	DirCreate($sDirPath)

	ControlSend($hWnd, "", "[CLASSNN:Edit1]", $sDirPath&'\'); путь добавляется перед именем файла
;~ 	Send($sDirPath&'\')
	Sleep(300)
	ControlClick($hWnd, "", 1)

	FileWrite($sDirPath&'\url.txt', $sUrl)

	Sleep(500)
	_ScreenCapture_CaptureWnd($sDirPath&'\screenshot.png', $hWindow)

	$sWinTitle=WinGetTitle($hWindow)
	TraySetToolTip($sWinTitle)
	TrayTip("Сохранен снимок", $sWinTitle, 5, 1)
EndFunc

Func SaveFolderSelect()
	$sPath=FileSelectFolder("Выбор папки сохранения снимков веб страниц", IniRead('WebPageSave.ini', 'general', 'Path', @DesktopDir),7)
	ConsoleWrite($sPath & @CRLF)
	If Not $sPath Then $sPath = @DesktopDir
	IniWrite('WebPageSave.ini','general', 'Path', $sPath)
EndFunc
