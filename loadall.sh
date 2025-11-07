#!/bin/bash

## Define some constants for scalability
SUCCESS="Success"
ADB="adb"
COGO="com.itsaky.androidide"
COUNT=(0 0)
TOD=$(date +'%Y-%m-%d,%H:%M:%S')

echo "Installatron"
for SERIAL in $($ADB devices | tail -n +2 | cut -sf 1);
do
    ## use an ls here so that if the apk is not found, we get an empty list
    ##  as compared to the script crashing
  for APKLIST in $(ls appRelease.apk);
  do
      ## get the device's architecture, on v7 and v8 are supported
      ARCH=$($ADB -s $SERIAL shell getprop ro.product.cpu.abi)
      MODEL=$($ADB -s $SERIAL shell getprop ro.product.model)
      PKG=$($ADB -s $SERIAL shell pm list packages | grep -i $COGO)
      echo Turning off WiFi on device
      $ADB -s $SERIAL shell svc wifi disable
      echo "Installatroning $APKLIST on $SERIAL model $MODEL for arch $ARCH"
      ## if Code On The Go already exists, unistall it
      if [[ "$PKG" == "package$COGO" ]]; then
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
	  result=$($ADB -s $SERIAL install -d -r  $APKLIST)
	  if [[ "$result" == *"$SUCCESS"* ]]; then
	      echo Successfully Installed $APKLIST
	      adb -s $SERIAL shell cmd notification post -S bigtext -t 'Alert' 'Installatron' "Installed\ new\ version\ of\ $APKLIST\ on\ $TOD"
	      ((COUNT[0]++))
	  else
	      echo "Installation failed - $result", aborting current install
	      ((COUNT[1]++))
	      continue
	  fi
      else 
	  echo unknown architecture - $ARCH, aborting current install
	      ((COUNT[1]++))
	  continue
      fi

  done

done
echo successfully installed on ${COUNT[0]} devices, falied to install on ${COUNT[1]} devices
echo "Installatron has left the building"
