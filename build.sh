#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

echo "Starting direct Open Orbis build..."

export OO_TOOLCHAIN="/lib/OpenOrbisSDK"

# Move into project directory
cd petscope

# 1. Compile main.c using standard clang from the system with Open Orbis sysroot
clang --target=x86_64-pc-freebsd12-elf \
    -fPIC -funwind-tables -c \
    --sysroot="$OO_TOOLCHAIN" \
    -isystem "$OO_TOOLCHAIN/include" \
    src/main.c -o main.o

# 2. Link into eboot.bin executable
clang --target=x86_64-pc-freebsd12-elf \
    -fuse-ld=lld -pie --rtlib=compiler-rt \
    --sysroot="$OO_TOOLCHAIN" \
    -L"$OO_TOOLCHAIN/lib" \
    main.o -lkernel -lSceSystemService -lc -o eboot.bin

echo "Build finished successfully!"
cp eboot.bin ../
