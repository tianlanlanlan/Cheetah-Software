#!/bin/bash
set -e
# set -x

GREEN='\033[0;32m'
NC='\033[0m' # No Color

echo -e "${GREEN} Starting LCM type generation...${NC}"

download_lcm() {
  cur_script_dir=$(dirname $(realpath $0))
  third_party_dir=$(realpath $cur_script_dir/../third-party)
  lcm_src_dir=$third_party_dir/lcm-1.5.0
  [ -d $lcm_src_dir ] && echo "Found lcm source directory: $lcm_src_dir" && return
  lcm_src_url=https://github.com/lcm-proj/lcm/archive/refs/tags/v1.5.0.tar.gz
  [ ! -f $third_party_dir/v1.5.0.tar.gz ] && wget $lcm_src_url -P $third_party_dir
  tar -xvf $third_party_dir/v1.5.0.tar.gz -C $third_party_dir
  echo "output/" >>$lcm_src_dir/.gitignore
}

build_lcm() {
  # Fix java source code encoding error
  sed -i "s|String spacer = \"  •  \"|String spacer = \" \\u2022 \"|g" $lcm_src_dir/lcm-java/lcm/spy/Spy.java
  sed -i "s|String spacer = \"  •  \"|String spacer = \" \\u2022 \"|g" $lcm_src_dir/lcm-java/lcm/logging/LogPlayer.java

  lcm_build_dir=$lcm_src_dir/build
  lcm_install_dir=$lcm_src_dir/output
  rm -rf $lcm_build_dir $lcm_install_dir
  cmake -S $lcm_src_dir -B $lcm_build_dir \
    -DCMAKE_INSTALL_PREFIX=$lcm_install_dir \
    -DCMAKE_BUILD_TYPE=Release
  cmake --build $lcm_build_dir -j 8
  cmake --install $lcm_build_dir
  lcm_jar_path=$lcm_install_dir/share/java/lcm.jar
  lcm_gen_bin_path=$lcm_install_dir/bin/lcm-gen
  [ ! -f $lcm_jar_path ] && echo "Not found lcm.jar file: $lcm_jar_path" && exit 1
  [ ! -f $lcm_gen_bin_path ] && echo "Not found lcm_gen file: $lcm_gen_bin_path" && exit 1
  echo "lcm_jar_path: $lcm_jar_path"
  echo "lcm_gen_bin_path: $lcm_gen_bin_path"
}

make_lcm_types() {
  echo "cur_script_dir: $cur_script_dir"
  cd $cur_script_dir/../lcm-types
  # Clean
  find . \( -name "*.jar" \
    -o -name "*.java" \
    -o -name "*.hpp" \
    -o -name "*.class" \
    -o -name "*.py" \
    -o -name "*.pyc" \
    \) | xargs rm -rf

  # Make
  $lcm_gen_bin_path -jxp *.lcm
  cp $lcm_jar_path .
  javac -cp lcm.jar */*.java
  jar cf my_types.jar */*.class
  mkdir -p java
  mv my_types.jar java
  mv lcm.jar java
  mkdir -p cpp
  mv *.hpp cpp

  mkdir -p python
  mv *.py python

  FILES=$(find . -name "*.class")
  echo ${FILES} >file_list.txt

  echo -e "${GREEN} Done with LCM type generation${NC}"
}

download_lcm
build_lcm
make_lcm_types
