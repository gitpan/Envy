#!/bin/sh
env |grep -v '^PWD=' |grep -v '^PATH='|grep -v 'MODULE_PATH'|grep -v 'ENVY_PATH' | grep -v REGRESSION | sort
