#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

echo "Starting direct Open Orbis build and packaging..."

export OO_TOOLCHAIN="/lib/OpenOrbisSDK"
# Add packaging tools to PATH
export PATH="$PATH:$OO_TOOLCHAIN/bin/linux"

# Move into project directory
cd petscope

# Create build directory
mkdir -p build

# 1. Compile main.c into an object file
clang --target=x86_64-pc-freebsd12-elf \
    -fPIC -funwind-tables -c \
    --sysroot="$OO_TOOLCHAIN" \
    -isystem "$OO_TOOLCHAIN/include" \
    src/main.c -o build/main.o

# 2. Link into eboot.bin executable
clang --target=x86_64-pc-freebsd12-elf \
    -fuse-ld=lld -pie --rtlib=compiler-rt \
    --sysroot="$OO_TOOLCHAIN" \
    -L"$OO_TOOLCHAIN/lib" \
    build/main.o -lkernel -lSceSystemService -lc -o eboot.bin

# 3. Create signed self binary (eboot.bin -> eboot.bin.aced)
create-fself -in eboot.bin -out eboot.bin.aced --lib "$OO_TOOLCHAIN/sce_module"

# 4. Build the final installable PS4 .pkg file using PkgTool.Core
PkgTool.Core pkg build sce_sys/param.sfo . ../petscope.pkg

echo "Build and packaging completed successfully!"
