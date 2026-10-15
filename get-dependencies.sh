#!/bin/sh

set -eu

ARCH=$(uname -m)

echo "Installing package dependencies..."
echo "---------------------------------------------------------------"
pacman -Syu --noconfirm \
	appstream          \
	blueprint-compiler \
	dconf              \
	gdk-pixbuf2        \
	graphene           \
	gtk4               \
	gtksourceview5     \
	hicolor-icon-theme \
	libadwaita         \
	libportal          \
	libsoup3           \
	meson              \
	pango              \
	python             \
	python-cairo       \
	python-gobject     \
	python-pillow      \
	python-pytesseract \
	tesseract          \
	webp-pixbuf-loader

echo "Installing debloated packages..."
echo "---------------------------------------------------------------"
get-debloated-pkgs --add-common --prefer-nano

echo "Building Gradia from source..."
echo "---------------------------------------------------------------"
git clone https://github.com/AlexanderVanhee/Gradia ./Gradia && (
	cd ./Gradia

	git fetch --tags origin
	TAG=$(git tag --sort=-v:refname | grep -vi 'rc\|alpha\|beta\|nightly' | head -1)
	git checkout "$TAG"
	echo "${TAG#v}" > ~/version

	# Keep the gradient library relocatable, resolve the OCR paths inside
	# the AppImage and fix the rotation buttons direction
	git apply ../patches/*.patch

	meson setup build --prefix=/usr --buildtype=release
	meson compile -C build
	meson install -C build
)
