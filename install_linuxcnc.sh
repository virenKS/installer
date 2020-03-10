#!/bin/bash

# var list
      NAME="LinuxCNC"
   VERSION=""
   DOC_LNG=""
   DOC_DIR="/usr/share/doc/linuxcnc"
   SRC_DIR="./linuxcnc"
  SRC_ARCH=("armhf")
  DST_ARCH=("armv7")
 ALL_FILES=("linuxcnc-doc-en_2.8.0~pre1_all.deb" \
            "linuxcnc-doc-es_2.8.0~pre1_all.deb" \
            "linuxcnc-doc-fr_2.8.0~pre1_all.deb" \
            "linuxcnc-uspace_2.8.0~pre1_armhf.deb" \
            "linuxcnc-uspace-dbgsym_2.8.0~pre1_armhf.deb" \
            "linuxcnc-uspace-dev_2.8.0~pre1_armhf.deb" \
            \
            "linuxcnc-doc-en_2.7.15_all.deb" \
            "linuxcnc-doc-es_2.7.15_all.deb" \
            "linuxcnc-doc-fr_2.7.15_all.deb" \
            "linuxcnc-uspace_2.7.15_armhf.deb" \
            "linuxcnc-uspace-dbgsym_2.7.15_armhf.deb" \
            "linuxcnc-uspace-dev_2.7.15_armhf.deb" \
            )




# greetings
echo "--- Installing '${NAME}' -------"




# select the VERSION from the arguments list
if [[ $# != 0 ]]; then
    for arg in $*; do
        case $arg in
            "2.7") VERSION="2.7"; ;;
            "2.8") VERSION="2.8"; ;;
        esac
    done
fi

# if no VERSION selected yet
while [[ "${VERSION}" != "1"   && "${VERSION}" != "2" && \
         "${VERSION}" != "2.7" && "${VERSION}" != "2.8" ]]; do
    echo    "Please select the ${NAME} version:"
    echo    "  1: LinuxCNC 2.7"
    echo    "  2: LinuxCNC 2.8"
    read -p "Version: " VERSION
done

# set VERSION
case "${VERSION}" in
    "1")   VERSION="2.7"; ;;
    "2")   VERSION="2.8"; ;;
    "2.7") VERSION="2.7"; ;;
    "2.8") VERSION="2.8"; ;;
    *)     VERSION="2.7"; ;;
esac




# select the language for documentation from the arguments list
if [[ $# != 0 ]]; then
    for arg in $*; do
        case $arg in
            "en") DOC_LNG="en"; ;;
            "es") DOC_LNG="es"; ;;
            "fr") DOC_LNG="fr"; ;;
        esac
    done
fi

# if no language for documentation selected yet
while [[ "${DOC_LNG}" != "1"  && "${DOC_LNG}" != "2"  && "${DOC_LNG}" != "3" && \
         "${DOC_LNG}" != "en" && "${DOC_LNG}" != "es" && "${DOC_LNG}" != "fr" ]]; do
    echo    "Please select the language for documentation:"
    echo    "  1: English"
    echo    "  2: Spanish"
    echo    "  3: French"
    read -p "Language for docs: " DOC_LNG
done

# set language for documentation
case "${DOC_LNG}" in
    "1")  DOC_LNG="en"; ;;
    "2")  DOC_LNG="es"; ;;
    "3")  DOC_LNG="fr"; ;;
    "en") DOC_LNG="en"; ;;
    "es") DOC_LNG="es"; ;;
    "fr") DOC_LNG="fr"; ;;
    *)    DOC_LNG="en"; ;;
esac




# check folders/files
if [[ ! -d "${SRC_DIR}" ]]; then
    echo "ERROR: Can't find the '${SRC_DIR}' folder (${0}:${LINENO})."
    exit 1
fi

for file in ${ALL_FILES[*]}; do
    if [[ ! -f "${SRC_DIR}/${file}" ]]; then
        echo "ERROR: Can't find the '${SRC_DIR}/${file}' file (${0}:${LINENO})."
        exit 1
    fi
done




# check CPU arch
for arch in ${DST_ARCH[*]}; do
    if [[ ! $(uname -m | grep "${arch}") ]]; then
        echo "Supported CPU types: ${DST_ARCH[*]}"
        echo "ERROR: Your CPU type ($(uname -m)) isn't supported (${0}:${LINENO})."
        exit 1
    fi
done




# get packages data
PKG_ARCH=""
arch_cnt=${#DST_ARCH[@]}

for (( a=0; a < $arch_cnt; a++ )); do
    if [[ $(uname -m | grep "${DST_ARCH[$a]}") ]]; then
        PKG_ARCH="${SRC_ARCH[$a]}"
        break
    fi
done

ALL_PKGS=$(ls $SRC_DIR | grep "all.deb")
ARCH_PKGS=$(ls $SRC_DIR | grep "$PKG_ARCH.deb")

MAIN_PKG=${SRC_DIR}"/"$(echo "${ARCH_PKGS}" | grep "uspace_$VERSION")
DEV_PKG=$SRC_DIR"/"$(echo "$ARCH_PKGS" | grep "dev_$VERSION")
DBG_PKG=$SRC_DIR"/"$(echo "$ARCH_PKGS" | grep "dbgsym_$VERSION")
DOC_PKG=$SRC_DIR"/"$(echo "$ALL_PKGS" | grep "doc-${DOC_LNG}_$VERSION")




# installing packages
echo "Installing packages ..."

echo "Installing '$MAIN_PKG' ..."
if [[ -f $MAIN_PKG ]]; then
    sudo apt install $MAIN_PKG -qq
fi
if [[ ! $(linuxcnc -help | grep Usage) ]]; then
    echo "ERROR: Failed to install '${MAIN_PKG}' package (${0}:${LINENO})."
    exit 1
fi

echo "Installing '$DEV_PKG' ..."
if [[ -f $DEV_PKG ]]; then
    sudo apt install $DEV_PKG -qq
fi
if [[ ! $(halcompile --help | grep Usage) ]]; then
    echo "ERROR: Failed to install '${DEV_PKG}' package (${0}:${LINENO})."
    exit 1
fi

#echo "Installing '$DBG_PKG' ..."
#
#if [[ -f $DBG_PKG ]]; then
#    sudo apt -y install $DBG_PKG
#fi

echo "Installing '$DOC_PKG' ..."
if [[ -f $DOC_PKG ]]; then
    sudo apt install $DOC_PKG -qq
fi
if [[ ! -d "${DOC_DIR}" ]]; then
    echo "WARNING: Documentation folder '${DOC_DIR}' isn't found (${0}:${LINENO})."
else
    docs_files_ok=""
    case $DOC_LNG in
        "en") if [[ $(ls "${DOC_DIR}" | grep "on.pdf") || 
                    $(ls "${DOC_DIR}" | grep "ed.pdf") ]]; then
                 docs_files_ok="1"
              fi ;;
        "es") if [[ $(ls "${DOC_DIR}" | grep "_es.pdf") ]]; then
                 docs_files_ok="1"
              fi ;;
        "fr") if [[ $(ls "${DOC_DIR}" | grep "_fr.pdf") ]]; then
                 docs_files_ok="1"
              fi ;;
    esac
    if [[ ! $docs_files_ok ]]; then
        echo "WARNING: Documentation files isn't found (${0}:${LINENO})."
    fi
fi




echo "--- The '${NAME}' successfully installed -------"