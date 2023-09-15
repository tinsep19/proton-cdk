local name="${args[name]}"
local major="${args[--major]}"

local tmpdir="$(mktemp -d)"
mkdir -p "$tmpdir/$name"

pushd "$tmpdir/$name" >/dev/null
  npx cdk init app --language=typescript --generate-only
  create_environment_manifest_yaml
  create_cdk_to_proton_sh
  customize_environment_package_json "$major"
  customize_environment_cdk_json
  customize_environment_tsconfig_json
popd >/dev/null

if [ -z "$major" ]; then
  mkdir -p "$name/schema"
  pushd "$name/schema" >/dev/null
    create_environment_schema
  popd >/dev/null
  mv "$tmpdir/$name" "$name/infrastructure"
else
  mkdir -p "$name/v$major/schema"
  pushd "$name/v$major/schema" >/dev/null
    create_environment_schema
  popd >/dev/null
  mv "$tmpdir/$name" "$name/v$major/infrastructure"
fi

rmdir $tmpdir
