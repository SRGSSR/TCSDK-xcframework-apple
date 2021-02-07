#!/bin/bash

# `--no-debug-symbols` option does not include dSYMs and BCSymbolMaps. Optional, default: debug symbols included.

execution_dir=`pwd`

scheme_name="TCSDK"
framework_name="$scheme_name.framework"
xcframework_name="$scheme_name.xcframework"
xcframework_zip_name="$xcframework_name.zip"
package_file_name="Package.swift"

xcframework_path="$execution_dir/$xcframework_name"
package_file_path="$execution_dir/$package_file_name"

xcarchive_framework="Products/Library/Frameworks/$framework_name"
xcarchive_dsym="dSYMs/$framework_name.dSYM"
xcarchive_bc_symbol_maps="BCSymbolMaps"

iphoneos_archive="archives/iphoneos.xcarchive"
iphonesimulator_archive="archives/iphonesimulator.xcarchive"
appletvos_archive="archives/appletvos.xcarchive"
appletvsimulator_archive="archives/appletvsimulator.xcarchive"

framework_dir="${@: -1}/TagCommander"
if [ ! -d "$framework_dir" ]; then
    echo "Please provide a correct Tag Commander local source code repository file path"
    exit 0
fi

if [ ! -f "$package_file_path" ]; then
    echo "Next time, execute the script in the working directory, and the Package.swift file will be updated"
fi

rm -rf "$xcframework_path"
rm -rf "$xcframework_path.zip"

pushd "$framework_dir" > /dev/null

echo "Building iphoneos variant..."
xcodebuild archive -scheme $scheme_name -sdk iphoneos -archivePath $iphoneos_archive SKIP_INSTALL=NO BUILD_LIBRARY_FOR_DISTRIBUTION=YES &> /dev/null

echo "Building iphonesimulator variant..."
xcodebuild archive -scheme $scheme_name -sdk iphonesimulator -archivePath $iphonesimulator_archive SKIP_INSTALL=NO BUILD_LIBRARY_FOR_DISTRIBUTION=YES &> /dev/null

echo "Building appletvos variant..."
xcodebuild archive -scheme $scheme_name -sdk appletvos -archivePath $appletvos_archive SKIP_INSTALL=NO BUILD_LIBRARY_FOR_DISTRIBUTION=YES &> /dev/null

echo "Building appletvsimulator variant..."
xcodebuild archive -scheme $scheme_name -sdk appletvsimulator -archivePath $appletvsimulator_archive SKIP_INSTALL=NO BUILD_LIBRARY_FOR_DISTRIBUTION=YES &> /dev/null

if [ "$1" == "--no-debug-symbols" ]; then
    echo "Packaging XCFramework without debug symbols..."
else
    echo "Packaging XCFramework with debug symbols..."
    iphoneos_debug_symbols_opts=( -debug-symbols "$framework_dir/$iphoneos_archive/$xcarchive_dsym" )
    for bc_symbol_map in `find "$iphoneos_archive/$xcarchive_bc_symbol_maps" -type f -name "*"`
    do
        iphoneos_debug_symbols_opts+=( -debug-symbols "$framework_dir/$bc_symbol_map" )
    done

    iphonesimulator_debug_symbols_opts=( -debug-symbols "$framework_dir/$iphonesimulator_archive/$xcarchive_dsym" )

    appletvos_debug_symbols_opts=( -debug-symbols "$framework_dir/$appletvos_archive/$xcarchive_dsym" )
    for bc_symbol_map in `find "$appletvos_archive/$xcarchive_bc_symbol_maps" -type f -name "*"`
    do
        appletvos_debug_symbols_opts+=( -debug-symbols "$framework_dir/$bc_symbol_map" )
    done

    appletvsimulator_debug_symbols_opts=( -debug-symbols "$framework_dir/$appletvsimulator_archive/$xcarchive_dsym" )
fi

xcodebuild -create-xcframework \
    -framework "$iphoneos_archive/$xcarchive_framework" \
    "${iphoneos_debug_symbols_opts[@]}" \
    -framework "$iphonesimulator_archive/$xcarchive_framework" \
    "${iphonesimulator_debug_symbols_opts[@]}" \
    -framework "$appletvos_archive/$xcarchive_framework" \
    "${appletvos_debug_symbols_opts[@]}" \
    -framework "$appletvsimulator_archive/$xcarchive_framework" \
    "${appletvsimulator_debug_symbols_opts[@]}" \
    -output "$xcframework_path" &> /dev/null

echo "Cleanup source code repository..."
rm -rf archives
rm "$framework_name"

popd > /dev/null

pushd "$execution_dir" > /dev/null

zip -r "$xcframework_zip_name" "$xcframework_name" > /dev/null
rm -rf "$xcframework_name"

# Currently a Package.swift file must be found for the command to succeed
dummy_package_file_created=false
if [ ! -f "$package_file_path" ]; then
    touch "$package_file_path"
    dummy_package_file_created=true
fi

xcframework_zip_path="NaN"
hash="NaN"
saved_information=""

if [ -f "$xcframework_zip_name" ]; then
    xcframework_zip_path="$execution_dir/$xcframework_zip_name"

    hash=`swift package compute-checksum "$xcframework_zip_name"`

    if ! $dummy_package_file_created; then
        old_hash=$(grep 'checksum: String =' $package_file_path)
        old_hash="$(echo -e "${old_hash}" | sed -e 's/^[[:space:]]*//')"

        new_hash="static let checksum: String = \"$hash\""
        sed -i "" "s/$old_hash/$new_hash/g" $package_file_path # -i "" on BSD, -i -e on GNU

        saved_information=", saved in $package_file_name"
    fi
fi

echo ""
echo "The XCFramework zip is saved at $xcframework_zip_path."
echo "The XCFramework zip hash is $hash$saved_information."
echo ""
echo "Please keep the zip and its hash in a safe place, as regenerating a new zip will produce a new hash."

if $dummy_package_file_created; then
    rm "$package_file_path"
fi

popd > /dev/null
