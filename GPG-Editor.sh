#!/bin/sh


EDITOR=/usr/bin/vim
GPG_KEY=E0228A97
GPG_OPTIONS="--armor"




FILE=$1

if [ -z "$FILE" ] ; then
  echo "Usage: gpg-write.sh <file>" >&2
  exit 1
fi


if [ ! -r "$FILE" ] ; then
  echo "File '$FILE' does not exist or is not readable" >&2
  exit 1
fi

if [ -z "$GPG_KEY" ] ; then
  echo "You must edit the script to add your GPG key id !"
  exit 1
fi

if [ ! -x $EDITOR ] ; then
  echo "Your editor '$EDITOR' does not exist" >&2
  exit 1
fi


GPG_BIN=`which gpg`
if [ 0 -ne $? ] ; then
  echo "GPG command not found in your path"
  exit 1
fi


gpg --list-secret-keys "$GPG_KEY" >/dev/null 2>&1
if [ 0 -ne $? ] ; then
  echo "Key '$GPG_KEY' does not exist in your private keyring" >&2
  exit 1
fi

random_filename () {
  r=""
  r=`head -c 10 < /dev/random | uuencode -m - | tail -n 2 | head -n 1 | cut -c 1-8`
  r=`echo $r | tr -cd "[:alnum:]"`
  r="/tmp/$r"

  if [ -e "$r" ] ; then
    random_filename
  fi
  
  echo $r
}

TMP_FILE=`random_filename`
touch "$TMP_FILE"
chmod 600 "$TMP_FILE"


$GPG_BIN --decrypt $FILE > "$TMP_FILE"

if [ 0 -ne $? ] ; then
  rm "$TMP_FILE"
  exit 1
fi

$EDITOR "$TMP_FILE" && \
  $GPG_BIN --sign --encrypt "$GPG_OPTIONS" -r "$GPG_KEY" -o "$FILE" "$TMP_FILE"

  
rm "$TMP_FILE"

exit 0
