#!/bin/bash

cleanup() 
{
    popd > /dev/null 2>&1
    rm -fr build.$$
}

make -C src

trap cleanup EXIT

mkdir -p build.$$
pushd build.$$ > /dev/null 2>&1
cp -pr ../meta/* .

mkdir -p usr/share/xupnpd usr/bin
cp -pr ../src/*.lua ../src/{playlists,plugins,profiles,ui,www} usr/share/xupnpd/
cp -p ../src/xupnpd-linux usr/bin/xupnpd

tar -czf control.tar.gz $(ls control conffiles pre* post* 2> /dev/null)
tar -czf data.tar.gz ./etc ./usr
echo "2.0" > debian-binary

version=$(grep Version: control | sed -e 's/.*: *//')
package=$(grep Package: control | sed -e 's/.*: *//')
arch=$(grep Architecture: control | sed -e 's/.*: *//')

ipk=${package}_${version}_${arch}.ipk

ar r ../dist/$ipk debian-binary control.tar.gz data.tar.gz
