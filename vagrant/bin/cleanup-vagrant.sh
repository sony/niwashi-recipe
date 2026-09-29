#!/bin/bash

vagrant_dirs=$(find . -name .vagrant)

for d in ${vagrant_dirs}; do
    pushd $(dirname $d)
    vagrant destroy -f
    popd
done
