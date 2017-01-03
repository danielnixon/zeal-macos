#!/usr/bin/env bash
#
# Build Zeal for macOS.
# Based on https://github.com/Stratus3D/dotfiles/blob/master/scripts/setup/install/zeal.sh
#

# Unofficial Bash "strict mode"
# http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail
IFS=$'\t\n' # Stricter IFS settings

# Version to build.
ZEAL_VERSION=0.3.1

# Deps
# brew install qt5 libarchive

# Download Zeal.
git clone https://github.com/zealdocs/zeal.git
cd zeal || exit
git checkout v${ZEAL_VERSION}

# Configure
# Add this to the pri file:
# Note that the versions in the paths must be correct.
cat << EOF >> src/libs/core/core.pri
macx: {
    INCLUDEPATH += /usr/local/Cellar/libarchive/3.2.2/include
    LIBS += -L/usr/local/Cellar/libarchive/3.2.2/lib -larchive
    INCLUDEPATH += /usr/local/Cellar/sqlite/3.15.2/include
    LIBS += -L/usr/local/Cellar/sqlite/3.15.2/lib -lsqlite3

}
EOF

# Zip the modified source.
rm -rf .git
cd .. || exit
tar -cvzf zeal-$ZEAL_VERSION-macos-src.tgz ./zeal

# Build
# Not sure if INCLUDEPATH and LIBS really need to be set
cd zeal || exit
/usr/local/opt/qt5/bin/qmake -makefile INCLUDEPATH+=/usr/local/opt/libarchive/include "LIBS+=-L/usr/local/opt/libarchive/lib -larchive"
make

cd .. || exit

# Create DMG image.
ln -s /Applications ./zeal/bin/Applications
cp ./zeal/COPYING ./zeal/bin/COPYING
cp ./zeal/README.md ./zeal/bin/README.md

mv ./zeal/bin ./zeal/Zeal
hdiutil create -srcfolder ./zeal/Zeal zeal-$ZEAL_VERSION-macos.dmg

# Clean up.
rm -rf ./zeal