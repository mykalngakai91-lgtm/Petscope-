#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

echo "Starting Open Orbis build..."

# Set toolchain path
export OO_TOOLCHAIN="/lib/OpenOrbisSDK"
export PATH="$OO_TOOLCHAIN/bin/linux:$PATH"

# Move into project directory
cd petscope

# Compile main.c into an object file using the SDK sysroot
x86_64-pc-freebsd12-elf-clang --target=x86_64-pc-freebsd12-elf \
    -fPIC -funwind-tables -c \
    -isysroot "$OO_TOOLCHAIN" \
    -isystem "$OO_TOOLCHAIN/include" \
    src/main.c -o main.o

# Link object file into an ELF executable
x86_64-pc-freebsd12-elf-clang --target=x86_64-pc-freebsd12-elf \
    -fuse-ld=lld -pie --rtlib=compiler-rt \
    -isysroot "$OO_TOOLCHAIN" \
    -L"$OO_TOOLCHAIN/lib" \
    main.o -lkernel -lSceSystemService -lc -o eboot.bin

echo "Build complete successfully!"
cp eboot.bin ../

