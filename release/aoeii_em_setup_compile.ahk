#Requires AutoHotkey v2.0
#SingleInstance Force

RunWait('iscc aoeii_em_setup.iss')
Size := FileGetSize('aoeii_em_setup_latest.exe')
Size /= 1024
Size /= 1024
Size := Round(Size, 2)
FileOpen('aoeii_em_setup_size.txt', 'w').Write(Size)