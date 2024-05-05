#!/bin/bash
set -e

GREEN='\033[0;32m'
NC='\033[0m' # No Color

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
./lcm-gen -xp *.lcm
mkdir -p cpp
mv *.hpp cpp

mkdir -p python
mv *.py python

FILES=$(find . -name "*.class")
echo ${FILES} >file_list.txt

echo -e "${GREEN} Done with LCM type generation${NC}"
