#!/usr/bin/env python3

import os, sys, getopt
from string import Template

dir_path = os.path.dirname(os.path.realpath(__file__))
app_path = os.path.join(dir_path, '..')
startWith = 2017

def tsconfig(year):
  text = '''{
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
  "files": ['''
  start = startWith
  while (start <= year):
    tmp = '''
    "src/app/${year}/${year}.module.ts",
    "src/app/users/${year}/${year}.module.ts",'''
    text += Template(tmp).substitute(year=start)
    start += 1

  text += '''
    "src/app/app.module.ts",
    "src/main.ts"
  ],

  "angularCompilerOptions": {
    "skipMetadataEmit": true,
    "fullTemplateTypeCheck": true,
    "entryModule": "src/app/app.module#AppModule"
  }
}'''
  return text

def createFiles(year):
  with open(os.path.join(app_path, 'tsconfig-prod-aot.json'), 'w') as f:
    f.write(tsconfig(year))

def main(argv):
  opts, args = getopt.getopt(argv, "y:")
  for opt, arg in opts:
    if opt == '-y':
      year = int(arg)
  createFiles(year)

if __name__ == '__main__':
  main(sys.argv[1:])
