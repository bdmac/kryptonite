#!/bin/sh

RESOURCES_TO_COPY=${PODS_ROOT}/resources-to-copy.txt
touch "$RESOURCES_TO_COPY"

install_resource()
{
  case $1 in
    *.storyboard)
      echo "ibtool --errors --warnings --notices --output-format human-readable-text --compile ${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$1\" .storyboard`.storyboardc ${PODS_ROOT}/$1 --sdk ${SDKROOT}"
      ibtool --errors --warnings --notices --output-format human-readable-text --compile "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$1\" .storyboard`.storyboardc" "${PODS_ROOT}/$1" --sdk "${SDKROOT}"
      ;;
    *.xib)
        echo "ibtool --errors --warnings --notices --output-format human-readable-text --compile ${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$1\" .xib`.nib ${PODS_ROOT}/$1 --sdk ${SDKROOT}"
      ibtool --errors --warnings --notices --output-format human-readable-text --compile "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$1\" .xib`.nib" "${PODS_ROOT}/$1" --sdk "${SDKROOT}"
      ;;
    *.framework)
      echo "rsync -rp ${PODS_ROOT}/$1 ${CONFIGURATION_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"
      rsync -rp "${PODS_ROOT}/$1" "${CONFIGURATION_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"
      ;;
    *.xcdatamodeld)
      echo "xcrun momc ${PODS_ROOT}/$1 ${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename $1 .xcdatamodeld`.momd"
      xcrun momc "${PODS_ROOT}/$1" "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename $1 .xcdatamodeld`.momd"
      ;;
    *)
      echo "${PODS_ROOT}/$1"
      echo "${PODS_ROOT}/$1" >> "$RESOURCES_TO_COPY"
      ;;
  esac
}
install_resource 'BlockAlertsAnd-ActionSheets/BlockAlertsDemo/images/arrived.png'
install_resource 'BlockAlertsAnd-ActionSheets/BlockAlertsDemo/images/arrived@2x.png'
install_resource 'BlockAlertsAnd-ActionSheets/BlockAlertsDemo/images/button_grey.png'
install_resource 'BlockAlertsAnd-ActionSheets/BlockAlertsDemo/images/button_grey@2x.png'
install_resource 'BlockAlertsAnd-ActionSheets/BlockAlertsDemo/images/button_red.png'
install_resource 'BlockAlertsAnd-ActionSheets/BlockAlertsDemo/images/button_red@2x.png'
install_resource 'BlockAlertsAnd-ActionSheets/BlockAlertsDemo/images/ActionSheet/action-black-button-selected.png'
install_resource 'BlockAlertsAnd-ActionSheets/BlockAlertsDemo/images/ActionSheet/action-black-button-selected@2x.png'
install_resource 'BlockAlertsAnd-ActionSheets/BlockAlertsDemo/images/ActionSheet/action-black-button.png'
install_resource 'BlockAlertsAnd-ActionSheets/BlockAlertsDemo/images/ActionSheet/action-black-button@2x.png'
install_resource 'BlockAlertsAnd-ActionSheets/BlockAlertsDemo/images/ActionSheet/action-gray-button-selected.png'
install_resource 'BlockAlertsAnd-ActionSheets/BlockAlertsDemo/images/ActionSheet/action-gray-button-selected@2x.png'
install_resource 'BlockAlertsAnd-ActionSheets/BlockAlertsDemo/images/ActionSheet/action-gray-button.png'
install_resource 'BlockAlertsAnd-ActionSheets/BlockAlertsDemo/images/ActionSheet/action-gray-button@2x.png'
install_resource 'BlockAlertsAnd-ActionSheets/BlockAlertsDemo/images/ActionSheet/action-red-button-selected.png'
install_resource 'BlockAlertsAnd-ActionSheets/BlockAlertsDemo/images/ActionSheet/action-red-button-selected@2x.png'
install_resource 'BlockAlertsAnd-ActionSheets/BlockAlertsDemo/images/ActionSheet/action-red-button.png'
install_resource 'BlockAlertsAnd-ActionSheets/BlockAlertsDemo/images/ActionSheet/action-red-button@2x.png'
install_resource 'BlockAlertsAnd-ActionSheets/BlockAlertsDemo/images/ActionSheet/action-sheet-panel.png'
install_resource 'BlockAlertsAnd-ActionSheets/BlockAlertsDemo/images/ActionSheet/action-sheet-panel@2x.png'
install_resource 'BlockAlertsAnd-ActionSheets/BlockAlertsDemo/images/AlertView/alert-black-button.png'
install_resource 'BlockAlertsAnd-ActionSheets/BlockAlertsDemo/images/AlertView/alert-black-button@2x.png'
install_resource 'BlockAlertsAnd-ActionSheets/BlockAlertsDemo/images/AlertView/alert-gray-button.png'
install_resource 'BlockAlertsAnd-ActionSheets/BlockAlertsDemo/images/AlertView/alert-gray-button@2x.png'
install_resource 'BlockAlertsAnd-ActionSheets/BlockAlertsDemo/images/AlertView/alert-green-button.png'
install_resource 'BlockAlertsAnd-ActionSheets/BlockAlertsDemo/images/AlertView/alert-green-button@2x.png'
install_resource 'BlockAlertsAnd-ActionSheets/BlockAlertsDemo/images/AlertView/alert-red-button.png'
install_resource 'BlockAlertsAnd-ActionSheets/BlockAlertsDemo/images/AlertView/alert-red-button@2x.png'
install_resource 'BlockAlertsAnd-ActionSheets/BlockAlertsDemo/images/AlertView/alert-window-landscape.png'
install_resource 'BlockAlertsAnd-ActionSheets/BlockAlertsDemo/images/AlertView/alert-window-landscape@2x.png'
install_resource 'BlockAlertsAnd-ActionSheets/BlockAlertsDemo/images/AlertView/alert-window.png'
install_resource 'BlockAlertsAnd-ActionSheets/BlockAlertsDemo/images/AlertView/alert-window@2x.png'
install_resource 'BlockAlertsAnd-ActionSheets/BlockAlertsDemo/images/AlertView/alert-yellow-button.png'
install_resource 'BlockAlertsAnd-ActionSheets/BlockAlertsDemo/images/AlertView/alert-yellow-button@2x.png'
install_resource 'Facebook-iOS-SDK/src/FacebookSDKResources.bundle'
install_resource 'Facebook-iOS-SDK/src/FBUserSettingsViewResources.bundle'
install_resource 'SORelativeDateTransformer/SORelativeDateTransformer/SORelativeDateTransformer.bundle'

rsync -avr --no-relative --exclude '*/.svn/*' --files-from="$RESOURCES_TO_COPY" / "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
rm "$RESOURCES_TO_COPY"
