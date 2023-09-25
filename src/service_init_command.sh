local name="${args[name]}"
local major="${args[--major]}"
local target="${args[--target-environment]}"

local tmpdir="$(mktemp -d)"
mkdir -p "$tmpdir/$name"

pushd "$tmpdir/$name" >/dev/null
  npx cdk init app --language=typescript --generate-only
  create_template_registration "$target"
  create_service_manifest_yaml
  create_cdk_to_proton_sh
  customize_service_package_json "$major"
  customize_service_cdk_json
  customize_service_tsconfig_json
popd >/dev/null

if [ -z "$major" ]; then
  mkdir -p "$name/schema"
  pushd "$name/schema" >/dev/null
    create_service_schema
  popd >/dev/null
  mv "$tmpdir/$name" "$name/instance_infrastructure"
else
  mkdir -p "$name/v$major/schema"
  pushd "$name/v$major/schema" >/dev/null
    create_service_schema
  popd >/dev/null
  mv "$tmpdir/$name" "$name/v$major/instance_infrastructure"
fi

rmdir $tmpdir
