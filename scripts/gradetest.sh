#!/bin/sh
GRADLE_OPTS=-Xmx512m ANDROID_HOME=~/Library/Android/sdk gradle testDebugUnitTest --console plain --rerun-tasks --no-daemon

