#!/usr/bin/env bash

## TODO:
##   - More verbose -s option
##   - Write header
##   - Write help string
##   - Implement -x option

### --------------------------------------------------------------------------
### -- VARIABLES -------------------------------------------------------------
### --------------------------------------------------------------------------

hflag=''  # -h, help option flag
sflag=''  # -s, setup option flag
xflag=''  # -x, exclusion option flag (for debugging)

##  The following are the default values for the working directory and
##  their sub-directories. Modifying these values would allow the user
##  to circumvent using the -d option upon execution. If additional
##  sub-directories are added, then additional logic will be needed in the
##  pickImage function to handle the additonal sub-directories.

WALLPAPER_DIR="$HOME/Pictures/_wallpapers"           # working directory
LATE_NIGHT_DIR="$WALLPAPER_DIR/_00-06-late-night"    # late night sub-directory
MORNING_DIR="$WALLPAPER_DIR/_06-12-morning"          # morning sub-directory
AFTERNOON_DIR="$WALLPAPER_DIR/_12-18-afternoon"      # afternoon sub-directory
NIGHT_DIR="$WALLPAPER_DIR/_18-23-night"              # night sub-directory

currentHour=$(date +%H)   # current hour
imagePath=""              # image path

### --------------------------------------------------------------------------
### -- FUNCTIONS -------------------------------------------------------------
### --------------------------------------------------------------------------

##  Prompts the user to install coreutils via homebrew.
##  Only executed if the -s option is provided.

function installGshuf {
  read -p \
  "Missing dependency 'gshuf' which is a part of coreutils. Would you like to use homebrew to install coreutils? [y/n] " uin
  case $uin in
    y|Y)  command -v brew >/dev/null 2>&1 || installHomebrew
          brew install coreutils
          ;;
    n|N)  exit 1
          ;;
    *)    printf '**ERROR: invalid input, enter y/n\n'
          installGshuf
          ;;
  esac
}

##  The default method for installing coreutils is through homebrew. If
##  homebrew isn't installed then the function prompts the user to install
##  homebrew via curl.
##  Only executed if the -s option is provided and homebrew isn't found on
##  the system.
##
##  More information about homebrew can be found at: https://brew.sh

function installHomebrew {
  read -p \
  "Missing homebrew which is the prefered way to install new packages. Would you like to install homebrew? [y/n] " uin
  case $uin in
    y|Y)  /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
          brew -v upgrade
          brew update
          ;;
    n|N)  exit 1
          ;;
    *)    printf '**ERROR: invalid input, enter y/n\n'
          installHomebrew
          ;;
  esac
}

##  Picks a random image in the given folder based on the hour.
##  The working directory and sub-directories can be modified under the
##  VARIABLES section above. If additional sub-directories are added,
##  then additional logic will be needed in the pickImage function to
##  handle the additonal sub-directories.
##
##  current sub-directories:
##    <time of day>     <hour range>    <folder name>
##    late-night        [0, 6)          _00-06-late-night
##    morning           [6, 12)         _06-12-morning
##    afternoon         [12, 18)        _12-18-afternoon
##    night             [18, 23]        _18-23-night

function pickImage {
  if [ $currentHour -ge 0 -a $currentHour -lt 6 ]
  then
    imagePath="$(gshuf -n1 -e $LATE_NIGHT_DIR/*)"
  elif [ $currentHour -ge 6 -a $currentHour -lt 12 ]
  then
    imagePath="$(gshuf -n1 -e $MORNING_DIR/*)"
  elif [ $currentHour -ge 12 -a $currentHour -lt 18 ]
  then
    imagePath="$(gshuf -n1 -e $AFTERNOON_DIR/*)"
  elif [ $currentHour -ge 18 -a $currentHour -le 23 ]
  then
    imagePath="$(gshuf -n1 -e $NIGHT_DIR/*)"
  else
    echo "Something went wrong."
  fi
}

### --------------------------------------------------------------------------
### -- OPTION PARSING --------------------------------------------------------
### --------------------------------------------------------------------------

while getopts d:hsx opt
do
    case "$opt" in
      d)  WALLPAPER_DIR="$OPTARG";;
      h)  hflag='true'
          ;;
      s)  sflag='true'
          ;;
      x)  xflag='true'
          ;;
      \?) printf >&2 \
	        "usage: $0 [-d directory] [-h] [-s] [-x]\n"
	        exit 1
          ;;
    esac
done
shift `expr $OPTIND - 1`

### --------------------------------------------------------------------------
### -- MAIN ------------------------------------------------------------------
### --------------------------------------------------------------------------

## h flag logic
if [[ $hflag == 'true' ]]; then
  printf "~~ replace with help string ~~"
  exit 1
fi

## s flag logic
if [[ $sflag == 'true' ]]; then
  if command -v gshuf >/dev/null 2>&1; then
    printf "All dependencies are present. Continuing..."
  else
    installGshuf
  fi
fi

## checks for dependencies
command -v gshuf >/dev/null 2>&1 || {
  printf >&2 "**ERROR: missing dependencies, install coreutils or run again with the -s flag enabled"
  exit 1
}

pickImage

## x flag logic
if [[ $xflag == 'true' ]]; then
  printf "Path to chosen image: %s\n" "$imagePath"
else
  osascript -e "tell application \"Finder\" to set desktop picture to \"$imagePath\" as POSIX file"
fi
