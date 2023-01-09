' ------------------------------------------
' Inicializacao de variaveis de sistema
Dim fso, wshShell

Set fso = CreateObject("Scripting.FileSystemObject")
Set wshShell = CreateObject("WScript.Shell")
' ------------------------------------------
' Inicializacao de variaveis de usuario
data_raw = fso.BuildPath(wshShell.CurrentDirectory, "\")
old_file = Wscript.Arguments.Item(0)
old_path = fso.BuildPath(data_raw, old_file)

new_file = Wscript.Arguments.Item(1)
' ------------------------------------------
' Inicializacao das variaveis do excel e operações
Dim excel, workbook 

WScript.Echo "Limpeza bancos\SISOR\" & old_file & "..."

Set excel = CreateObject("Excel.Application")
excel.Application.DisplayAlerts = False

Set workbook = excel.Workbooks.Open(fso.GetFile(old_path))

On Error Resume Next
workbook.Worksheets(1).ShowAllData
workbook.Worksheets(1).Cells.ClearFormats
workbook.SaveAs data_raw & new_file, 51
On Error GoTo 0
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
