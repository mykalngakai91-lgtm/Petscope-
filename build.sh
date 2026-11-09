#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

echo "Starting direct Open Orbis build..."

# Set toolchain paths
export OO_TOOLCHAIN="/lib/OpenOrbisSDK"
export PATH="$OO_TOOLCHAIN/bin/linux:$PATH"

# Move into your project source directory
cd petscope

# 1. Compile main.c into an object file
x86_64-pc-freebsd12-elf-clang --target=x86_64-pc-freebsd12-elf \
    -fPIC -funwind-tables -c \
    -isysroot "$OO_TOOLCHAIN" \
    -isystem "$OO_TOOLCHAIN/include" \
    src/main.c -o main.o

# 2. Link into eboot.bin executable
x86_64-pc-freebsd12-elf-clang --target=x86_64-pc-freebsd12-elf \
    -fuse-ld=lld -pie --rtlib=compiler-rt \
    -isysroot "$OO_TOOLCHAIN" \
    -L"$OO_TOOLCHAIN/lib" \
    main.o -lkernel -lSceSystemService -lc -o eboot.bin

echo "Build finished successfully!"
cp eboot.bin ../
