@echo off
REM ===========================================================================
REM  update_xcom_links.bat
REM
REM  Erzeugt in DIESEM Verzeichnis (CommonFiles) fuer jede gemeinsame
REM  Header-Datei xCom*.h aus dem CatFind-Repo eine echte Windows-Verknuepfung,
REM  damit die Arduino IDE sie als Library-Include findet.
REM
REM  Hintergrund:
REM    Git legt Symlinks auf Windows ohne Entwicklermodus/Adminrechte nur als
REM    kleine Text-Stubs (Typ ".symlink") an, die Arduino NICHT als #include
REM    aufloesen kann. Diese Batchdatei ersetzt das durch funktionierende
REM    Verknuepfungen.
REM
REM  Zukunftssicher:
REM    Es werden ALLE Dateien gefunden, die auf xCom*.h passen - also auch
REM    spaetere Versionen wie xComDef6_4.h / xComProc6_4.h usw., ohne dass die
REM    Batchdatei angepasst werden muss.
REM
REM  Verknuepfungsart (in dieser Reihenfolge, erste die klappt gewinnt):
REM    1. [SYMLINK]  mklink      - braucht Adminrechte ODER Windows-
REM                                Entwicklermodus (Einstellungen > Fuer
REM                                Entwickler > Entwicklermodus EIN)
REM    2. [HARDLINK] mklink /H   - ohne Adminrechte, nur gleiches Laufwerk
REM                                (CatFind und CommonFiles muessen auf C: liegen)
REM    3. [KOPIE]    copy        - Notfall-Fallback, immer moeglich
REM                                ACHTUNG: Kopie aktualisiert sich nicht
REM                                automatisch - Batch nach Aenderungen erneut
REM                                ausfuehren.
REM
REM  Aufruf:
REM    Doppelklick, oder in der Eingabeaufforderung in diesem Ordner ausfuehren.
REM    Fuer [SYMLINK] ggf. "Als Administrator ausfuehren".
REM ===========================================================================
setlocal enabledelayedexpansion

REM --- Zielverzeichnis = Ordner dieser Batchdatei (CommonFiles) ---
set "DEST=%~dp0"
if "%DEST:~-1%"=="\" set "DEST=%DEST:~0,-1%"

REM ---------------------------------------------------------------------------
REM  Quelle: Verzeichnis, unter dem die Master-Dateien xCom*.h liegen.
REM  Standard: CatFind-Repo im Standard-GitHub-Ordner. BEI BEDARF ANPASSEN.
REM ---------------------------------------------------------------------------
set "SRC=%USERPROFILE%\Documents\GitHub\CatFind\Controller"

if not exist "%SRC%" (
  echo.
  echo [FEHLER] Quellverzeichnis nicht gefunden:
  echo          %SRC%
  echo.
  echo Bitte oben in dieser Batchdatei die Variable SRC auf den Pfad des
  echo CatFind-Repos anpassen ^(Ordner, der die Manager6_x_0-Verzeichnisse enthaelt^).
  echo.
  pause
  exit /b 1
)

echo.
echo  Quelle : %SRC%
echo  Ziel   : %DEST%
echo  ---------------------------------------------------------------
set /a COUNT=0

for /r "%SRC%" %%F in (xCom*.h) do (
  call :linkone "%%~fF" "%%~nxF"
)

echo  ---------------------------------------------------------------
echo  Fertig: !COUNT! Datei^(en^) verknuepft.
echo.
pause
exit /b 0

REM ===========================================================================
:linkone
REM  %1 = voller Quellpfad, %2 = Dateiname
set "FULL=%~1"
set "NAME=%~2"
set "TARGET=%DEST%\%NAME%"

REM vorhandene (kaputte) Datei / Verknuepfung entfernen
if exist "%TARGET%" del /f /q "%TARGET%" >nul 2>&1

REM 1) Symbolischer Link
mklink "%TARGET%" "%FULL%" >nul 2>&1
if not errorlevel 1 (
  echo   [SYMLINK]  %NAME%
  set /a COUNT+=1
  exit /b 0
)

REM 2) Harter Link
mklink /H "%TARGET%" "%FULL%" >nul 2>&1
if not errorlevel 1 (
  echo   [HARDLINK] %NAME%
  set /a COUNT+=1
  exit /b 0
)

REM 3) Kopie
copy /y "%FULL%" "%TARGET%" >nul 2>&1
if not errorlevel 1 (
  echo   [KOPIE]    %NAME%
  set /a COUNT+=1
  exit /b 0
)

echo   [FEHLER]   %NAME% konnte nicht verknuepft werden
exit /b 1
