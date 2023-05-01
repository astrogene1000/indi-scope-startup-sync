#!/bin/bash

# Usage RA1 DEC1 RA2 DEC2 RA3 DEC3 ExpTime  Longitude Dark

# Set indi scope and camera
INDISCOPE="Telescope Simulator"
INDICAM="CCD Simulator"

#################################
set -x
echo "Connecting"
CON=`indi_getprop -1  "$INDISCOPE.CONNECTION.CONNECT"`
if [ $CON = "Off" ]; then
  indi_setprop "$INDISCOPE.CONNECTION.CONNECT=On"
  sleep 5
  echo "Loading Config"
    indi_setprop "$INDISCOPE.CONFIG_PROCESS.CONFIG_LOAD=On"
    sleep 2
  echo "Setting TIME"
  DATE1=`date -u --iso-8601=ns`
  echo DATE1=$DATE1
  DATE2=(${DATE1//\,/ })
  DATE=${DATE2[0]}
  DATE="$DATE;-5"
  echo Setting Date=$DATE
  echo `indi_setprop "$INDISCOPE.TIME_UTC.UTC;OFFSET=$DATE"`
  sleep 1
  echo `indi_setprop "$INDISCOPE.ALIGNMENT_SUBSYSTEM_MATH_PLUGINS.SVD Math Plugin=On"`
  sleep 2
  echo `indi_setprop "$INDISCOPE.POLLING_PERIOD.PERIOD_MS=250"`
  sleep 2
  echo `indi_setprop "$INDISCOPE.POLLING_PERIOD.PERIOD_MS=250"`
else
  echo `indi_setprop "$INDISCOPE.POLLING_PERIOD.PERIOD_MS=250"`
  sleep 2
fi

echo "Opening camera"
CON=`indi_getprop -1  "$INDICAM.CONNECTION.CONNECT"`
if [ $CON = "Off" ]; then
  `indi_setprop "$INDICAM.CONNECTION.CONNECT=On"`
fi

  `indi_setprop "$INDICAM.UPLOAD_SETTINGS.UPLOAD_DIR=/tmp"`
  `indi_setprop "$INDICAM.UPLOAD_SETTINGS.UPLOAD_PREFIX=IMAGE_001"
  `indi_setprop "$INDICAM.CCD_GAIN.GAIN=12"
  `indi_setprop "$INDICAM.UPLOAD_MODE.UPLOAD_LOCAL=On"`

SET1=`./solve.sh $1 $2 $7 $8`
#SET1=1
if [ $SET1 -gt 3 ]; then
  SET2=`./solve.sh $3 $4 $7 $8 $9`
  if [ $SET2 -gt 3 ]; then
    SET3=`./solve.sh $5 $6 $7 $8 $9`
    if [ $SET3 -gt 3 ]; then
      echo "completed succesfully!"
    else
      echo "Failed SET3"
    fi
  else
      echo "Failed SET2"
  fi
else
  echo "Failed SET1"
fi
