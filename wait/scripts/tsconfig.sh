#!/usr/bin/env bash


MD="`dirname $(readlink -f ${0})`/.."
TSCONFIG_FILE="${MD}/tsconfig-prod-aot.json"

declare -i START_YEAR="${1}"
declare -i YEAR="${2}"

write_file()
{
  cat << EOF
{
  "extends": "./tsconfig.json",
  "compileOnSave": false,
  "compilerOptions": {
    "outDir": "public",
    "importHelpers": true,
    "module": "es2020",
    "noImplicitAny": true,
    "removeComments": true,
    "suppressImplicitAnyIndexErrors": true,
  },
  "files": [
EOF

  while [[ ${START_YEAR} -le ${YEAR} ]]; do
    echo -e "    \"src/app/${START_YEAR}/${START_YEAR}.module.ts\","
    echo -e "    \"src/app/top/${START_YEAR}/${START_YEAR}.module.ts\","
    START_YEAR=$(( ${START_YEAR} + 1 ))
  done

  cat << EOF
    "src/app/app.module.ts",
    "src/main.ts"
  ],

  "angularCompilerOptions": {
    "skipMetadataEmit": true,
    "fullTemplateTypeCheck": true,
    "entryModule": "src/app/app.module#AppModule"
  }
}
EOF
}

write_file > ${TSCONFIG_FILE}
