const ICU_VERSION    = "63.1"
const ICU_VERSION_US = replace(ICU_VERSION, '.' => '_')

using BinaryBuilder

# Collection of sources required to build ICU
sources = [
    "http://download.icu-project.org/files/icu4c/$(ICU_VERSION)/icu4c-$(ICU_VERSION_US)-src.tgz" =>
    "05c490b69454fce5860b7e8e2821231674af0a11d7ef2febea9a32512998cb9d"
    #"9ab407ed840a00cdda7470dcc4c40299a125ad246ae4d019c4b1ede54781157fd63af015a8228cd95dbc47e4d15a0932b2c657489046a19788e5e8266eac079c"
]

# Bash recipe for building across all platforms
# (note, need to have way of converting from BinaryBuilder target names to
# ICU target names)

script = raw"""
build="x86_64-linux-gnu"
icubuild="Linux"
location="$WORKSPACE/srcdir/icu/source"
cd $location
if [[ "$target" == *"linux"* ]]
then icutarget="Linux"
elif [[ "$target" == *"apple"* ]]
then icutarget="MacOSX"
elif [[ "$target" == *"w64"* ]]
then icutarget="MinGW"
else echo "Unsupported platform" ; exit 1
fi
echo prefix = "$prefix" ; build = "$build" ; target = "$target"
echo icutarget = "$icutarget"
icuargs="--prefix=$prefix --disable-samples --disable-tests"
./runConfigureICU $icubuild $icuargs
make
if [[ "$target" != "$build" ]]
then
./runConfigureICU $icutarget $icuargs --build=$build --host=$target --with-cross-build=$location
make
fi
make install
"""

# These are the platforms we will build for by default, unless further
# platforms are passed in on the command line
platforms = [
    Linux(:x86_64, :glibc),
    Linux(:i686, :glibc),
#    Linux(:aarch64, :glibc),
#    Linux(:armv7l, :glibc),
#    Linux(:powerpc64le, :glibc),
    MacOS(:x86_64),
#    Windows(:i686),
    Windows(:x86_64)
]

# The products that we will ensure are always built
products = prefix -> [
   LibraryProduct(prefix, ["icu"], :libicu)
]

# Dependencies that must be installed before this package can be built
dependencies = [
    
]

# Build the tarballs, and possibly a `build.jl` as well.
build_tarballs(ARGS, "ICUBuilder", VersionNumber(ICU_VERSION), sources, script, platforms,
               products, dependencies)
