#!/bin/bash

folder=($(jq -r '.name' 'info.json'))
version=($(jq -r '.version' 'info.json'))

cd ..

rm -r "../${folder}_${version}"

rm "../${folder}.zip"

zip -r "../${folder}.zip" "${folder}" -x "*/.vscode/**\*"  -x "*.git*" -x "*/\.*" -x "*/archive/*" -x "*/template/*"

cd ..

unzip "${folder}.zip" && rm "${folder}.zip"

mv ${folder} "${folder}_${version}"