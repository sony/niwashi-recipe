#!/bin/bash
set -euox pipefail


# find Vagrantfile and run `vagrant destroy -f` in its directory
find . -name Vagrantfile -execdir vagrant destroy -f \;

# find .venv and remove it
find . -name .venv -type d -exec rm -rf {} +

# remove .niwashi directory
rm -rf .niwashi

# remove plan.json if it exists
rm -f plan.json
