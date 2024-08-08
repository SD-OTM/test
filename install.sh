#!/bin/bash

#remove lateset version of boost
sudo apt-get --purge remove libboost-dev libboost-doc  2> /dev/null 
#download boost 1.58
sudo apt-get update 
sudo apt-get install net-tools cmake -y
sudo apt-get install build-essential 
wget http://sourceforge.net/projects/boost/files/boost/1.81.0/boost_1_81_0.tar.gz
tar -xf boost_1_81_0.tar.gz

# Usage generator
echo "###############################################################"
echo "#                                                             #"
echo "#                 start Build boost                           #"
echo "#                 don't worry about warnings                 #"
echo "#                                                             #"
echo "###############################################################"

# Move into the boost directory
cd boost_1_81_0 || { echo "Directory boost_1_81_0 not found"; exit 1; }

# Build and install Boost
./bootstrap.sh --prefix=/usr/
sudo ./b2
sudo ./b2 install

# Return to the previous directory
cd ..

# Function to copy lib files
copyToLib() {
    mkdir -p ../../COMMONAPI 
    cp -d lib* ../../COMMONAPI 
    cd ../../ || exit
}

# Clone and build capicxx-core
git clone https://github.com/GENIVI/capicxx-core-runtime.git
cd capicxx-core-runtime || { echo "Directory capicxx-core-runtime not found"; exit 1; }
# Checkout a specific tag
git checkout tags/3.2.3-r7
# Define the file path and line number
file="/home/otsa/Desktop/test/capicxx-core-runtime/include/CommonAPI/Types.hpp"
line_number=18
line_to_insert='#include <string>'

# Insert the line at the specified line number
sed -i "${line_number}i ${line_to_insert}" "$file"

# Print a message indicating the line has been inserted
echo "Inserted '$line_to_insert' at line $line_number in $file"

mkdir build
cd build || { echo "Directory build not found"; exit 1; }
cmake ..
make -j 
if [ $? -ne 0 ]; then
    echo "Error in capicxx-core-runtime"
    exit 1
fi

echo "Successfully installed capicxx-core-runtime"
sleep 1
copyToLib


#capixx-someip
git clone https://github.com/GENIVI/capicxx-someip-runtime.git
cd capicxx-someip-runtime
git checkout tags/3.1.12.9
mkdir build
cd build
cmake -DUSE_INSTALLED_COMMONAPI=OFF ..
make -j
if [ $? -ne 0 ]
then
echo "Error in capicxx-someip-runtime"
exit -1
fi
copyToLib
