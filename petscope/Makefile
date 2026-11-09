TITLE       := PETSCOPE
VERSION     := 1.00
TITLE_ID    := PETSCOPE1
CONTENT_ID  := IV0000-PETSCOPE1_00-0000000000000000

LIBS        := -lc -lkernel -lSceSystemService
ASSETS      := $(wildcard assets/**/*)

TOOLCHAIN   := $(OO_PS4_TOOLCHAIN)
INTDIR      := build

CFLAGS      := --target=x86_64-pc-freebsd12-elf -fPIC -funwind-tables -c -isysroot $(TOOLCHAIN) -isystem $(TOOLCHAIN)/include
LDFLAGS     := -m elf_x86_64 -pie --script $(TOOLCHAIN)/link.x --eh-frame-hdr -L$(TOOLCHAIN)/lib $(LIBS) $(TOOLCHAIN)/lib/crt1.o

CC          := clang
LD          := ld.lld

all: $(CONTENT_ID).pkg

$(CONTENT_ID).pkg: pkg.gp4
	$(TOOLCHAIN)/bin/linux/PkgTool.Core pkg_build $< .

pkg.gp4: eboot.bin sce_sys/param.sfo sce_sys/icon0.png $(ASSETS)
	$(TOOLCHAIN)/bin/linux/create-gp4 -out $@ --content-id=$(CONTENT_ID) --files "$^"

sce_sys/param.sfo: Makefile
	$(TOOLCHAIN)/bin/linux/PkgTool.Core sfo_new $@
	$(TOOLCHAIN)/bin/linux/PkgTool.Core sfo_setentry $@ APP_TYPE --type Integer --maxsize 4 --value 1
	$(TOOLCHAIN)/bin/linux/PkgTool.Core sfo_setentry $@ APP_VER --type Utf8 --maxsize 8 --value '$(VERSION)'
	$(TOOLCHAIN)/bin/linux/PkgTool.Core sfo_setentry $@ ATTRIBUTE --type Integer --maxsize 4 --value 0
	$(TOOLCHAIN)/bin/linux/PkgTool.Core sfo_setentry $@ CATEGORY --type Utf8 --maxsize 4 --value 'gd'
	$(TOOLCHAIN)/bin/linux/PkgTool.Core sfo_setentry $@ CONTENT_ID --type Utf8 --maxsize 48 --value '$(CONTENT_ID)'
	$(TOOLCHAIN)/bin/linux/PkgTool.Core sfo_setentry $@ DOWNLOAD_DATA_SIZE --type Integer --maxsize 4 --value 0
	$(TOOLCHAIN)/bin/linux/PkgTool.Core sfo_setentry $@ SYSTEM_VER --type Integer --maxsize 4 --value 0
	$(TOOLCHAIN)/bin/linux/PkgTool.Core sfo_setentry $@ TITLE --type Utf8 --maxsize 128 --value '$(TITLE)'
	$(TOOLCHAIN)/bin/linux/PkgTool.Core sfo_setentry $@ TITLE_ID --type Utf8 --maxsize 12 --value '$(TITLE_ID)'
	$(TOOLCHAIN)/bin/linux/PkgTool.Core sfo_setentry $@ VERSION --type Utf8 --maxsize 8 --value '$(VERSION)'

eboot.bin: build/main.o
	$(LD) build/main.o -o build/app.elf $(LDFLAGS)
	$(TOOLCHAIN)/bin/linux/create-fself -in=build/app.elf -out=build/app.oelf --eboot "eboot.bin" --paid 0x3800000000000011

build/main.o: main.c
	@mkdir -p build
	$(CC) $(CFLAGS) -o $@ $<

clean:
	rm -rf build eboot.bin pkg.gp4 sce_sys/param.sfo *.pkg
