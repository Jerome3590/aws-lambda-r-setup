
AWS LAMBDA R ENVIRONMENT SETUP\
[Reference 1: Running R On AWS Lambda](https://medium.com/bakdata/running-r-on-aws-lambda-9d40643551a6)\
[Reference 2: RBloggers - How To Use R In AWS Lambda](https://www.r-bloggers.com/how-to-use-r-in-aws-lambda/)\
[Reference 3: AWS Tutorial - Publishing a Custom Runtime](https://docs.aws.amazon.com/lambda/latest/dg/runtimes-walkthrough.html) \
[Reference 4: Running R Script on Lambda](https://medium.com/veltra-engineering/running-r-script-on-aws-lambda-custom-runtime-3a87403dcb) \
[Reference 5: Serverless Container-aware ARchitectures](https://github.com/grycap/scar/tree/master/examples/r)

[Docker]
docker run -ti --name baser-deb-slim debian:stretch-slim bash

apt-get update
apt-get install wget
apt-get install sudo

set -euo pipefail

VERSION=3.6.3

wget https://cran.uni-muenster.de/src/base/R-3/R-$VERSION.tar.gz  \
mkdir /opt/R/     \
chown $(whoami) /opt/R/   \
tar -xf R-$VERSION.tar.gz  \
mv R-$VERSION/* /opt/R/


sudo apt install dirmngr apt-transport-https ca-certificates software-properties-common gnupg2  

sudo apt-get install -y readline-devel \
xorg-x11-server-devel libX11-devel libXt-devel \
curl-devel \
gcc-c++ gcc-gfortran \
zlib-devel bzip2 bzip2-libs

sudo apt install dirmngr apt-transport-https ca-certificates software-properties-common gnupg2

sudo apt-key adv --keyserver keys.gnupg.net --recv-key 'E19F5F87128899B192B1A2C2AD5F960A256A04AF' \
sudo add-apt-repository 'deb https://cloud.r-project.org/bin/linux/debian stretch-cran35/'

sudo apt update
sudo apt install r-base

sudo apt install build-essential

cd /opt/R/
./configure --prefix=/opt/R/ --exec-prefix=/opt/R/ --with-libpth-prefix=/opt/ --without-recommended-packages  \
make
cp /usr/lib64/libgfortran.so.3 lib/  \
cp /usr/lib64/libgomp.so.1 lib/      \
cp /usr/lib64/libquadmath.so.0 lib/  \
cp /usr/lib64/libstdc++.so.6 lib/    \
sudo apt install libssl-dev libxml2-dev  \
libcurl4-openssl-dev


install.packages(c("jsonlite", "aws.signature", "httr", "xml2", "logging"), repos="http://cran.r-project.org")'  \

install.packages("aws.s3", repos = c("cloudyr" = "http://cloudyr.github.io/drat"))' \

R_HOME_DIR=$R_HOME

zip -r -q R.zip bin/ lib/ lib64/ etc/ library/ doc/ modules/ share/

(Copy from Docker to local file system)
(pwd)

docker cp CONTAINER:{pwd}/R.zip R.zip

[Windows Bash Linux]
set -euo pipefail

rm -rf R/
unzip -q R.zip -d R/
rm -r R/doc/manual/
chmod -R 755 bootstrap runtime.R R/
rm -f runtime.zip
zip -r -q runtime.zip runtime.R bootstrap R/
zip runtime.zip bootstrap runtime.R R/# Bundle Base R Layer with Boostrap/Runtime.R environment

(Copy to S3 Bucket)
aws s3 cp runtime.zip s3://cana-jerome-test/RBuilds/

(Finally - publish everything to Lambda as seperate layers
aws lambda publish-layer-version --layer-name baseR-3.6.3 --zip-file fileb://runtime.zip
	
	
# aws-lambda-r-setup
