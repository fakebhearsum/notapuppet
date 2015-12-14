@echo off

SET MOZBUILDDIR=C:\mozilla-build
SET MOZILLABUILD=%MOZBUILDDIR%
echo "MozillaBuild directory: %MOZBUILDDIR%"

REM set BUILDBOT_PATH
Set BUILDBOT_PATH=C:\mozilla-build\buildbotve

set log="c:\runner\buildbot-startup.log"

REM Use the "new" moztools-static
set MOZ_TOOLS=%MOZBUILDDIR%\moztools-x64

REM append moztools to PATH
SET PATH=%PATH%;%MOZ_TOOLS%\bin

SET IDLEIZER_HALT_ON_IDLE=true

cd "%USERPROFILE%"

:start
echo "%date% %time% - About to run runslave.py"

REM running this via 'bash' is critical - bash adds a bunch of items to PATH
REM which the build steps expect to find.  We pass the --twistd-cmd pointing
REM to the appropriate twistd executable for the active Buildbot version
"%MOZILLABUILD%\msys\bin\bash" --login -c "'%BUILDBOT_PATH%\Scripts\python' /c/programdata/puppetagain/runslave.py --twistd-cmd '%BUILDBOT_PATH%\Scripts\twistd.py'"

echo "%date% %time% - runner.py finished"
