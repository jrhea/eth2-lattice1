# mips
ETH_CFLAGS=-DBLS_ETH -DBLS_SWAP_G
MIPS_TOOLCHAIN_ROOT=/root/source
MIPS_LIB_DIR=/root/work/bls-eth-go-binary/bls/lib/linux/mips
MIPS_TOOLCHAIN_CXX=$(MIPS_TOOLCHAIN_ROOT)/staging_dir/toolchain-mipsel_24kc_gcc-7.3.0_musl/bin/mipsel-openwrt-linux-g++
MIPS_TOOLCHAIN_CC=$(MIPS_TOOLCHAIN_ROOT)/staging_dir/toolchain-mipsel_24kc_gcc-7.3.0_musl/bin/mipsel-openwrt-linux-gcc
MIPS_TOOLCHAIN_AR=$(MIPS_TOOLCHAIN_ROOT)/staging_dir/toolchain-mipsel_24kc_gcc-7.3.0_musl/bin/mipsel-openwrt-linux-ar
MIPS_TOOLCHAIN_CFLAGS=-Os -pipe -mno-branch-likely -mips32r2 -mtune=24kc -fno-caller-saves -fno-plt -fhonour-copts -Wno-error=unused-but-set-variable -Wno-error=unused-result -msoft-float -mips16 -minterlink-mips16 -Wformat -Werror=format-security -fstack-protector -Wl,-z,now -Wl,-z,relro
MIPS_HERUMI_CFLAGS=-std=c++03 -O3 -fPIC -DNDEBUG -DMCL_DONT_USE_OPENSSL -DMCL_LLVM_BMI2=0 -DMCL_USE_LLVM=1 -DMCL_USE_VINT -DMCL_SIZEOF_UNIT=4 -DMCL_VINT_FIXED_BUFFER -DMCL_MAX_BIT_SIZE=384 -DCYBOZU_DONT_USE_EXCEPTION -DCYBOZU_DONT_USE_STRING -D_FORTIFY_SOURCE=0 $(ETH_CFLAGS)  $(CFLAGS_USER)
MIPS_TOOLCHAIN_INCLUDES=-I$(MIPS_TOOLCHAIN_ROOT)/staging_dir/toolchain-mipsel_24kc_gcc-7.3.0_musl/usr/include -I$(MIPS_TOOLCHAIN_ROOT)/staging_dir/toolchain-mipsel_24kc_gcc-7.3.0_musl/include -I$(MIPS_TOOLCHAIN_ROOT)/staging_dir/target-mipsel_24kc_musl/usr/include -I$(MIPS_TOOLCHAIN_ROOT)/staging_dir/target-mipsel_24kc_musl/include -I$(MIPS_TOOLCHAIN_ROOT)/build_dir/target-mipsel_24kc_musl/gmp-6.1.2
MIPS_HERUMI_INCLUDES=-I../cybozulib/include -I../bls/include -I../mcl/include
MIPS_TARGET_TRIPLE=$$($(MIPS_TOOLCHAIN_CXX) -dumpmachine)

all: bls validator

validator:
        $(eval export STAGING_DIR=$(MIPS_TOOLCHAIN_ROOT)/staging_dir)
        $(eval export CC=$(MIPS_TOOLCHAIN_CC))
        env CGO_LDFLAGS="-s -L$(MIPS_LIB_DIR)" \
        CGO_LDLIBS="-lbls384_256" \
        CGO_CXXFLAGS="$(MIPS_HERUMI_CFLAGS) $(MIPS_TOOLCHAIN_CFLAGS)" \
        GOOS=linux \
        GOARCH=mipsle \
        GOMIPS=softfloat \
        CGO_ENABLED=1 \
        CXX_FOR_TARGET="$(MIPS_TOOLCHAIN_CXX)" \
        CC_FOR_TARGET="$(MIPS_TOOLCHAIN_CC)" \
        go build

bls: 
        cd /root/work/bls-eth-go-binary && make CXX=clang++-10 mips_all

.PHONY: validator
~                        