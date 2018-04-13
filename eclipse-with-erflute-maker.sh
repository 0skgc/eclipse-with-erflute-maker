#!/bin/bash
ERFLUTE_JAR="org.dbflute.erflute_0.5.7.jar"
ERFLUTE_URL="http://dbflute.seasar.org/download/misc/helper/erflute/$ERFLUTE_JAR"
ECLIPSE_DMG="eclipse-java-oxygen-3a-macosx-cocoa-x86_64.dmg"
ECLIPSE_URL="http://ftp.jaist.ac.jp/pub/eclipse/technology/epp/downloads/release/oxygen/3a/$ECLIPSE_DMG"

CURRENT_DIR="`dirname $0`"
pushd ${CURRENT_DIR}
TARGET=".`basename $0`"
ECLIPSE_APP="Eclipse.app"

# check overwitten
if [ -e $ECLIPSE_APP ]; then
  while true; do
    read -p "The $ECLIPSE_APP already exists. Do you want to overwrite it? [Y/n]" Answer
    case $Answer in
      [Yy]* )
        break;
        ;;
      [Nn]* )
        exit 1
        break;
        ;;
      * )
        echo Please answer YES or NO.
    esac
  done;
fi

# clear
rm -fr $TARGET
mkdir $TARGET

# download and copy
curl -o $TARGET/$ERFLUTE_JAR $ERFLUTE_URL
curl -o $TARGET/$ECLIPSE_DMG $ECLIPSE_URL

# eclipse
hdiutil mount $TARGET/$ECLIPSE_DMG
cp -R /Volumes/Eclipse/$ECLIPSE_APP $TARGET
hdiutil detach /Volumes/Eclipse
rm -f $TARGET/$ECLIPSE_DMG

# erflute
DROPINS_DIR=$TARGET/$ECLIPSE_APP/Contents/Eclipse/dropins/ERFlute/eclipse/plugins/
mkdir -p $DROPINS_DIR
cp $TARGET/$ERFLUTE_JAR $DROPINS_DIR
rm -f $TARGET/$ERFLUTE_JAR

# move app and clear target
rm -fr $ECLIPSE_APP
mv -f $TARGET/$ECLIPSE_APP ./
rm -fr $TARGET
ECLIPSE_HOME=$ECLIPSE_APP

# eclipse.iniのメモリサイズ調整
ECLIPSE_INI=$ECLIPSE_HOME/Contents/Eclipse/eclipse.ini
cp $ECLIPSE_INI $TMPDIR/_eclipse.ini
cat $TMPDIR/_eclipse.ini \
  | sed -e 's/-Xms256m/-Xms512m/g' \
  | sed -e 's/-Xmx1024m/-Xmx2048m/g' \
  > $ECLIPSE_INI

# install Eclipse 2.0 style plugin support
CMD_BASE="$ECLIPSE_HOME/Contents/MacOS/eclipse -nosplash -application org.eclipse.equinox.p2.director"
CMD_BASE="$CMD_BASE -clean"
CMD_BASE="$CMD_BASE -debug"
CMD_BASE="$CMD_BASE -repository http://download.eclipse.org/releases/oxygen"
CMD_BASE="$CMD_BASE -repository http://download.eclipse.org/eclipse/updates/4.7"

CMD="$CMD_BASE -installIU org.eclipse.osgi.compatibility.plugins.feature.feature.group"
$CMD

popd
