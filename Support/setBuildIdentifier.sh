#!/bin/sh

COMMIT_ID=$(git rev-parse --short HEAD)
perl -pi'' -e "s/[A-Za-z0-9]{7}(?=\")/$COMMIT_ID/;" Sources/PackageFramework/Version.swift