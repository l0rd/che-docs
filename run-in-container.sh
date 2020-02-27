#!/bin/sh
#
# Copyright (c) 2018 Red Hat, Inc.
# This program and the accompanying materials are made
# available under the terms of the Eclipse Public License 2.0
# which is available at https://www.eclipse.org/legal/epl-2.0/
#
# SPDX-License-Identifier: EPL-2.0
#

set -eu

usage() {
  echo "$0 [-h] [-prod] [-war] [-testadoc]
  OPTIONS:
    (no option)                     Building and serving the docs for local preview.
    -prod                           Building for production, to publish on eclipse.org/che/docs/.
    -war                            Building for embedding in Che, to link from the app.
    -newassembly <guide> <title>    Create a new assembly in guide <guide>, with title <title>
    -newconcept <guide> <title>     Create a new concept in guide <guide>, with title <title>
    -newprocedure <guide> <title>   Create a new procedure in guide <guide>, with title <title>
    -newreference <guide> <title>   Create a new reference in guide <guide>, with title <title>
    -test-adoc [<fileslist>]        Run test-adoc.sh on files (default: on all files)
    -vale [<fileslist>]             Run vale linter on files (default: on all files)
  "
}

run_newdoc() {
    shift
    SRC_PATH="$(pwd)/src/main/pages/che-7/${1}"
    shift
    TITLE="${*}"
    echo "Running newdoc in ${SRC_PATH} with option \"${NATURE}\" \"${TITLE}\""
    cd "${SRC_PATH}"
    newdoc -C "${NATURE}" "${TITLE}"
}

case "$1" in
  -h)
    usage
    ;;
  -prod)
    echo "Building for production (publishing on eclipse.org/che/docs/)."
    cd /che-docs && jekyll clean && jekyll build --config _config.yml,_config-web.yml
    ;;
  -war)
    echo "Building for embedding in Che (linking from the app)."
    cd /che-docs && jekyll clean && jekyll build --config _config.yml,_config-war.yml
    ;;
  -newassembly)
    NATURE="-a"
    run_newdoc "$@"
    ;;
  -newconcept)
    NATURE="-c"
    run_newdoc "$@"
    ;;
  -newprocedure)
    NATURE="-p"
    run_newdoc "$@"
    ;;
  -newreference)
    NATURE="-r"
    run_newdoc "$@"
    ;;
  -test-adoc)
    shift
    SRC_PATH="$(pwd)"
    FILES="${*:-src/main/pages/*/*/*.adoc}"
    echo "Running test-adoc.sh on ${FILES}"
    test-adoc.sh ${FILES}
    ;;
  -vale)
    shift
    SRC_PATH="$(pwd)"
    FILES="${*:-.}"
    echo "Running vale on ${FILES}"
    vale ${FILES}
    ;;
  *)
    echo "Building and serving the docs for local preview."
    cd /che-docs && jekyll clean && jekyll serve --livereload -H 0.0.0.0 --trace
  ;;
esac
