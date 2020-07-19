# Eth2 Validator on Lattice 1

Docker setup notes:

```
docker pull onion/omega2-source
docker run -it onion/omega2-source /bin/bash
apt-get update && apt-get install -y git wget subversion build-essential libncurses5-dev zlib1g-dev gawk flex quilt git-core unzip libssl-dev python-dev python-pip libxml-parser-perl
make menuconfig
```

In the menu that appears, you will need to do the following:
* For Target System, select MediaTek Ralink MIPS
* For Subtarget, select MT7688 based boards
* For Target Profile, select Multiple Devices
* A new item will appear on the Main menu, Target Devices
* For Target Devices, select Onion Omega2 and Onion Omega2+
* Exit and save your configuration

```
./scripts/feeds update onion
git pull
sh scripts/onion-minimal-build.sh
make -j8
```

**Clang**

/etc/apt/sources.list
```
# i386 not available
deb http://apt.llvm.org/bionic/ llvm-toolchain-bionic main
deb-src http://apt.llvm.org/bionic/ llvm-toolchain-bionic main
# 9
deb http://apt.llvm.org/bionic/ llvm-toolchain-bionic-9 main
deb-src http://apt.llvm.org/bionic/ llvm-toolchain-bionic-9 main
# 10
deb http://apt.llvm.org/bionic/ llvm-toolchain-bionic-10 main
deb-src http://apt.llvm.org/bionic/ llvm-toolchain-bionic-10 main
```
```
apt-get install lsb-release software-properties-common
bash -c "$(wget -O - https://apt.llvm.org/llvm.sh)"
apt-get install clang-format clang-tidy clang-tools clang clangd libc++-dev libc++1 libc++abi-dev libc++abi1 libclang-dev libclang1 liblldb-dev libllvm-ocaml-dev libomp-dev libomp5 lld lldb llvm-dev llvm-runtime llvm python-clang
```
**Go**

```
cd /tmp
wget https://dl.google.com/go/go1.14.4.linux-amd64.tar.gz
tar -xvf go1.14.4.linux-amd64.tar.gz
mv go /usr/local
export GOROOT=/usr/local/go
export GOPATH=$HOME/go
export PATH=$GOPATH/bin:$GOROOT/bin:$PATH
```

**Herumi**

 ```
mkdir work
cd work
apt-get install libgmp-dev
git clone https://github.com/herumi/mcl
git clone https://github.com/herumi/bls
# lattice-validator branch
git clone https://github.com/herumi/bls-eth-go-binary 
git clone https://github.com/herumi/cybozulib.git
cd bls-eth-go-binary
make CXX=clang++-10 mips_all
```

**Prsym**

```
git clone https://github.com/prysmaticlabs/prysm.git
cd prysm/validator
make all
```

Note: I also added an entry to go.mod to force Prysm to look at the right herumi library.  I don't think it worked

```
go mod edit -replace github.com/herumi/bls-eth-go-binary/bls=/root/work/bls-eth-go-binary
```

**Hacks**

1)

if you get this error

```
# github.com/herumi/bls-eth-go-binary/bls
/tmp/go-build084989476/b514/_x004.o: In function `_cgo_861568203c2d_Cfunc_mclBn_setOriginalG2cofactor':
/tmp/go-build/cgo-gcc-prolog:2323: undefined reference to `mclBn_setOriginalG2cofactor'
/tmp/go-build/cgo-gcc-prolog:2323: undefined reference to `mclBn_setOriginalG2cofactor'
collect2: error: ld returned 1 exit status
Makefile:17: recipe for target 'validator' failed
```

then you need to figure out what source still has this call to an undefined method.  I suggest:

```
grep -R "setOriginalG2cofactor" /root/
```

I tried `go clean -cache` but ended up having to change the file:

```
vi /root/go/pkg/mod/github.com/herumi/bls-eth-go-binary@v0.0.0-20200522010937-01d282b5380b/bls/mcl.go
```

and remove the call specifically.


