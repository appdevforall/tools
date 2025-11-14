#!/bin/bash

## Define some constants for scalability
SUCCESS="Success"
ADB="adb"
COGO="com.itsaky.androidide"
COUNT=(0 0)

## Define the function for installing the apk
## Usage: install <apkname> (aka $1)
## Args: <apkname> file name of the apk to be installed
function install {
    TOD=$(date +'%Y-%m-%d,%H:%M:%S')
    echo "Installatroning $1 on $SERIAL model $MODEL for arch $ARCH"
    result=$($ADB -s $SERIAL install -d -r  $1)
    if [[ "$result" == *"$SUCCESS"* ]]; then
	echo Successfully Installed $1
	devnull=$(adb -s $SERIAL shell cmd notification post -S bigtext -t 'Alert' 'Installatron' "Installed\ new\ version\ of\ $1\ at\ $TOD")
	status=0
	((COUNT[0]++))
    else
	echo "Installation failed - $result", aborting current install
	((COUNT[1]++))
	status=-1
    fi

return $status
}

## Main
echo "Installatron"
for SERIAL in $($ADB devices | tail -n +2 | cut -sf 1);
do
    ## use an ls here so that if the apk is not found, we get an empty list
    ##  as compared to the script crashing
####  for APKLIST in $(ls appRelease.apk);
####  do
      ## get the device's architecture, on v7 and v8 are supported
      ARCH=$($ADB -s $SERIAL shell getprop ro.product.cpu.abi)
      MODEL=$($ADB -s $SERIAL shell getprop ro.product.model)
      PKG=$($ADB -s $SERIAL shell pm list packages | grep -i $COGO)
      echo Turning off WiFi on device
      $ADB -s $SERIAL shell svc wifi disable
      ## if Code On The Go already exists, unistall it
      echo $PKG,,,$COGO
      if [[ "$PKG" == *"$COGO"* ]]; then
	  echo Uninstalling existing version
	  result=$($ADB -s $SERIAL uninstall $COGO)
	  if [[ "$result" == *"$SUCCESS"* ]]; then
	      echo Successfully uninstalled existing version
	  else 
	     echo Failed to uninstall existing version, aborting current install
	     ((COUNT[1]++))
	     continue
	  fi
      fi
      ## install the V8 or the v7 release version of Code On The Go
      if [[ "$ARCH" == arm64-v8a ]]; then
	  install appv8.apk
      elif [[ "$ARCH" == armeabi-v7a ]]; then
	  install appv7.apk
      else
	  echo unknown architecture - $ARCH, aborting current install
	  ((COUNT[1]++))
	  continue
      fi

  done

#### done
echo successfully installed on ${COUNT[0]} devices, falied to install on ${COUNT[1]} devices
echo "Installatron has left the building"
