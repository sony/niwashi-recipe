#!/bin/bash
set -euox pipefail

RECIPE_DIR_OPT="--recipe-dir ./test-recipe"
RECIPE_DIR_OPT="${RECIPE_DIR_OPT} --recipe-dir ../../../python"
RECIPE_DIR_OPT="${RECIPE_DIR_OPT} --recipe-dir ../../../vagrant"

export NWS_LOG_LEVEL="DEBUG"
#DEBUG_OPT="--dry-run simulate"
DEBUG_OPT=""
OPT_LOG="--log-format plain --log-file test.log"

./cleanup.sh

nwsctl version

if [ -d .niwashi ]; then
    echo "Already initialized"
else
nwsctl init
fi

# Construct
nwsctl plan -t desired-state.yaml $RECIPE_DIR_OPT $OPT_LOG
nwsctl apply --plan plan.json $RECIPE_DIR_OPT $DEBUG_OPT $OPT_LOG

# Destruct
nwsctl plan --destroy $RECIPE_DIR_OPT $OPT_LOG
nwsctl apply --destroy --yes --plan plan.json $RECIPE_DIR_OPT $DEBUG_OPT $OPT_LOG
