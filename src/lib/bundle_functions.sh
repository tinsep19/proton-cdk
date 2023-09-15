bundle_filename_from_package_json () {
    local pkg="$1"
    jq -r '"\(.name)-\(.version).tar.gz"' "$pkg"
}