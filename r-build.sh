#!/bin/bash

# modified from https://github.com/Appsilon/r-lambda-workflow

#Amazon Linux AMI 2018.03.0.20181129 x86_64 HVM gp2

set -euo pipefail

VERSION=3.6.3

wget https://cran.uni-muenster.de/src/base/R-3/R-$VERSION.tar.gz
sudo mkdir /opt/R/
sudo chown ec2-user /opt/R/
chmod -R 777 /opt/R/
tar -xf R-$VERSION.tar.gz
mv R-$VERSION/* /opt/R/
sudo yum install -y readline-devel \
xorg-x11-server-devel libX11-devel libXt-devel \
curl-devel \
gcc-c++ gcc-gfortran \
zlib-devel bzip2 bzip2-libs


sudo yum install -y R

cd /opt/R/
./configure --prefix=/opt/R/ --exec-prefix=/opt/R/ --with-libpth-prefix=/opt/ --without-recommended-packages
make
cp /usr/lib64/libgfortran.so.3 lib/
cp /usr/lib64/libgomp.so.1 lib/
cp /usr/lib64/libquadmath.so.0 lib/
cp /usr/lib64/libstdc++.so.6 lib/
sudo yum install -y openssl-devel libxml2-devel


./bin/Rscript -e 'install.packages(c("xml2"), repos="http://cran.r-project.org")'


./bin/Rscript -e 'install.packages(c("jsonlite", "dplyr","tidyr", "fuzzyjoin", "data.table", "aws.signature", "magrittr", "stringr", "readr", "Matrix", "httr", "logging"), repos="http://cran.r-project.org")'

./bin/Rscript -e 'install.packages("aws.s3", repos = c("cloudyr" = "http://cloudyr.github.io/drat"))'


zip -r -q R.zip bin/ lib/ lib64/ etc/ library/ doc/ modules/ share/


aws s3 cp R.zip s3://war-reserve-cos/R-3.6.3/

#After I send to S3 bucket I manually download and remove files/packages to reduce file size
