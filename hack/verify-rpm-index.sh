#!/usr/bin/env bash

# Copyright 2021 Hewlett Packard Enterprise Development LP

PACKAGING_TOOLS_IMAGE="arti.hpc.amslabs.hpecorp.net/internal-docker-stable-local/packaging-tools:0.12.3"

set -o errexit
set -o pipefail

ROOTDIR="$(dirname "${BASH_SOURCE[0]}")/.."

[[ $# -gt 0 ]] || set -- "${ROOTDIR}/rpm/cray/csm/sle-15sp2/index.yaml" "${ROOTDIR}/rpm/cray/csm/sle-15sp2-compute/index.yaml"

#pass the repo credentials environment variables to the container that runs rpm-sync
REPO_CREDS_DOCKER_OPTIONS=""
REPO_CREDS_RPMSYNC_OPTIONS=""
if [ ! -z "$ARTIFACTORY_USER" ] && [ ! -z "$ARTIFACTORY_TOKEN" ]; then
    REPOCREDSPATH="/tmp/"
    REPOCREDSFILENAME="repo_creds.json"
    jq --null-input   --arg url "https://artifactory.algol60.net/artifactory/" --arg realm "Artifactory Realm" --arg user "$ARTIFACTORY_USER"   --arg password "$ARTIFACTORY_TOKEN"   '{($url): {"realm": $realm, "user": $user, "password": $password}}' > $REPOCREDSPATH$REPOCREDSFILENAME
    REPO_CREDS_DOCKER_OPTIONS="--mount type=bind,source=${REPOCREDSPATH},destination=/repo_creds_data"
    REPO_CREDS_RPMSYNC_OPTIONS="-c /repo_creds_data/${REPOCREDSFILENAME}"
    trap "rm -f '${REPOCREDSPATH}${REPOCREDSFILENAME}'" EXIT
fi

while [[ $# -gt 0 ]]; do
    docker run ${REPO_CREDS_DOCKER_OPTIONS} --rm -i "$PACKAGING_TOOLS_IMAGE" rpm-sync ${REPO_CREDS_RPMSYNC_OPTIONS} -v -n 32 - >/dev/null < "$1"
    shift
done
