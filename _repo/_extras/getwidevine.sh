#!/bin/sh
set -e

LIBNAME=libwidevinecdm.so

# Legacy installation
if [ -d ~/decrypters ]; then
  rm -fr ~/.kodi/cdm
  mv ~/decrypters ~/.kodi/cdm
  [ -f /usr/lib/libssd_wv.so ] && ln -fs /usr/lib/libssd_wv.so ~/.kodi/cdm/libssd_wv.so
  echo "Successfully installed ${LIBNAME}!"
  exit 0
fi

[ -z "${ARCH}" ] && ARCH=$(grep -m1 ARCH= /etc/os-release | sed 's/"//g' | cut -d. -f2)
if [ -z "${ARCH}" ]; then
  echo "ERROR: Unable to determine ARCH for this system!"
  echo "ERROR: Specicy ARCH=arm or ARCH=x86_64 if /etc/os-release does define a suitable ARCH"
  exit 1
fi
echo "Detected ARCH: ${ARCH}"

mkdir -p ~/.kodi/cdm
cd ~/.kodi/cdm

# Sym link to whatever libssd_wv.so we can find...
for l in /usr/lib/libssd_wv.so ~/.kodi/addons/inputstream.mpd/lib/libssd_wv.so; do
  if [ -f ${l} ]; then
    rm -f ~/.kodi/cdm/libssd_wv.so
    ln -fs ${l} ~/.kodi/cdm/libssd_wv.so
    break
  fi
done

if [ ! -f ./${LIBNAME} ]; then
  echo "Download directory: $(pwd)"

  case $ARCH in
    arm)
      #See https://www.raspberrypi.org/forums/viewtopic.php?p=839875&sid=58ac945dede918b24cc478fc4b44b004#p839875
      echo "Downloading: ${LIBNAME} for ${ARCH}..."
      curl -Lf --progress-bar --url http://odroidxu.leeharris.me.uk/xu3/chromium-widevine-1.4.8.823-2-armv7h.pkg.tar.xz -o - | \
        tar xJfO - usr/lib/chromium/libwidevinecdm.so >./${LIBNAME}
      chmod 755 ./${LIBNAME}
      ;;

    x86 | x86_64)
      echo "Downloading: google-chrome-stable for ${ARCH}..."
      curl -Lf --progress-bar --url https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb -o ./temp.deb && \
        ar x temp.deb data.tar.xz && \
        echo "Extracting ${LIBNAME}..." && \
        tar xJfO data.tar.xz ./opt/google/chrome/libwidevinecdm.so >./${LIBNAME} && \
        chmod 755 ./${LIBNAME}
      rm -f temp.deb data.tar.xz
      ;;

    *)
      echo
      echo "ERROR: Arch ${ARCH} is not supported!"
      exit 1
      ;;
  esac

  echo
fi

[ -f ./${LIBNAME} ] \
  &&  echo "Successfully installed ${LIBNAME}!" \
  ||  echo "ERROR: Unable to install ${LIBNAME}"
