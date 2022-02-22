#!/bin/bash

# Podspec names
corePodspec="TinkoffASDKCore.podspec"
uiPodspec="TinkoffASDKUI.podspec"
versionSwift="TinkoffASDKCore/TinkoffASDKCore/Version.swift"

read -p "Enter new version string: " version
if [[ $version != "" && $version =~ ^[0-9]*[\.][0-9]*[\.][0-9]*.*$ ]]; then
sed -i '' "s/\(spec.version = \)\(.*\)/\1'$version'/" $corePodspec
sed -i '' "s/\(spec.version = \)\(.*\)/\1'$version'/" $uiPodspec
sed -i '' "s/\(versionString = \)\(.*\)/\1\"$version\"/" $versionSwift
else
echo "Invalid version format, please use \"n.n.n\" format"
fi
