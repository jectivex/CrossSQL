#!/bin/bash
echo ANDROID_HOME: ${ANDROID_HOME}
GRADLE_OPTS=-Xmx512m ANDROID_HOME=${ANDROID_HOME:-~/Library/Android/sdk} gradle testDebugUnitTest --console plain --rerun-tasks --no-daemon

