#!/bin/bash
set -euo pipefail

if [ "${CONFIGURATION}" != "Release" ]; then
	echo "[SKIP] Not building an Release configuration, skipping DMG creation"
	exit
fi

RSYNCOSXSCHEDDMG_DMG_VERSION=$(/usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" "${PROJECT_DIR}/RsyncOSXsched/Info.plist")
RSYNCOSXSCHEDDMG_DMG="${BUILT_PRODUCTS_DIR}/RsyncOSXsched-${RSYNCOSXSCHEDDMG_DMG_VERSION}.dmg"
RSYNCOSXSCHEDDMG_APP="${BUILT_PRODUCTS_DIR}/RsyncOSXsched.app"
RSYNCOSXSCHEDDMG_APP_RESOURCES="${RSYNCOSXSCHEDDMG_APP}/Contents/Resources"

CREATE_DMG="${SOURCE_ROOT}/3thparty/github.com/andreyvit/create-dmg/create-dmg"
STAGING_DIR="${BUILT_PRODUCTS_DIR}/staging/dmg"
STAGING_APP="${STAGING_DIR}/RsyncOSXsched.app"
DMG_TEMPLATE_DIR="${SOURCE_ROOT}/Scripts/Templates/DMG"
DEFAULT_IDENTITY=$(security find-identity -v -p codesigning | grep "Developer ID" | head -1 | cut -f 4 -d " " || true)

if [ -f "${RSYNCOSXSCHEDDMG_DMG}" ]; then
	echo "-- RsyncOSXsched dmg already created"
	echo "   > ${RSYNCOSXSCHEDDMG_DMG}"
else
	echo "-- Creating RsyncOSXsched dmg"
	echo "   > ${RSYNCOSXSCHEDDMG_DMG}"
	rm -rf ${STAGING_DIR}
	mkdir -p ${STAGING_DIR}
	cp -a -p ${RSYNCOSXSCHEDDMG_APP} ${STAGING_DIR}

	if [[ ! -z "${RSYNCOSXSCHEDDMG_APP_CODE_SIGN_IDENTITY+x}" ]]; then
		echo "-- Codesign with ${RSYNCOSXSCHEDDMG_APP_CODE_SIGN_IDENTITY}"
		SELECTED_IDENTITY="${RSYNCOSXSCHEDDMG_APP_CODE_SIGN_IDENTITY}"
	elif [[ ! -z "${DEFAULT_IDENTITY}" ]]; then
		echo "-- Using first valid identity (variable RSYNCOSXSCHEDDMG_APP_CODE_SIGN_IDENTITY unset)"
		SELECTED_IDENTITY="${DEFAULT_IDENTITY}"
	else
		echo "-- Skip codesign (variable RSYNCOSXSCHEDDMG_APP_CODE_SIGN_IDENTITY unset and no Developer ID identity found)"
		SELECTED_IDENTITY=""
	fi

	if [[ ! -z "${SELECTED_IDENTITY}" ]]; then
		codesign --force --deep --sign "${SELECTED_IDENTITY}" "${STAGING_APP}"
	fi

	${CREATE_DMG} \
		--volname "RsyncOSXsched" \
		--volicon "${RSYNCOSXSCHEDDMG_APP_RESOURCES}/AppIcon.icns" \
		--background "${DMG_TEMPLATE_DIR}/background.png" \
		--window-pos -1 -1 \
		--window-size 480 540 \
		--icon "RsyncOSXsched.app" 240 130 \
		--hide-extension RsyncOSXsched.app \
		--app-drop-link 240 380 \
		${RSYNCOSXSCHEDDMG_DMG} \
		${STAGING_DIR}

	if [[ ! -z "${SELECTED_IDENTITY}" ]]; then
		codesign --sign "${SELECTED_IDENTITY}" "${RSYNCOSXSCHEDDMG_DMG}"
	fi
fi
