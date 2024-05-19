#!/bin/sh
set -e

save_core_dump=0
repo_root=$(pwd)
if [ $save_core_dump = 1 ]; then
  ulimit -S -c unlimited
  sudo sysctl -w kernel.core_pattern="$repo_root/core_%e.%p"
fi

cd $repo_root/build
. ./conan/conanrun.sh
./user/MIT_Controller/mit_ctrl m s
