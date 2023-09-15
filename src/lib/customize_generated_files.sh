customize_environment_tsconfig_json() {
  jq '.compilerOptions.resolveJsonModule=true | .compilerOptions.esModuleInterop=true' tsconfig.json > tmp3.json
  mv -f tmp3.json tsconfig.json
}

customize_environment_package_json() {
  local major=${1:-1}
  jq --arg major "$major" '.version="\($major).0.0"' package.json > tmp1.json
  mv -f tmp1.json package.json
}

customize_environment_cdk_json() {
  jq '.outputsFile="cdk-outputs.json" | .requireApproval="never"' cdk.json > tmp2.json
  mv -f tmp2.json cdk.json
}
