if [ ! -f "instance_infrastructure/package.json" ]; then
  echo "instance_infrastructure/package.json is not exists."
  return 1
fi
local output="$(bundle_filename_from_package_json 'instance_infrastructure/package.json')"
find . -mindepth 1 -type f | sed 's/^\.\///' | grep -v node_modules | xargs tar zcf $output
