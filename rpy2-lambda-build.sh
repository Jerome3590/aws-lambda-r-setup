#!/bin/bash

#Notes:
#us-east-1: ami-02354e95b39ca8dec amzn2-ami-hvm-2.0.20200722.0-x86_64-gp2

# Install Python 3.8
sudo amazon-linux-extras enable python3.8
sudo yum -y install python38


# Install R Dependencies Global
yum -y install java-1.8.0-openjdk-devel
yum -y install libcurl-devel
yum install -q -y wget \
    awscli \
    readline-devel \
    xorg-x11-server-devel libX11-devel libXt-devel \
    gcc-c++ gcc-gfortran \
    zlib-devel bzip2 bzip2-libs \
    java-1.8.0-openjdk-devel \
    openssl-devel libxml2-devel
    
export PATH="$PATH:/opt/R/lib64/R:/opt/R/bin/R:/opt/bin:/opt/lib:/opt/R/bin"
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/opt/lib"
export LIBRARY_PATH="$LD_LIBRARY_PATH:/opt/lib"
export LD_RUN_PATH="$LD_RUN_PATH:/opt/lib"
export C_INCLUDE_PATH="$C_INCLUDE_PATH:/usr/include/python2.7:/opt/include"
export CPLUS_INCLUDE_PATH="$CPLUS_INCLUDE_PATH:/usr/include/python2.7:/opt/include"
export CPATH="$CPATH:/usr/include/python2.7:/opt/include"
export LDFLAGS="-I/opt/lib"

# Edit .bashrc file to include above environmental variables
# nano .bashrc
# export PATH="$PATH:/opt/R/lib64/R:/opt/R/bin/R:/opt/bin:/opt/lib:/opt/R/bin"
# export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/opt/lib"
# export LIBRARY_PATH="$LD_LIBRARY_PATH:/opt/lib"
# export LD_RUN_PATH="$LD_RUN_PATH:/opt/lib"
# export C_INCLUDE_PATH="$C_INCLUDE_PATH:/usr/include/python2.7:/opt/include"
# export CPLUS_INCLUDE_PATH="$CPLUS_INCLUDE_PATH:/usr/include/python2.7:/opt/include"
# export CPATH="$CPATH:/usr/include/python2.7:/opt/include"
# export LDFLAGS="-I/opt/lib"

source /home/ec2-user/.bashrc

mkdir ~/build
cd ~/build

# Install R Dependencies Local
# openssl
wget https://www.openssl.org/source/openssl-1.1.1g.tar.gz
tar -zxvf openssl-1.1.1g.tar.gz
cd openssl-1.1.1g
./config --prefix=/opt shared
make
sudo make install
cd ..


# curl
wget https://curl.haxx.se/download/curl-7.72.0.tar.gz
tar -zxvf curl-7.72.0.tar.gz
cd curl-7.72.0
./configure --prefix=/opt --with-ssl
make
sudo make install
cd ..

# bzip2
wget -O bzip2-latest.tar.gz https://www.sourceware.org/pub/bzip2/bzip2-latest.tar.gz
tar -zxvf bzip2-latest.tar.gz
cd bzip2-1.0.8
make -f Makefile-libbz2_so
sudo make install PREFIX=/opt
cd ..

# xz
wget https://tukaani.org/xz/xz-5.2.5.tar.gz
tar -zxvf xz-5.2.5.tar.gz
cd xz-5.2.5
./configure --prefix=/opt
make
sudo make install
cd ..

# pcre
wget https://ftp.pcre.org/pub/pcre/pcre2-10.35.tar.gz
tar -zxvf pcre2-10.35.tar.gz
cd pcre2-10.35
./configure --prefix=/opt --enable-utf8 --enable-unicode-properties
make
sudo make install
cd ..

# libxml2
wget http://xmlsoft.org/sources/libxml2-2.9.10.tar.gz
tar -zxvf libxml2-2.9.10.tar.gz
cd libxml2-2.9.10
./configure --prefix=/opt
make
sudo make install
cd ..

# sql-lite-devel
wget https://sqlite.org/2020/sqlite-autoconf-3330000.tar.gz
tar xvfz sqlite-autoconf-3330000.tar.gz
cd sqlite-autoconf-3330000
./configure --prefix=/opt
make
make install
cd ..


# R Libraries
cp /usr/lib64/libgfortran.so.4 /opt/lib
cp /usr/lib64/libquadmath.so.0 /opt/lib
cp /usr/lib64/ld-linux-x86-64.so.2 /opt/lib
cp /usr/lib64/libc.so.6 /opt/lib
cp /usr/lib64/libstdc++.so.6.0.24 /opt/lib
cp /usr/lib64/libgomp.so.1 /opt/lib
cp /usr/lib64/libpthread-2.26.so /opt/lib
cp /usr/lib64/libpcre2-8.so.0 /opt/lib
cp /opt/R/lib64/R/lib/libR.so  /opt/lib
cp /opt/R/lib64/R/lib/libRlapack.so /opt/lib


R_VERSION=4.0.2

wget https://cran.r-project.org/src/base/R-4/R-${R_VERSION}.tar.gz && \
tar -zxvf R-${R_VERSION}.tar.gz && \
cd R-${R_VERSION}
./configure --prefix=/opt/R --enable-R-shlib --without-recommended-packages --with-x=no --with-aqua=no \
    --with-tcltk=no --with-ICU=no --disable-openmp --disable-nls --disable-largefile \
    --disable-R-profiling --disable-BLAS-shlib --with-libpng=no --with-jpeglib=no --with-libtiff=no
make
sudo make install
cd ..


# Prune not needed files
sudo -s
cd /opt
rm -rf /opt/R/lib64/R/library/tcltk
mv /opt/R/lib64/R/library/translations/en* /opt/R/lib64/R/library/
mv /opt/R/lib64/R/library/translations/DESCRIPTION /opt/R/lib64/R/library/
rm -rf /opt/R/lib64/R/library/translations/*
mv /opt/R/lib64/R/library/en* /opt/R/lib64/R/library/translations/
mv /opt/R/lib64/R/library/DESCRIPTION /opt/R/lib64/R/library/translations/
## Removing previously copied R libraries for space saving
rm /opt/R/lib64/R/lib/libR.so  
rm /opt/R/lib64/R/lib/libRlapack.so


# Libraries for additional Lambda builds/Future Step Functions
sudo -s
mkdir -p /opt/base-library/lib/R/site-library
sudo /opt/R/bin/R
install.packages(c("httr", "aws.signature", "logging","jsonlite", "aws.s3", "data.table", "readxl", "purrr", "tidyr", "lubridate", "RcppRoll", "dplyr", "magrittr", "tidyverse", "BiocManager"), repos="http://cran.r-project.org", lib="/opt/base-library/lib/R/site-library", configure.vars="INCLUDE_DIR=/opt/lib LIB_DIR=/opt/lib")
q()

sudo -s
mkdir -p /opt/data-viz/lib/R/site-library
sudo /opt/R/bin/R
install.packages(c("shiny", "ggplot2", "gtable", "kableExtra"), repos="http://cran.r-project.org", lib="/opt/data-viz/lib/R/site-library", configure.vars="INCLUDE_DIR=/opt/lib LIB_DIR=/opt/lib")
q()


# Edit Renviron file to use additional site-library directories
# nano /opt/R/lib64/R/etc/Renviron
# #R_LIBS_USER=${R_LIBS_USER-'/opt/R/lib64/R/library:/opt/base-library/lib/R/site-library:/opt/data-viz/lib/R/site-library#'}

chmod -R a+rwx /opt/lib
chmod -R a+rwx /opt/R/lib64/R/library/
chmod -R a+rwx /opt/base-library/lib/R/site-library
chmod -R a+rwx /opt/data-viz/lib/R/site-library
# # # # # # # # # # # # # # # # # # # # # # #
#  WinSCP - Delete files/prune R packages   #
#  Prune R Libraries                        #
# # # # # # # # # # # # # # # # # # # # # # #


# RPY2 Interface
VENV=python-rpy2
python3.8 -m venv ${VENV}
mkdir -p python
chmod -R a+rwx python
cd python
source /opt/${VENV}/bin/activate

# Edit .bashrc file to include above environmental variables
# nano .bashrc
# export PATH="$PATH:/opt/R/lib64/R:/opt/R/bin/R:/opt/bin:/opt/lib:/opt/R/bin"
# export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/opt/lib"
# export LIBRARY_PATH="$LD_LIBRARY_PATH:/opt/lib"
# export LD_RUN_PATH="$LD_RUN_PATH:/opt/lib"
# export C_INCLUDE_PATH="$C_INCLUDE_PATH:/usr/include/python2.7/:/opt/include"
# export CPLUS_INCLUDE_PATH="$CPLUS_INCLUDE_PATH:/usr/include/python2.7/:/opt/include"
# export CPATH="$CPATH:/usr/include/python2.7/:/opt/include"
# export LDFLAGS="-I/opt/lib"
# export R_LIBS_USER=${R_LIBS_USER-'/opt/R/lib64/R/library:/opt/base-library/lib/R/site-library:/opt/data-viz/lib/R/site-library'}

# Set environment variables for rpy2 install
export PATH=/opt/R/lib64/R:/opt/R:/opt/R/bin/:/opt/R/bin/R:${PATH}
export LD_LIBRARY_PATH=/opt/lib:${LD_LIBRARY_PATH}
export R_HOME=/opt/R/lib64/R
export R_LIBS=/opt/R/lib64/R/library/:/opt/base-library/lib/R/site-library:/opt/data-viz/lib/R/site-library
export R_LIBS_USER=${R_LIBS_USER-'/opt/R/lib64/R/library/:/opt/base-library/lib/R/site-library:/opt/data-viz/lib/R/site-library'}

source /opt/python/.bashrc

# Install rpy2
export CPLUS_INCLUDE_PATH="$CPLUS_INCLUDE_PATH:/usr/include/python2.7"
pip3 install rpy2
deactivate

cp -r /opt/python-rpy2/lib/python3.8/site-packages/* /opt/python

# Python-R Interface Libraries
cp /usr/lib64/python3.8/lib-dynload/_sqlite3.cyphon-38-x86_64-linux-gnu.so /opt/python


chmod -R a+rwx /opt/python
# # # # # # # # # # # # # # # # # # # # # # #
#  WinSCP - Prune Python files              #
# # # # # # # # # # # # # # # # # # # # # # #


# Package Build Files
sudo -s
cd /opt
zip -r ../rpy2.zip R python lib
zip -r ../r-base-packages.zip base-library
zip -r ../dataviz-packages.zip data-viz
zip -r ../subsystem.zip etc doc modules share


# Upload Build Files to AWS S3
aws configure
# Enter credentials #

cd /
aws s3 cp rpy2.zip s3://aws-lambda-builds-2020
aws s3 cp r-base-packages.zip s3://aws-lambda-builds-2020
aws s3 cp dataviz-packages.zip s3://aws-lambda-builds-2020
aws s3 cp subsystem.zip s3://aws-lambda-builds-2020

