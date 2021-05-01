#!/bin/bash

 vers=$(sw_vers -productVersion)
 OSV=$(echo $vers | sed -e 's/\([0-9]*\)\.\([0-9]*\)\(\.[0-9]*\)*/\1/')
 OSv=$(echo $vers | sed -e 's/\([0-9]*\)\.\([0-9]*\)\(\.[0-9]*\)*/\2/')

 if [ "$OSV" -ge 11 ] || [ "$OSv" -ge 15 ]; then
   profile="zprofile"
   bash_profile="zshenv"
  else
   profile="profile"
   bash_profile="bash_profile"
 fi

 PROFILE="$HOME/.$profile"
 BASH_PROFILE="$HOME/.$bash_profile"
 EXPORT_PATH='export PATH=$PATH:/opt/kroleg/mc/bin'
 EXPORT_TERMINFO='export TERMINFO=/usr/share/terminfo'

 function removePath() {
  while read -r line
  do
   [[ ! "$line" =~ "$2" ]] && echo "$line"
  done <$1 > o
  mv o $1
  sudo chown $USER $1
 }
 
 removePath $PROFILE "$EXPORT_PATH"
 removePath $BASH_PROFILE "$EXPORT_PATH"
 
 removePath $PROFILE "$EXPORT_TERMINFO"
 removePath $BASH_PROFILE "$EXPORT_TERMINFO"

 IDF=org.kroleg.mc

 if ! [ -f /var/db/receipts/$IDF.bom ]; then
  BOM_DIR=/Library/Receipts/boms
 else
  BOM_DIR=/var/db/receipts
 fi

 lsbom -fls $BOM_DIR/$IDF.bom | (cd /; sudo xargs rm)
 lsbom -dls $BOM_DIR/$IDF.bom | (cd /; sudo xargs rmdir -p)

 cd $BOM_DIR
 rm -f $IDF.bom $IDF.plist
 rm -f $IDF.xd.bom $IDF.xd.plist
 rm -f $IDF.xm.bom $IDF.xm.plist
 rm -f $IDF.tp.bom $IDF.tp.plist
 rm -f $IDF.keymap.bom $IDF.keymap.plist
 rm -f $IDF.ini.bom $IDF.ini.plist
 rm -f $IDF.menu.bom $IDF.menu.plist
 rm -f $IDF.ext.bom $IDF.ext.plist

 rm -f $HOME/.Xdefaults $HOME/.Xmodmap
