# borg-cygwin

#### This creates a standard Windows installer for Borg Backup on Windows 7 and above.

* The only prerequisite is the presence of NSIS zip, available at [https://sourceforge.net/projects/nsis/files/NSIS%203/3.03/nsis-3.03.zip/download](https://sourceforge.net/projects/nsis/files/NSIS%203/3.03/nsis-3.03.zip/download)
* About 1 GB free disk space required to build installer
* Borg install itself will only require about 165 MB

---

#### What doesn't work:

* `borg mount` command :  it use FUSE wich is not available on Windows.
* ssh repo like `borg init user@host:repo`; you need to mount the repo as networkdrive first with [WinFsp](http://www.secfs.net/winfsp/) for exemple


---

Create the installer by running build32.bat on 32bit Windows or build64.bat on 64bit Windows. After creating the installer, run it to install Borg.

Then use borg like this, noting that all file paths are in Cygwin notation e.g. /c/path/to/my/files

```
borg init /d/Borg
borg create -C lz4 /d/Borg::Test /c/Photos/
```

The install script first builds borg inside temporary CygWin subfolder, then installs a much smaller release version into the Borg-installer subfolder. Built packages are copied over, unnecessary files removed, and then NSIS is run.

Tested with CygWin 2.10.0, borgbackup 1.1.7 on Windows 7 32-bit & 64-bit.
