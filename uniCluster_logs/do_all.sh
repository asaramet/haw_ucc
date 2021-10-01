#!/usr/bin/env bash

MD="`dirname $(readlink -f ${0})`"

${MD}/sacct_logs.sh &&
${MD}/sreport_logs.sh &&
${MD}/sacct_trunc.sh &&
${MD}/sync.sh
