#!/bin/sh
# ----------------------------------------------------------------------------
# Maven Wrapper script for POSIX systems
# ----------------------------------------------------------------------------
set -e
[ -z "$PROJECTION" ] || set -x

MAVEN_WRAPPER_VERSION="3.3.2"
MAVEN_VERSION="3.9.8"
WRAPPER_JAR=".mvn/wrapper/maven-wrapper.jar"

if [ -f "$WRAPPER_JAR" ]; then
    exec java -jar "$WRAPPER_JAR" "$@"
fi

if command -v mvn >/dev/null 2>&1; then
    exec mvn "$@"
else
    echo "Maven Wrapper: Neither '$WRAPPER_JAR' nor system 'mvn' was found."
    echo "Please install Maven or build with Docker: docker compose build"
    exit 1
fi
