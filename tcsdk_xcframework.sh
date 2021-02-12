#!/bin/bash

# `--no-debug-symbols` option does not include dSYMs and BCSymbolMaps. Optional, default: debug symbols included.

script_dir=`cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd`

scheme_name="TCSDK"
framework_name="$scheme_name.framework"
xcframework_name="$scheme_name.xcframework"
xcframework_zip_name="$xcframework_name.zip"
package_file_name="Package.swift"

xcframework_path="$script_dir/$xcframework_name"
package_file_path="$script_dir/$package_file_name"

xcarchive_framework="Products/Library/Frameworks/$framework_name"
xcarchive_dsym="dSYMs/$framework_name.dSYM"
xcarchive_bc_symbol_maps="BCSymbolMaps"

iphoneos_archive="archives/iphoneos.xcarchive"
iphonesimulator_archive="archives/iphonesimulator.xcarchive"
appletvos_archive="archives/appletvos.xcarchive"
appletvsimulator_archive="archives/appletvsimulator.xcarchive"

absolute_dir=`cd "${@: -1}" > /dev/null; pwd`
framework_dir="$absolute_dir/TagCommander"
if [ ! -d "$framework_dir" ]; then
    echo "Please provide a correct Tag Commander local source code repository file path"
    exit 0
fi

rm -rf "$xcframework_path"
rm -rf "$xcframework_path.zip"

pushd "$framework_dir" > /dev/null

echo "Building iphoneos variant..."
xcodebuild clean archive -scheme $scheme_name -sdk iphoneos -archivePath $iphoneos_archive SKIP_INSTALL=NO BUILD_LIBRARY_FOR_DISTRIBUTION=YES &> /dev/null

echo "Building iphonesimulator variant..."
xcodebuild clean archive -scheme $scheme_name -sdk iphonesimulator -archivePath $iphonesimulator_archive SKIP_INSTALL=NO BUILD_LIBRARY_FOR_DISTRIBUTION=YES &> /dev/null

echo "Building appletvos variant..."
xcodebuild clean archive -scheme $scheme_name -sdk appletvos -archivePath $appletvos_archive SKIP_INSTALL=NO BUILD_LIBRARY_FOR_DISTRIBUTION=YES &> /dev/null

echo "Building appletvsimulator variant..."
xcodebuild clean archive -scheme $scheme_name -sdk appletvsimulator -archivePath $appletvsimulator_archive SKIP_INSTALL=NO BUILD_LIBRARY_FOR_DISTRIBUTION=YES &> /dev/null

if [ "$1" == "--no-debug-symbols" ]; then
    echo "Packaging XCFramework without debug symbols..."
else
    echo "Packaging XCFramework with debug symbols..."

    # We must only package bcsymbolmaps matching the dSYM for each architecture. The unique identifiers of these symbol maps
    # are generated from the dSYM using the dwarfdump command, providing a way to find the right ones. For more information
    # see https://instabug.com/blog/ios-binary-framework/. This article also recommends running dsymutil again to ensure reports 
    # are as much symbolicated as possible.

    iphoneos_dsym="$framework_dir/$iphoneos_archive/$xcarchive_dsym"
    iphoneos_debug_symbols_opts=( -debug-symbols "$iphoneos_dsym" )
    iphoneos_bcsymbolmap_uuids=$(dwarfdump --uuid "$iphoneos_dsym" | cut -d ' ' -f2)
    for bc_symbol_map in `find "$iphoneos_archive/$xcarchive_bc_symbol_maps" -type f -name "*.bcsymbolmap"`; do
        for uuid in $iphoneos_bcsymbolmap_uuids; do
            if [ "$(basename "$bc_symbol_map" ".bcsymbolmap")" == "$uuid" ]; then
                dsymutil --symbol-map "$bc_symbol_map" "$iphoneos_dsym"
                iphoneos_debug_symbols_opts+=( -debug-symbols "$framework_dir/$bc_symbol_map" )
            fi
        done
    done

    iphonesimulator_debug_symbols_opts=( -debug-symbols "$framework_dir/$iphonesimulator_archive/$xcarchive_dsym" )

    appletvos_dsym="$framework_dir/$appletvos_archive/$xcarchive_dsym"
    appletvos_debug_symbols_opts=( -debug-symbols "$appletvos_dsym" )
    appletvos_bcsymbolmap_uuids=$(dwarfdump --uuid "$appletvos_dsym" | cut -d ' ' -f2)
    for bc_symbol_map in `find "$appletvos_archive/$xcarchive_bc_symbol_maps" -type f -name "*.bcsymbolmap"`; do
        for uuid in $appletvos_bcsymbolmap_uuids; do
            if [ "$(basename "$bc_symbol_map" ".bcsymbolmap")" == "$uuid" ]; then
                dsymutil --symbol-map "$bc_symbol_map" "$appletvos_dsym"
                appletvos_debug_symbols_opts+=( -debug-symbols "$framework_dir/$bc_symbol_map" )
            fi
        done
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

pushd "$script_dir" > /dev/null

zip -r "$xcframework_zip_name" "$xcframework_name" > /dev/null
rm -rf "$xcframework_name"

xcframework_zip_path="$script_dir/$xcframework_zip_name"
if [ ! -f "$xcframework_zip_path" ]; then
    echo "XCFramework creation failed."
    exit 1
fi

# Currently a Package.swift file must be found for the swift package command to succeed
dummy_package_file_created=false
if [ ! -f "$package_file_path" ]; then
    touch "$package_file_path"
    dummy_package_file_created=true
fi

hash=`swift package compute-checksum "$xcframework_zip_name"`

if ! $dummy_package_file_created; then
    old_hash=$(grep 'checksum: String =' $package_file_path)
    old_hash="$(echo -e "${old_hash}" | sed -e 's/^[[:space:]]*//')"

    new_hash="static let checksum: String = \"$hash\""
    sed -i "" "s/$old_hash/$new_hash/g" $package_file_path # -i "" on BSD, -i -e on GNU

    saved_information=", saved in $package_file_name"
fi

echo ""
echo "The XCFramework zip is saved at $xcframework_zip_path."
echo "The XCFramework zip hash is $hash$saved_information."
echo ""
echo "Please keep the zip and its hash in a safe place, as regenerating a new zip will produce a new hash."
echo "The Package.swift file was automatically updated with the new hash, please manually commit the changes."

if $dummy_package_file_created; then
    rm "$package_file_path"
fi

popd > /dev/null
