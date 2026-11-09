#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

echo "Starting direct Open Orbis build and packaging..."

export OO_TOOLCHAIN="/lib/OpenOrbisSDK"

# Locate packaging binaries dynamically
CREATE_FSELF=$(find "$OO_TOOLCHAIN" -name "create-fself" -print -quit)
PKG_TOOL=$(find "$OO_TOOLCHAIN" -name "PkgTool.Core" -print -quit)

echo "Found create-fself at: $CREATE_FSELF"
echo "Found PkgTool.Core at: $PKG_TOOL"

# Move into project directory
cd petscope

# Create build directory safely
mkdir -p build

# Compile and link directly
clang --target=x86_64-pc-freebsd12-elf \
    -fPIC -pie -nostdlib \
    --sysroot="$OO_TOOLCHAIN" \
    -isystem "$OO_TOOLCHAIN/include" \
    -L"$OO_TOOLCHAIN/lib" \
    "$OO_TOOLCHAIN/lib/crt1.o" \
    src/main.c \
    -lc -lkernel -lSceSystemService \
    "$OO_TOOLCHAIN/lib/crtn.o" \
    -o eboot.bin

# 2. Create signed self binary
"$CREATE_FSELF" -in eboot.bin -out eboot.bin.aced --lib "$OO_TOOLCHAIN/sce_module"

# 3. Build final PS4 .pkg file
if [[ "$PKG_TOOL" == *.dll ]]; then
    dotnet "$PKG_TOOL" pkg build sce_sys/param.sfo . ../petscope.pkg
else
    "$PKG_TOOL" pkg build sce_sys/param.sfo . ../petscope.pkg
fi

echo "Build and packaging completed successfully!"
