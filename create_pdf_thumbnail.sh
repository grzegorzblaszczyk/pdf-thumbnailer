#!/bin/bash

# Create PDF Thumbnail v0.3.
# Changelog:
#
# 0.3 - working also on Mac OS X
# 0.2.1 - fix when you do not have an .pdf_thumbnailer.rc file we create one for you with default settings
# 0.2 - added upload feature via SCP and use of ~/.pdf_thumbnailer.rc file
# 0.1 - initial version

# About:
# Fast'n'dirty script by Grzegorz Błaszczyk <grzegorz@blaszczyk-consulting.com>

VERSION="0.3"

AWK=`which awk`
CAT=`which cat`
CUT=`which cut`
GREP=`which grep`
SCP=`which scp`
UNAME=`which uname`
WC=`which wc`
CONVERT=`which convert`
HEIGHT=259

CONFIG_FILE="$HOME/.pdf_thumbnailer.rc"

### DO NOT EDIT BELOW THIS LINE ###

if [ ! -f $CONFIG_FILE ]; then 
  echo "Configuration file not found - creating $CONFIG_FILE..."
  echo "#PDF Thumbnail v$VERSION" > $CONFIG_FILE
  echo "scp_upload_username=$USER" >> $CONFIG_FILE
  echo "scp_upload_hostname=somehost.com" >> $CONFIG_FILE
  echo "scp_upload_directory=/home/$USER" >> $CONFIG_FILE
fi

function read_config_file_property {
  VALUE=`$CAT $CONFIG_FILE | $GREP $1 | $CUT -f 2 -d '='`
  echo $VALUE
}

function print_usage {
  echo "Usage: $0 [PDF filename]"
  exit 1;
}

function get_os_version {
  LSB_RELEASE_FILE="/etc/lsb-release"
  if [ -f $LSB_RELEASE_FILE ]; then
    DISTRO_ID=`$CAT /etc/lsb-release | $GREP "ID" | $CUT -f 2 -d "="`;
    echo $DISTRO_ID;
  else
    UNAME_STRING=`$UNAME`
    if [ "x$UNAME_STRING" == "xDarwin" ]; then
      echo "MacOSX";
    fi
  fi
}

if [ -z $1 ]; then
  print_usage
fi

UPLOAD_USERNAME=`read_config_file_property "scp_upload_username"`
UPLOAD_HOST=`read_config_file_property "scp_upload_hostname"`
UPLOAD_DIR=`read_config_file_property "scp_upload_directory"`

if [ -z $CONVERT ]; then 
  echo ""
  echo "+--------------+"
  echo "|   FAILURE !  |"
  echo "+--------------+"
  echo ""
  echo "Please install ImageMagick package."
  echo ""
  echo "You can install it by running the following command:"

  OS_VERSION=`get_os_version`

  case $OS_VERSION in
    "Ubuntu" )
      echo "sudo apt-get install imagemagick" ;;
    "Fedora" )
      echo "sudo yum install imagemagick" ;;
    "CentOS" )
      echo "sudo yum install imagemagick" ;;
    "MacOSX" )
      echo "brew install ghostscript";
      echo "brew install imagemagick" ;;
    "Unknown" )
      echo "[Your operating system is not known to this script - please install ImageMagick on your own.]"
  esac
  echo ""
  exit 1;
fi

PDF_FILENAME=$1
JPG_FILENAME="${PDF_FILENAME%\.pdf}.jpg"

echo -n "Converting..."
echo $CONVERT : $HEIGHT : $PDF_FILENAME[0] : $JPG_FILENAME
$CONVERT -scale x$HEIGHT $PDF_FILENAME\[0\] $JPG_FILENAME
echo "[done]"

read -p "Do you want to upload the book along with the cover to the server [Y/n]? "
if [ "$REPLY" != "n" ]; then 
  echo "Uploading files ${PDF_FILENAME%\.pdf}.* to $UPLOAD_USERNAME@$UPLOAD_HOST:$UPLOAD_DIR"
  $SCP -v ${PDF_FILENAME%\.pdf}.* $UPLOAD_USERNAME"@"$UPLOAD_HOST":"$UPLOAD_DIR
fi
