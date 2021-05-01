#!/bin/sh

# install_name_tool -change old new file

#   ⃝ Kroleg, 2016

me=`basename "$0"`

if [ -z "$1" ]; then
 echo "usage: ./$me [version] [screen] <save>"
# ./build.sh 4.8.15 ncurses save
 exit 1
fi

if [ "$2" == "slang" ]; then
 SCRN="--with-screen=slang"
elif [ "$2" == "ncurses" ]; then
 SCRN="--with-screen=ncurses"
 else
  echo "usage: ./$me [version] [screen] <save>"
 exit 1
fi

MC_VERS=$1
# PATCH=""
# PATCH="3692-mc_subshell"
PATCH1="mc-4.8.26-ncurses"
PATCH2="mc-4.8.26-uzip"
APP="mc-$MC_VERS-x86_64-$2"
#APP="mc-$MC_VERS-x86_64-$2$PATCH"
DEST_DIR="$HOME/DevPkg/mc-dyld/x86_64/$APP"
SRC=$DEST_DIR/opt/kroleg/mc/bin/mc
LIB=$DEST_DIR/opt/kroleg/mc/lib/
EXEC=@executable_path/../lib/
CPL="/opt/local/lib/"

# Colors
BGRED='\033[41m'
BGBLUE='\033[44m'
RED='\033[1;31m'
WHITE='\033[1;37m'
NORMAL='\033[0m'

mkdir -p $HOME/DevPkg/{mc-dyld,dmg}
mkdir -p $LIB

get_dylibs() {
 echo `otool -L $1 | grep -E "/opt.*dylib[^:]" | awk -F' ' '{ print $1 }'`
}


if [ ! -f "mc-$MC_VERS".tar.xz ]; then
 wget http://ftp.midnight-commander.org/"mc-$MC_VERS".tar.xz
# rm -f "mc-$MC_VERS".tar.xz
fi

if [ ! -d "mc-$MC_VERS" ]; then
 tar -xvf "mc-$MC_VERS".tar.xz
fi

# cd "mc-$MC_VERS"

# patches ###########
#cp _patch/patch-src_subshell_common.c "mc-$MC_VERS/src/subshell/"
## cp "_patch/$PATCH.patch" "mc-$MC_VERS"
#
# makepatch: diff -Naur mc-4.8.23.old mc-4.8.23 > mc-4.8.23.patch
# patch for 4.8.23
 cp "_patch/$PATCH1.patch" "mc-$MC_VERS"
 cp "_patch/$PATCH2.patch" "mc-$MC_VERS"
 cd "mc-$MC_VERS"
 patch -p1 < "$PATCH1.patch"
 patch -p1 < "$PATCH2.patch"
# exit #for i-386
#
#
#cd "mc-$MC_VERS/src/subshell"
#patch < patch-src_subshell_common.c
#cd ..
#cd ..
####################

./configure --prefix=/opt/kroleg/mc \
$SCRN \
CPPFLAGS="-I/opt/local/include" \
LDFLAGS="-L/opt/local/lib"

make && make install DESTDIR=$DEST_DIR
cd ..

if [ ! -f "$SRC"  ]; then
 rm -Rf "mc-$MC_VERS"
 echo "$WHITE$APP$RED build error $NORMAL"  
 exit 1
fi

# change dylib path in bynary and copy dylibd

fix_dylib() {

 DYLIBS=$(get_dylibs $1)

 for dylib in $DYLIBS; do

  if [ "$2" == "1" ] && [ -f $CPL`basename $dylib` ]; then
   cp -f $CPL`basename $dylib` $LIB;
   chmod 755 $LIB`basename $dylib`;
   install_name_tool -change $dylib $EXEC`basename $dylib` $1;
  fi
  DYLIBS2=$(get_dylibs $dylib)
 
  for dylib2 in $DYLIBS2; do

   if [ "$2" == "1" ] && [ -f $CPL`basename $dylib2` ]; then
    cp -f $CPL`basename $dylib2` $LIB;
    chmod 755 $LIB`basename $dylib2`;
   install_name_tool -change $dylib2 $EXEC`basename $dylib2` $LIB`basename $dylib`;
   fi
   DYLIBS3=$(get_dylibs $LIB`basename $dylib2`)

   for dylib3 in $DYLIBS3; do
    if [ "$2" == "1" ]; then
     cp -f $CPL`basename $dylib3` $LIB;
    fi;

    chmod 755 $LIB`basename $dylib3`
    install_name_tool -change $dylib3 $EXEC`basename $dylib3` $LIB`basename $dylib2`
##    if [ "$2" == "1" ]; then ln -sf $CPL`basename $dylib3` $LIB; fi;
   done;
  done;
 done;

 for dylib in $LIB*; do
  install_name_tool -id `basename $dylib` $dylib;
 done

}

fix_dylib $SRC 1

# make dmg
source _pkgdmg/makedmg

if [ "$3" != "save" ]; then
 rm -Rf "$APP"
 rm -Rf "mc-$MC_VERS"
fi

# rm -Rf "mc-$MC_VERS"

echo "$BGBLUE$WHITE   $APP buid completed   $NORMAL"

