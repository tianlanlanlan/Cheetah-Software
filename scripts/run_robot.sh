#!/bin/sh
set -e

repo_root=$(pwd)
cd $repo_root/build
. ./conan/conanrun.sh
./user/MIT_Controller/mit_ctrl m s
