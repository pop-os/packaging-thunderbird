#!/usr/bin/env bash

set -e

if [ ! -d langpacks ]
then
    rm -rf langpacks.partial langpacks
    mkdir langpacks.partial

    apt-file search /usr/lib/thunderbird-addons/extensions |
    grep "^thunderbird-locale-" |
    sort |
    while read line
    do
        pkg="$(echo "$line" | cut -d':' -f1)"
        pkg_lang="$(echo "$pkg" | cut -d'-' -f3-)"
        xpi="$(echo "$line" | cut -d' ' -f2-)"
        xpi_lang="$(basename "${xpi}" | cut -d'-' -f2- | cut -d'@' -f1)"
        echo "${xpi_lang}" >> "langpacks.partial/${pkg_lang}"
    done

    mv -T langpacks.partial langpacks
fi

cp debian/control.in debian/control
rm -f debian/thunderbird-locale-*.install

ls -1 langpacks | while read pkg_lang
do
    cat >> debian/control <<EOF

Package: thunderbird-locale-${pkg_lang}
Architecture: amd64
Depends: thunderbird (= \${binary:Version})
Replaces: language-pack-${pkg_lang}-base
Description: Mozilla Firefox language pack for ${pkg_lang}
EOF

    cat "langpacks/${pkg_lang}" | while read xpi_lang
    do
        echo \
            "vendor/langpack-${xpi_lang}@thunderbird.mozilla.org.xpi" \
            "usr/lib/thunderbird/distribution/extensions" \
            >> "debian/thunderbird-locale-${pkg_lang}.install"
    done
done
