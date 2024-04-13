#!/bin/bash

SCRIPT_NAME=$(echo \"$0\" | xargs readlink -f)
SCRIPTDIR=$(dirname "$SCRIPT_NAME")

exec 6>display.log
/usr/bin/Xvfb -displayfd 6 &
XVFB_PID=$!
while [[ ! -s display.log ]]; do
  sleep 1
done
read -r DPY_NUM < display.log
rm display.log

export WINEPREFIX="$SCRIPTDIR/space-engineers-generic/.wine"
export WINEDLLOVERRIDES="mscoree,mshtml="
export WINEARCH=win64
export WINEDEBUG=fixme-all
export DISPLAY=:$DPY_NUM

wget -q -N https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks
chmod +x winetricks
wget -q -O $WINEPREFIX/mono.msi https://dl.winehq.org/wine/wine-mono/9.0.0/wine-mono-9.0.0-x86.msi

./winetricks -q win11 > winescript_log.txt 2>&1
./winetricks -q vcrun2022 >> winescript_log.txt 2>&1
/usr/bin/wine msiexec /i $WINEPREFIX/mono.msi /qn /quiet /norestart /log $WINEPREFIX/mono_install.log
./winetricks -q corefonts >> winescript_log.txt 2>&1
./winetricks -q sound=disabled >> winescript_log.txt 2>&1
rm -rf ~/.cache/winetricks ~/.cache/fontconfig

exec 6>&-
kill $XVFB_PID

exit 0
