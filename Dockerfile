FROM onion/omega2-source

RUN apt-get update \
&& apt-get install -y git wget subversion build-essential libncurses5-dev zlib1g-dev gawk flex quilt git-core unzip libssl-dev python-dev python-pip libxml-parser-perl

# Update the toolchain
RUN cd /root/source \
&& ./scripts/feeds update onion \
&& git pull 
COPY resources/.config /root/source/.config
# Build the toolchain
RUN sh scripts/onion-minimal-build.sh \
&& make -j8

# Add Clang package dependencies
RUN apt-get install -y lsb-release software-properties-common 

# Add Clang sources
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 15CF4D18AF4F7421 \
&& add-apt-repository 'deb http://apt.llvm.org/bionic/ llvm-toolchain-bionic main' \
&& add-apt-repository 'deb http://apt.llvm.org/bionic/ llvm-toolchain-bionic-9 main' \
&& add-apt-repository 'deb http://apt.llvm.org/bionic/ llvm-toolchain-bionic-10 main' \
&& apt-get update

# Install Clang
RUN bash -c "$(wget -O - https://apt.llvm.org/llvm.sh)" \
&& apt-get install -y clang-format clang-tidy clang clangd libc++-dev libc++1 libc++abi-dev libc++abi1 libclang-dev libclang1 libllvm-ocaml-dev libomp-dev libomp5 lld lldb llvm-dev llvm-runtime llvm

# Install Go
ENV GOROOT /usr/local/go
ENV GOPATH /root/go
ENV PATH $GOPATH/bin:$GOROOT/bin:$PATH

RUN cd /tmp \
&& wget https://dl.google.com/go/go1.14.4.linux-amd64.tar.gz \
&& tar -xvf go1.14.4.linux-amd64.tar.gz \
&& mv go /usr/local

# Herumi build setup
RUN apt-get install -y libgmp-dev gcc-multilib \
&& mkdir /root/work \
&& cd /root/work \
&& git clone https://github.com/herumi/mcl \
&& git clone https://github.com/herumi/bls \
&& git clone https://github.com/herumi/bls-eth-go-binary \
&& git clone https://github.com/herumi/cybozulib.git

ENV PATH /root/source/staging_dir/toolchain-mipsel_24kc_gcc-7.3.0_musl/bin/:/root/source/staging_dir/toolchain-mipsel_24kc_gcc-7.3.0_musl/bin/:$PATH

# Cross Compile Herumi
RUN cd /root/work/bls-eth-go-binary \
&& make ../mcl/src/base32.ll \
&& env CXX=clang++-10 BIT=32 ARCH=mipsel _OS=linux _ARCH=mipsle make MCL_USE_GMP=0 UNIT=4 CFLAGS_USER="-target mipsel-linux -fPIC"

# Clone Prysm
RUN cd /root/work \
&& git clone https://github.com/prysmaticlabs/prysm.git

# Copy ridiculous patch
COPY resources/0001-these-changes-were-a-30-sec-hack-made-to-get-the-val.patch /root/work/prysm/0001-these-changes-were-a-30-sec-hack-made-to-get-the-val.patch

# Apply ridiculous patch
RUN cd /root/work/prysm \
&& git apply /root/work/prysm/0001-these-changes-were-a-30-sec-hack-made-to-get-the-val.patch

# Cross Compile Prysm Validator
RUN cd /root/work/prysm/validator \
&& env CC=mipsel-openwrt-linux-gcc CGO_ENABLED=1 GOOS=linux GOARCH=mipsle GOMIPS=softfloat CGO_LDFLAGS="-s -L/root/work/bls-eth-go-binary/bls/lib/linux/mipsle" CGO_LDLIBS="-lbls384_256" go build






