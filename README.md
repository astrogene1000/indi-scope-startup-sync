# indi-scope-startup-sync
INDILIB scripted scope startup goto/solve/sync x3



This is a repository for the indilib subsystem that will do three seperate blind goto's,
capture and solve at each position using astrometry, sync the mount at each position using J2000 coordinates
from astrometry precessed to JNOW.

Repository is set to ccd simulator and scope simulator for eval purposes, see below

Indilib/indiserver, indi scope driver, indi camera driver, astrometry to be installed
All three indi components at a minimum to be running prior to launch

For capture/solve, if failure, up to three capture/solve iterations will be performed.
If any fail, the total script will be aborted, sync's done prior to the fail are not removed.

Relies on indi_getprop and indi_setprop for control of scope/camera
Requires indi configuration to have been done prior for the scope and camera and saved
except for those overridden, see below

BIG NOTE: Expects the given camera, exposure length can solve an image with your loaded astrometry index files.

Execution command line

progname RAOff1 DECOff1 RAOff2 DECOff2 RAOff3 DECOff3 ExpLength Longitude PathToDark

Where the RAOffX and DECOffX are
 RAOffX = offset from LST for capture 1,2,3
 DECOffX = DEC offset for capture 1,2,3
 --Note: RAOffX is signed, + is interpreted as East of LM, - as West of LM

 ExpLength = How long to expose for, in seconds
 Longitude = Longitude of observation (for LST calculation)
 PathToDark = path to darkframe file to subtract for last exposure
 -Note: PathToDark needs to be specified but if does not exist will be ignored, e.g. /tmp/JUNK


There are four components

1) Bash script that does high level control
Connect mount
Connect camera
Execute goto/capture/darksub/solve/precess/sync script
If success, repeat for second position, else fail
If success, repeat for third position, else fail

Change the scope and camera at front of file to match your setup
INDISCOPE="Celestron AUX"
INDICAM="RPI Camera"


2) Bash script that does the goto/capture/darksub/solve/precess/sync
Uses sidtime_p3_w_off below
Uses imagearith below for dark subtraction
Has hard coded convergence value for how 'close' the position read from scope is to the commanded position
Currently set to 0.1 degrees
--See    ABC=`echo "$ADRA < .1 && $ADEC < .1" | bc -l`
--Waits for .TARGET_EOD_COORD to match .EQUATORIAL_EOD_COORD within convergence value

--Waits up to 50 seconds for GoTo to converge else fails

After converge, wait hard coded 15 seconds after converged for mount to settle
--See   while [ $x -le 15 ]

In the script, change mount and camera to indi driver names
INDISCOPE="Celestron AUX"
INDICAM="RPI Camera"
Change where to save the solved images
SOLVED_PATH="MYPATH"

Copies the solved FIT's file to 
  mv /tmp/result.fits "$SOLVED_PATH/result-J2K:$MYRA1;$MYDEC-JNOW:$JNOWRA1;$JNOWDEC-`date "+%H.%M.%S-%m.%d.%Y"`.fit"

This gives solved file names containing both J2000 and JNOW coordinates and the time of capture

3) CLang program that does LST calculations
sidtime_p3_w_off.c
Compile with
 gcc  -o sidtime_p3_w_off sidtime_p3_w_off.c

This source code is a heavily modifed form of
https://github.com/window-maker/dockapps/blob/master/wmCalClock/Src/wmCalClock.c
 *      wmCalClock-1.25 (C) 1998, 1999 Mike Henderson (mghenderson@lanl.gov)


4) Python script that does J2000 to JNOW
Dependency: astropy
https://docs.astropy.org/en/stable/install.html


There is a dependency on imarith.c for dark subtraction
Source code:
https://heasarc.gsfc.nasa.gov/docs/software/fitsio/cexamples/imarith.c

Requires libcfitsio.so for compilation:
gcc -o imagearith imarith.c PATH_TO_libcfitsio.so

Notes:
Scope if not connected at start:
Sets .TIME_UTC.UTC;OFFSET= to time from linux clock
Sets .ALIGNMENT_SUBSYSTEM_MATH_PLUGINS.SVD Math Plugin=On
Sets scope polling period for 250ms, found best for CelestronAux driver
Else
Sets scope polling period for 250ms, found best for CelestronAux driver
EndIf

Camera:
  `indi_setprop "$INDICAM.UPLOAD_SETTINGS.UPLOAD_DIR=/tmp"`
  `indi_setprop "$INDICAM.UPLOAD_SETTINGS.UPLOAD_PREFIX=IMAGE_001"
  `indi_setprop "$INDICAM.CCD_GAIN.GAIN=12"
  `indi_setprop "$INDICAM.UPLOAD_MODE.UPLOAD_LOCAL=On"`

Sets 
Sets camera image directory to /tmp, sets image filename to IMAGE_001
Sets camera to 'Local Only'
Hard coded GAIN to 12



