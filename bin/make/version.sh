#!/usr/bin/env bash

function info {
  echo "$(tput setaf 2)INFO: $1$(tput sgr0)"
}

function error {
  echo "$(tput setaf 1)ERROR: $1$(tput sgr0)"
}

function banner {
  echo ""
  echo "$(tput setaf 5)######## $1 #######$(tput sgr0)"
  echo ""
}

function ditto_or_exit {
  ditto "${1}" "${2}"
  if [ "$?" != 0 ]; then
    error "Could not copy:"
    error "  source: ${1}"
    error "  target: ${2}"
    if [ ! -e "${1}" ]; then
      error "The source file does not exist"
      error "Did a previous xcodebuild step fail?"
    fi
    error "Exiting 1"
    exit 1
  fi
}

XC_PROJECT=calabash.xcodeproj
XC_BUILD_CONFIG=Debug

VTOOL_BUILD_DIR=build/version-tool
mkdir -p "${VTOOL_BUILD_DIR}"

INSTALL_PATH=bin/version
rm -rf "${INSTALL_PATH}"

if [ "${XCPRETTY}" = "0" ]; then
  USE_XCPRETTY=
else
  USE_XCPRETTY=`which xcpretty | tr -d '\n'`
fi

if [ ! -z ${USE_XCPRETTY} ]; then
  XC_PIPE='xcpretty -c'
else
  XC_PIPE='cat'
fi

banner "Build Version Tool"

VTOOL="${VTOOL_BUILD_DIR}/Build/Products/${XC_BUILD_CONFIG}/version"

rm -rf "${VTOOL}"

xcrun xcodebuild build \
  -project "${XC_PROJECT}" \
  -scheme "version" \
  -SYMROOT="${VTOOL_BUILD_DIR}" \
  -derivedDataPath "${VTOOL_BUILD_DIR}" \
  -configuration "${XC_BUILD_CONFIG}" \
  -sdk macosx \
  GCC_TREAT_WARNINGS_AS_ERRORS=YES | $XC_PIPE

EXIT_CODE=${PIPESTATUS[0]}

if [ $EXIT_CODE != 0 ]; then
  error "Building version tool for framework failed."
  exit $RETVAL
else
  info "Building version tool for framework succeeded."
fi

banner "Installing Version Tool"

ditto_or_exit "${VTOOL}" "${INSTALL_PATH}"
info "Installed version tool to ${INSTALL_PATH}"

banner "Version Info"

echo "$ ${INSTALL_PATH} --revision ALL"
${INSTALL_PATH} --revision ALL

