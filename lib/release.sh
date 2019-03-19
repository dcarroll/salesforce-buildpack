#!/usr/bin/env bash

START_TIME=$SECONDS

# set -x
set -o errexit      # always exit on error
set -o pipefail     # don't ignore exit codes when piping output
unset GIT_DIR       # Avoid GIT_DIR leak from previous build steps

while getopts "a:p:x:" option
do
  case "${option}"
  in
    a) TARGET_SCRATCH_ORG_ALIAS=${OPTARG};;
    p) SFDX_PACKAGE_VERSION_ID=${OPTARG};;
    x) scratchSfdxAuthUrl=${OPTARG}
  esac
done

# if [ "$SFDX_INSTALL_PACKAGE_VERSION" == "true" ]; then
#  TARGET_SCRATCH_ORG_ALIAS=${1:-}
#   SFDX_PACKAGE_VERSION_ID=${2:-}
# fi

vendorDir="vendor/sfdx"

source "$vendorDir"/common.sh
source "$vendorDir"/sfdx.sh
source "$vendorDir"/stdlib.sh

: ${SFDX_BUILDPACK_DEBUG:="false"}

header "Running release.sh"

# Setup local paths
log "Setting up paths ..."

setup_dirs "."

log "Config vars ..."
debug "SFDX_DEV_HUB_AUTH_URL: $SFDX_DEV_HUB_AUTH_URL"
debug "STAGE: $STAGE"
debug "SFDX_AUTH_URL: $SFDX_AUTH_URL"
debug "SFDX_BUILDPACK_DEBUG: $SFDX_BUILDPACK_DEBUG"
debug "CI: $CI"
debug "HEROKU_TEST_RUN_BRANCH: $HEROKU_TEST_RUN_BRANCH"
debug "HEROKU_TEST_RUN_COMMIT_VERSION: $HEROKU_TEST_RUN_COMMIT_VERSION"
debug "HEROKU_TEST_RUN_ID: $HEROKU_TEST_RUN_ID"
debug "STACK: $STACK"
debug "SOURCE_VERSION: $SOURCE_VERSION"
debug "TARGET_SCRATCH_ORG_ALIAS: $TARGET_SCRATCH_ORG_ALIAS"
debug "SFDX_INSTALL_PACKAGE_VERSION: $SFDX_INSTALL_PACKAGE_VERSION"
debug "SFDX_CREATE_PACKAGE_VERSION: $SFDX_CREATE_PACKAGE_VERSION"
debug "SFDX_PACKAGE_NAME: $SFDX_PACKAGE_NAME"
debug "SFDX_PACKAGE_VERSION_ID: $SFDX_PACKAGE_VERSION_ID"

whoami=$(whoami)
debug "WHOAMI: $whoami"

# This invokes a JS script to handle all the release process logic.
# As long as most of the var have been created as env vars it should
# be easy to access the values set during the compile state.
# There may be a few values to pass to the node process.
debug "Launching bin/release.js"
debug "XOrg auth file: "$scratchOrgAuthFile 
invokeCmd "node bin/release.js v=$vendorDir a=$TARGET_SCRATCH_ORG_ALIAS p=$SFDX_PACKAGE_VERSION_ID x=$scratchSfdxAuthUrl"

header "DONE! Completed in $(($SECONDS - $START_TIME))s"
exit 0
