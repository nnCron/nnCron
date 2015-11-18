; example1.nsi
;
; This script is perhaps one of the simplest NSIs you can make. All of the
; optional settings are left to their default settings. The instalelr simply 
; prompts the user asking them where to install, and drops of notepad.exe
; there. If your Windows directory is not C:\windows, change it below.
;

; The name of the installer
;Name "nnCron"

; The file to write
OutFile "nncron11.exe"

XPStyle on

#BGGradient 000000 308030 FFFFFF
InstallColors FF8080 000000
InstProgressFlags smooth colored

LicenseText "You must read the following license before installing:"
LicenseData Image\data\txt\license.txt 

; The default installation directory
InstallDir $PROGRAMFILES\nncron

InstallDirRegKey HKLM "software\nnSoft\nnCron" "path"

; The text to prompt the user to enter a directory
DirText "Choose a directory"


; First is default
;LoadLanguageFile "${NSISDIR}\Contrib\Language files\English.nlf"
;Name English
;LoadLanguageFile "${NSISDIR}\Contrib\Language files\Russian.nlf"
;Name Russian
;LoadLanguageFile "${NSISDIR}\Contrib\Language files\German.nlf"
;Name German
;LoadLanguageFile "${NSISDIR}\Contrib\Language files\Spanish.nlf"
;Name Spanish


; The stuff to install
Section install_nncron
  ReadEnvStr $1 VER
  ; Set output path to the installation directory.
  SetOutPath $INSTDIR
  ; Put file there
  File /r "image\data\*.*"
  WriteRegStr HKLM "software\nnSoft\nnCron" "path" $INSTDIR
SectionEnd ; end the section

Section -post
  SetOutPath $INSTDIR
  Delete $INSTDIR\uninst.exe 
  WriteUninstaller $INSTDIR\uninst.exe
SectionEnd


Section Uninstall
  Delete $INSTDIR\uninst.exe 

  ; if $INSTDIR was removed, skip these next ones
  IfFileExists $INSTDIR 0 Removed 
    MessageBox MB_YESNO|MB_ICONQUESTION \
      "Remove all files in your nnCron directory? (If you have anything \
you created that you want to keep, click No)" IDNO Removed
    Delete $INSTDIR\*.* ; this would be skipped if the user hits no
    RMDir /r $INSTDIR
    IfFileExists $INSTDIR 0 Removed 
      MessageBox MB_OK|MB_ICONEXCLAMATION \
                 "Note: $INSTDIR could not be removed."
  Removed:
SectionEnd

Function .onInit
;    Push ${LANG_ENGLISH}
;    Push English
;    Push ${LANG_GERMAN}
;    Push German
;    Push ${LANG_RUSSIAN}
;    Push Russian
;    Push ${LANG_SPANISH}
;    Push Spanish
;    Push 4 ; 7 is the number of languages
;    LangDLL::LangDialog "Installer Language" "Please select the language of the installer"
;
;    Pop $LANGUAGE
    StrCmp $LANGUAGE "cancel" 0 +2
        Abort
FunctionEnd
