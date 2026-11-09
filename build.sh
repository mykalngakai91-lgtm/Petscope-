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

# 1. Compile main.c into an object file
clang --target=x86_64-pc-freebsd12-elf \
    -fPIC -funwind-tables -c \
    --sysroot="$OO_TOOLCHAIN" \
    -isystem "$OO_TOOLCHAIN/include" \
    src/main.c -o build/main.o

# 2. Link into eboot.bin using SDK sysroot and library paths
clang --target=x86_64-pc-freebsd12-elf \
    -fuse-ld=lld -pie \
    --sysroot="$OO_TOOLCHAIN" \
    -L"$OO_TOOLCHAIN/lib" \
    build/main.o \
    -lkernel -lSceSystemService -lc \
    -o eboot.bin

# 3. Create signed self binary using the dynamically found path
"$CREATE_FSELF" -in eboot.bin -out eboot.bin.aced --lib "$OO_TOOLCHAIN/sce_module"

# 4. Build final PS4 .pkg file
if [[ "$PKG_TOOL" == *.dll ]]; then
    dotnet "$PKG_TOOL" pkg build sce_sys/param.sfo . ../petscope.pkg
else
    "$PKG_TOOL" pkg build sce_sys/param.sfo . ../petscope.pkg
fi

echo "Build and packaging completed successfully!"
