#!/bin/sh
# Trivial release helper for winetricks
#
# Usage: $0 optional_version_name
#
# Copyright:
#   Copyright (C) 2016 Austin English
#
# SPDX-License-Identifier: LGPL-2.1+

set -e
set -u
set -x

# Make sure we're at top level:
if [ ! -f Makefile ] ; then
    echo "Please run this from the top of the source tree"
    exit 1
fi

version="${1:-$(date +%Y%m%d)}"

if git tag | grep -w "${version}" ; then
    echo "A tag for ${version} already exists!"
    exit 1
fi

# update version in winetricks itself
sed -i -e "s%WINETRICKS_VERSION=.*%WINETRICKS_VERSION=${version}%" src/winetricks

# update manpage
line=".TH WINETRICKS 1 \"$(date +"%B %Y")\" \"Winetricks ${version}\" \"Wine Package Manager\""
sed -i -e "s%\\.TH.*%${line}%" src/winetricks.1

# update LATEST (version) file
echo "${version}" > files/LATEST

git commit files/LATEST src/winetricks src/winetricks.1 -m "version bump - ${version}"
git tag -s -m "winetricks-${version}" "${version}"

git push
git push --tags


# create local tarball, identical to github's generated one
git archive --prefix="winetricks-${version}/" -o "../${version}.tar.gz" "${version}"

# create a detached signature of the tarball
gpg --armor --default-key 0xA041937B --detach-sign "../${version}.tar.gz"

# upload the detached signature to github:
python3 src/github-api-releases.py  ../../"${version}.tar.gz.asc" Winetricks winetricks "${version}"

exit 0
