#!/usr/local/bin/env bash

if [ ! -d "archive" ] ; then
    mkdir -p archive
fi

mv sample/${SAMPLE}.* archive/