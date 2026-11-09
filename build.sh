#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

echo "Starting direct Open Orbis build and packaging..."

export OO_TOOLCHAIN="/lib/OpenOrbisSDK"
export PATH="$PATH:$OO_TOOLCHAIN/bin/linux"

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

# 2. Link into eboot.bin using explicit SDK startup objects and libraries
clang --target=x86_64-pc-freebsd12-elf \
    -fuse-ld=lld -pie \
    --sysroot="$OO_TOOLCHAIN" \
    -B"$OO_TOOLCHAIN/lib" \
    -L"$OO_TOOLCHAIN/lib" \
    build/main.o \
    "$OO_TOOLCHAIN/lib/crt1.o" \
    "$OO_TOOLCHAIN/lib/crti.o" \
    "$OO_TOOLCHAIN/lib/crtbeginS.o" \
    -lkernel -lSceSystemService -lc \
    "$OO_TOOLCHAIN/lib/crtendS.o" \
    "$OO_TOOLCHAIN/lib/crtn.o" \
    -o eboot.bin

# 3. Create signed self binary
create-fself -in eboot.bin -out eboot.bin.aced --lib "$OO_TOOLCHAIN/sce_module"

# 4. Build final PS4 .pkg file
PkgTool.Core pkg build sce_sys/param.sfo . ../petscope.pkg

echo "Build and packaging completed successfully!"
