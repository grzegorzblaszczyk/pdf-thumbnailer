#!/bin/bash

# Fast'n'dirty script by Grzegorz Błaszczyk <grzegorz@blaszczyk-consulting.com>

CAT=`which cat`
CUT=`which cut`
GREP=`which grep`
WC=`which wc`
CONVERT=`which convert`
HEIGHT=259

### DO NOT EDIT BELOW THIS LINE ###

function print_usage {
  echo "Usage: $0 [PDF filename]"
  exit 1;
}

if [ -z $1 ]; then
  print_usage
fi

if [ -z $CONVERT ]; then 
  echo ""
  echo "+--------------+"
  echo "|   FAILURE !  |"
  echo "+--------------+"
  echo ""
  echo "Please install ImageMagick package."
  echo ""

  DISTRO_ID=`$CAT /etc/lsb-release | $GREP "ID" | $CUT -f 2 -d "="`
 
  case $DISTRO_ID in
    "Ubuntu" )
      echo "You can install it by running the following command:"
      echo "sudo apt-get install imagemagick" ;;
    "Fedora" )
      echo "You can install it by running the following command:"
      echo "sudo yum install imagemagick" ;;
    "CentOS" )
      echo "You can install it by running the following command:"
      echo "sudo yum install imagemagick" ;;
  esac
  echo ""
  exit 1;
fi

PDF_FILENAME=$1
JPG_FILENAME="${PDF_FILENAME%\.pdf}.jpg"

echo -n "Converting..."
#echo $CONVERT : $HEIGHT : $PDF_FILENAME\[0\] : $JPG_FILENAME
$CONVERT -scale x$HEIGHT $PDF_FILENAME\[0\] $JPG_FILENAME
echo "[done]"

