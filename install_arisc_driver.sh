#!/bin/bash

# var list
      NAME="ARISC drivers"
   CUR_DIR=$(pwd)
 TARGET_ID="0"
 ALL_FILES=("allwinner_CPU.h" "arisc.gpio.h" "arisc.gpio.c" "arisc.stepgen.h" \
            "arisc.stepgen.c" "gpio_api.h"   "msg_api.h"    "stepgen_api.h")
   C_FILES=("arisc.gpio.c" "arisc.stepgen.c")




# greetings
echo "--- Installing '${NAME}' -------"




# select the target from the arguments list
if [[ $# != 0 ]]; then
    for arg in $*; do
        case "${arg}" in
            "linuxcnc")   TARGET_ID="1"; ;;
            "machinekit") TARGET_ID="2"; ;;
        esac
    done
fi

# if no target selected yet
while [[ "${TARGET_ID}" != "1" && "${TARGET_ID}" != "2" ]]; do
    echo    "Please select the target:"
    echo    "  1: for LinuxCNC"
    echo    "  2: for Machinekit"
    read -p "Target: " TARGET_ID
done

# set target name
case "${TARGET_ID}" in
    1) TARGET="linuxcnc"; ;;
    2) TARGET="machinekit"; ;;
    *) TARGET="linuxcnc"; ;;
esac




# check a folder with sources
SRC_DIR="${TARGET}/drivers/arisc"

if [[ ! -d "${SRC_DIR}" ]]; then
    echo "ERROR: Can't find the './${SRC_DIR}' folder (${0}:${LINENO})."
    cd "${CUR_DIR}"
    exit 1
fi

cd "${SRC_DIR}"

for file in ${ALL_FILES[*]}; do
    if [[ ! -f "${file}" ]]; then
        echo "ERROR: Can't find the './${SRC_DIR}/${file}' file (${0}:${LINENO})."
        cd "${CUR_DIR}"
        exit 1
    fi
done




# find a compiler
if [[ $(halcompile --help | grep Usage) ]]; then
    COMPILER="halcompile"
elif [[ $(comp --help | grep Usage) ]]; then
    COMPILER="comp"
else
    echo "ERROR: Can't find a components compiler for the '${TARGET}' (${0}:${LINENO})."
    exit 1
fi




# compiling the driver
echo "Compiling the drivers ..."

for file in ${C_FILES[*]}; do
    if [[ ! $(sudo "${COMPILER}" --install "${file}" | grep Linking) ]]; then
        echo "ERROR: Failed to compile the '${file}' file (${0}:${LINENO})."
        exit 1
    fi
done

cd "${CUR_DIR}"

echo "--- The '${NAME}' successfuly installed -------"
