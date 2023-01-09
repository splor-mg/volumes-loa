' ------------------------------------------
' Inicializacao de variaveis de sistema
Dim fso, wshShell

Set fso = CreateObject("Scripting.FileSystemObject")
Set wshShell = CreateObject("WScript.Shell")
' ------------------------------------------
' Inicializacao de variaveis de usuario
old_drive = fso.BuildPath(wshShell.CurrentDirectory, "\")
old_path = fso.BuildPath(old_drive, Wscript.Arguments.Item(0))
new_path = fso.BuildPath(old_drive, Wscript.Arguments.Item(1))

' ------------------------------------------
' Inicializacao das variaveis do excel e operações
Dim excel, workbook 

WScript.Echo " ------------------------------------------"
WScript.Echo "Transferindo " & old_path
WScript.Echo " para "
WScript.Echo new_path
WScript.Echo " ------------------------------------------"

Set excel = CreateObject("Excel.Application")
excel.Application.DisplayAlerts = False

Set workbook = excel.Workbooks.Open(fso.GetFile(old_path))
workbook.Worksheets(1).Cells.ClearFormats
workbook.SaveAs new_path, 51
workbook.Close

excel.Application.DisplayAlerts = True
excel.Application.Quit 
' ------------------------------------------
' Finalização
Set fso = Nothing
Set workbook = Nothing    
Set excel = Nothing
Set wshShell = Nothing

wScript.Quit

