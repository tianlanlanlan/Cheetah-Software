#!/bin/sh
set -e

repo_root_dir=$(pwd)
build_type=Debug

check_conan() {
  conan_minimum_version="2.0.6"
  [ -z $(command -v conan) ] && echo "conan not installed, run: 'pip install conan'" && exit 1
  conan_current_version=$(conan --version | grep -o '[0-9.]*')
  version=$(printf "$conan_minimum_version\n$conan_current_version\n" | sort -V | head -n 1)
  if [ "$version" != "$conan_minimum_version" ]; then
    printf "require conan >= $conan_minimum_version, current: $conan_current_version\n"
    printf "run: 'pip install conan --upgrade'\n"
    exit 1
  fi
  conan profile show >/dev/null 2>&1 || conan profile detect
}

build() {
  # build lcm types
  lcm_check_file=$repo_root_dir/lcm-types/file_list.txt
  [ ! -f $lcm_check_file ] && (bash scripts/make_types.sh || (echo "Failed to build lcm types" && exit 1))

  build_dir=$repo_root_dir/build
  [ ! -d $build_dir ] && rebuild=1 || rebuild=0
  [ $# = 1 ] && rebuild=$1
  if [ $rebuild = 1 ]; then
    rm -rf $build_dir
    conan install conanfile.py \
      --output-folder $build_dir \
      --profile:host default \
      --build missing \
      --options *:shared=True \
      --options icu/*:shared=False \
      --settings build_type=Release \
      --settings compiler.cppstd=gnu17 \
      --settings Cheetah/*:build_type=$build_type \
      -c tools.system.package_manager:mode=install \
      -c tools.system.package_manager:sudo=True

    . $build_dir/conan/conanbuild.sh
    cmake -S . -B $build_dir \
      -DCMAKE_BUILD_TYPE=$build_type \
      -DENABLE_ASAN=OFF \
      -DCMAKE_TOOLCHAIN_FILE=$build_dir/conan/conan_toolchain.cmake
  fi
  . $build_dir/conan/conanbuild.sh
  cmake --build $build_dir -j
}

check_conan
build "$@"
