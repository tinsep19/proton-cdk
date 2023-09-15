local major="${args[--major]}"
if [ ! -f "infrastructure/package.json" ]; then
  echo "infrastructure/package.json is not exists."
  return 1
fi
local output="$(bundle_filename_from_package_json 'infrastructure/package.json')"
find . -mindepth 1 -type f | sed 's/^\.\///' | grep -v node_modules | xargs tar zcf $output
