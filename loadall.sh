#!/bin/bash

SUCCESS="Success"

echo "Installatron"
for SERIAL in $(adb devices | tail -n +2 | cut -sf 1);
do 
  for APKLIST in $(ls appRelease.apk);
  do
      ARCH=$(adb -s $SERIAL shell getprop ro.product.cpu.abi)
      MODEL=$(adb -s $SERIAL shell getprop ro.product.model)
      PKG=$(adb shell pm list packages | grep -i com.itsaky.androidide)
      echo Turning off WiFi on device
      adb -s $SERIAL shell svc wifi disable
      echo "Installatroning $APKLIST on $SERIAL model $MODEL for arch $ARCH"
      if [[ "$PKG" == "package:com.itsaky.androidide" ]]; then
	  echo Uninstalling existing version
	  result=$(adb -s $SERIAL uninstall com.itsaky.androidide)
	  if [[ "$result" == *"$SUCCESS"* ]]; then
	     echo Successfully uninstalled existing version
	  else
	     echo Failed to uninstall existing version, aborting current install
	     continue
	  fi
      fi
      
      if [[ "$ARCH" == arm64-v8a ]]; then
	  result=$(adb -s $SERIAL install -d -r  $APKLIST)
	  if [[ "$result" == *"$SUCCESS"* ]]; then
	      echo Successfully Installed $APKLIST
	  else
	      echo "Installation failed - $result"
	  fi
      else 
	  echo unknown architecture - $ARCH
      fi

  done

done

echo "Installatron has left the building"
