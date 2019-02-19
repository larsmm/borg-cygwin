# borg-cygwin

#### This creates a standard Windows installer for Borg Backup on Windows 7 and above.

* The only prerequisite is the presence of NSIS zip, available at [https://sourceforge.net/projects/nsis/files/NSIS%203/3.04/nsis-3.04.zip/download](https://sourceforge.net/projects/nsis/files/NSIS%203/3.04/nsis-3.04.zip/download)
* About 1 GB free disk space required to build installer
* Borg install itself will only require about 165 MB

---

#### What doesn't work:

* `borg mount` command :  it use FUSE wich is not available on Windows.
* ssh repo like `borg init user@host:repo`; you need to mount the repo as networkdrive first with [WinFsp](http://www.secfs.net/winfsp/) for exemple


---

Create the installer by running build32.bat on 32bit Windows or build64.bat on 64bit Windows. After creating the installer, run it to install Borg.

File paths are in Cygwin notation e.g. /c/path/to/my/files

Exemple batch script to do backup:

```
@echo off

REM Mount smb backup folder to W:
net use W: \\192.168.0.252\backup PASSWORD /USER:SOMEUSER /PERSISTENT:NO

set BORG_PASSPHRASE=MYBORGPASSWORD

REM ----------------------------------------
REM Use only first time
REM borg init --encryption=repokey-blake2 /w/Borg
REM ----------------------------------------

set T=%TIME: =0%
set backdir=%date:~6,4%-%date:~3,2%-%date:~0,2%-%T:~0,2%%T:~3,2%%T:~6,2%

call borg create --list -s -p -e '*/Thumbs.db' -e '*/Desktop.ini' -e '*/cache*' /w/Borg::%backdir% /c/Data /c/Users/me

call borg prune --list --show-rc --keep-daily 7 --keep-weekly 4 --keep-monthly 6 /w/Borg

net use W: /DELETE
```

The install script first builds borg inside temporary CygWin subfolder, then installs a much smaller release version into the Borg-installer subfolder. Built packages are copied over, unnecessary files removed, and then NSIS is run.

Tested with CygWin 2.11.2, borgbackup 1.1.9 on Windows 7 & 10, 32-bit & 64-bit.
