#!/bin/bash
set -e

GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Change this path
lcm_jar_path=~/Downloads/lcm/build/lcm-java/lcm.jar
[ ! -f $lcm_jar_path ] && echo "Not found lcm.jar file!" && exit 1

echo -e "${GREEN} Starting LCM type generation...${NC}"

cd ../lcm-types
# Clean
find . \( -name "*.jar" \
  -o -name "*.java" \
  -o -name "*.hpp" \
  -o -name "*.class" \
  -o -name "*.py" \
  -o -name "*.pyc" \
  \) | xargs rm -rf

# Make
./lcm-gen -jxp *.lcm
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
