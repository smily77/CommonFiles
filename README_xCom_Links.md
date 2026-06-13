# Gemeinsame Header (xCom*.h) einbinden

Die gemeinsamen Dateien `xComDef6_x.h` und `xComProc6_x.h` werden **einmal**
im CatFind-Repo gepflegt:

```
CatFind\Controller\Manager6_2_0\xComDef6_2.h , xComProc6_2.h
CatFind\Controller\Manager6_3_0\xComDef6_3.h , xComProc6_3.h
CatFind\Controller\Manager6_4_0\...          (zukuenftig)
```

Damit die Arduino IDE sie als Library findet, müssen sie hier im
`CommonFiles`-Ordner (im Arduino-`libraries`-Verzeichnis) verfügbar sein.

## Warum nicht einfach Symlinks im Repo?

Git speichert Symlinks plattformneutral. Auf Windows werden sie aber **ohne
Entwicklermodus/Adminrechte nur als kleine Text-Stubs** (Typ `.symlink`, 0 KB)
ausgecheckt — die Arduino IDE kann ein `#include <xComDef6_3.h>` darauf nicht
auflösen. Deshalb werden diese Dateien **nicht mehr im Repo versioniert**
(siehe `.gitignore`), sondern lokal mit einem Skript erzeugt.

## Einrichten / Aktualisieren

1. Sicherstellen, dass das **CatFind-Repo** ausgecheckt ist
   (Standard: `%USERPROFILE%\Documents\GitHub\CatFind`).
   Liegt es woanders, in `update_xcom_links.bat` die Variable `SRC` anpassen.
2. `update_xcom_links.bat` ausführen (Doppelklick).
   - Für **echte Symlinks**: Windows-Entwicklermodus einschalten
     (*Einstellungen → Datenschutz und Sicherheit → Für Entwickler →
     Entwicklermodus EIN*) **oder** die Batchdatei „Als Administrator ausführen".
   - Ohne diese Rechte legt das Skript automatisch **harte Links** an
     (funktionieren genauso, solange CatFind und CommonFiles auf demselben
     Laufwerk liegen).
   - Notfalls wird **kopiert** (dann das Skript nach jeder Änderung an den
     Master-Dateien erneut ausführen).

Das Skript findet automatisch **alle** `xCom*.h` — also auch zukünftige
Versionen (6_4, 6_5 …), ohne dass es angepasst werden muss.

## Auf einen Blick

| | |
|---|---|
| Master-Dateien | `CatFind\Controller\Manager6_x_0\xCom*.h` |
| Hier benötigt | `CommonFiles\xCom*.h` (lokal erzeugt, git-ignoriert) |
| Erzeugen mit | `update_xcom_links.bat` |
