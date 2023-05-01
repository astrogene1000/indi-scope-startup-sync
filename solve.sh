#!/bin/bash

INDISCOPE="Telescope Simulator"
INDICAM="CCD Simulator"
SOLVED_PATH="/media/c1/solved"

set -x
##################################
#ESN echo "GOTO" $1 $2
NEWRA=`./sidtime_p3_w_offA $1 $4`
indi_setprop "$INDISCOPE.ON_COORD_SET.TRACK=On"
sleep 1
indi_setprop "$INDISCOPE.EQUATORIAL_EOD_COORD.RA;DEC=$NEWRA;$2"
#ESN echo "Waiting for GOTO to complete"

x=1
while [ $x -le 50 ]
do
  TRA=`indi_getprop -1 "$INDISCOPE.TARGET_EOD_COORD.RA"`
  TDEC=`indi_getprop -1 "$INDISCOPE.TARGET_EOD_COORD.DEC"`
  CRA=`indi_getprop -1 "$INDISCOPE.EQUATORIAL_EOD_COORD.RA"`
  CDEC=`indi_getprop -1 "$INDISCOPE.EQUATORIAL_EOD_COORD.DEC"`
  CRA2=`bc -l <<< "$CRA * 100"`
  CRA1=`bc -l <<< "scale=2;$CRA2 / 1"`
  CDEC2=`echo "$CDEC * 100" | bc -l`
  CDEC1=`echo "scale=2;$CDEC2 / 1" | bc -l`
  TRA2=`echo "$TRA * 100" | bc -l`
  TRA1=`echo "scale=2;$TRA2 / 1" | bc -l`
  TDEC2=`echo "$TDEC*100" | bc -l`
  TDEC1=`echo "scale=2;$TDEC2 / 1" | bc -l`
  DRA=`echo "scale=2;($TRA1 - $CRA1) / 1" | bc -l`
  DDEC=`echo "scale=2;$TDEC1 - $CDEC1" | bc -l`
#  echo "RA=" $CRA "DEC=" $CDEC "CRA=" $CRA1 "CDEC=" $CDEC1
#  echo "TRA=" $TRA "TDEC=" $TDEC "TCRA=" $TRA1 "TCDEC=" $TDEC1
#   echo "DRA=" $DRA " DDEC=" $DDEC
   ADRA=${DRA#-}
   ADEC=${DDEC#-}
#   echo "ADRA = " $ADRA "ADEC = " $ADEC
   ABC=`echo "$ADRA < .4 && $ADEC < .4" | bc -l`
   #ESN echo "ADRA = " $ADRA "ADEC = " $ADEC
#   echo "ABC = " $ABC
   if [ $ABC = "1" ]; then
    #ESN echo "Got There"
    x=51
   fi
  x=$(( $x + 1 ))
  sleep 1
done
x=1
while [ $x -le 15 ]
do
  TRA=`indi_getprop -1 "$INDISCOPE.TARGET_EOD_COORD.RA"`
  TDEC=`indi_getprop -1 "$INDISCOPE.TARGET_EOD_COORD.DEC"`
  CRA=`indi_getprop -1 "$INDISCOPE.EQUATORIAL_EOD_COORD.RA"`
  CDEC=`indi_getprop -1 "$INDISCOPE.EQUATORIAL_EOD_COORD.DEC"`
  CRA2=`bc -l <<< "$CRA * 100"`
  CRA1=`bc -l <<< "scale=2;$CRA2 / 1"`
  CDEC2=`echo "$CDEC * 100" | bc -l`
  CDEC1=`echo "scale=2;$CDEC2 / 1" | bc -l`
  TRA2=`echo "$TRA * 100" | bc -l`
  TRA1=`echo "scale=4;$TRA2 / 1" | bc -l`
  TDEC2=`echo "$TDEC*100" | bc -l`
  TDEC1=`echo "scale=2;$TDEC2 / 1" | bc -l`
  DRA=`echo "scale=4;$TRA1 - $CRA1" | bc -l`
  DDEC=`echo "scale=4;$TDEC1 - $CDEC1" | bc -l`
#  echo "RA=" $CRA "DEC=" $CDEC "CRA=" $CRA1 "CDEC=" $CDEC1
#  echo "TRA=" $TRA "TDEC=" $TDEC "TCRA=" $TRA1 "TCDEC=" $TDEC1
   #ESN echo "DRA=" $DRA " DDEC=" $DDEC
  x=$(( $x + 1 ))
  sleep 1
done

#================================
# set -x

if test -f "/tmp/IMAGE_001.fits"; then
#    echo "/tmp/IMAGE_001.fits exists."
    rm /tmp/IMAGE_001.fits
fi

if test -f "/tmp/result.fits"; then
#    echo "$FILE exists."
    rm /tmp/result.fits
fi

icount=1
while [ $icount -le 4 ]
do

    #ESN echo "Taking image set count = $icount"
    #`indi_setprop "INDICAM.UPLOAD_MODE.UPLOAD_LOCAL=On"`
    `indi_setprop "$INDICAM.CCD_EXPOSURE.CCD_EXPOSURE_VALUE=$3"`
    sleep $(( $3 + 3 ))
    ################################
    #ESN echo "Solving image, dark= " $4
    if test -f $4; then
      /home/pi/tindi/imagearithmatic /tmp/IMAGE_001.fits $4 sub /tmp/result.fits
    else
      cp /tmp/IMAGE_001.fits /tmp/result.fits
    fi
    # RA,Dec = (34.4599,85.8547), pixel scale 3.59807 arcsec/pix.

    MYRA1=`echo "scale=6;$NEWRA*15.0" | bc`
    #ESN echo "Solving around RA=" $1 $MYRA1 " DEC=" $2
    S1="-d 1-30 --ra $MYRA1 --dec $2 --radius 20.0 --scale-low 3.0 --scale-high 4.0 --scale-units arcsecperpix"
#    echo $S1

  #  SOLVE=`solve-field --overwrite  --downsample 2 --no-plots --use-sextractor $S1 /tmp/result.fits 2>&1 | fgrep "pixel scale"`

    SOLVE=`solve-field --overwrite  --downsample 2 --no-plots --use-sextractor /tmp/result.fits 2>&1 | fgrep "pixel scale"`
    ## echo ${#SOLVE}

    # RA,Dec = (34.4599,85.8547), pixel scale 3.59807 arcsec/pix.
    S1=(${SOLVE//\(/ })
    S2=(${S1[2]//\,/ })
    MYRA=${S2[0]}
    S3=(${S2[1]//\)/ })
    MYDEC=${S3[0]}
    ## echo "MYRA = " $MYRA
    ## echo "MY DEC=" $MYDEC
    MYSET=$MYRA\;$MYDEC
    ## echo Lenght = ${#MYSET}
    MYSET1=${#MYSET}
    ## echo Lenght1 = $MYSET1
    if [ $MYSET1 -gt 3 ]; then
      icount=$MYSET1
    else
      #ESN echo "Failed solve set  count =  $icount"
      icount=$(( $icount + 1 ))
      rm /tmp/IMAGE_001.fits /tmp/result.fits
      sleep 5
    fi
done

if [ $MYSET1 -gt 3 ]; then

  MYRA1=`echo "scale=6;$MYRA/15.0" | bc`
  MYSET=$MYRA1\;$MYDEC

  JNOW=`python3 ./tjnow.py $MYRA $MYDEC 2>/dev/null`
#  echo "Python=<"$JNOW">"
  JNOW1=(${JNOW//\,/ })
  JNOWRA=${JNOW1[0]}
  JNOWDEC=${JNOW1[1]}
  JNOWRA1=`echo "scale=6;$JNOWRA/15.0" | bc`
  MYSET2=$JNOWRA1\;$JNOWDEC
  #ESN echo "First Image solved at " $SOLVE
##  echo YES
  mv /tmp/result.fits "$SOLVED_PATH/result-J2K:$MYRA1;$MYDEC-JNOW:$JNOWRA1;$JNOWDEC-`date "+%H.%M.%S-%m.%d.%Y"`.fit"
  #ESN echo "Syncing scope"
  indi_setprop "$INDISCOPE.ON_COORD_SET.SYNC=On"
  indi_setprop "$INDISCOPE.EQUATORIAL_EOD_COORD.RA;DEC=$MYSET2"
  sleep 1
  indi_setprop "$INDISCOPE.ON_COORD_SET.TRACK=On"
  indi_setprop "$INDISCOPE.TELESCOPE_TRACK_STATE.TRACK_ON=On"
  sleep 1
fi

echo $MYSET1
