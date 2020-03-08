
AWS LAMBDA R ENVIRONMENT SETUP\
[Reference 1: Running R On AWS Lambda](https://medium.com/bakdata/running-r-on-aws-lambda-9d40643551a6)\
[Reference 2: RBloggers - How To Use R In AWS Lambda](https://www.r-bloggers.com/how-to-use-r-in-aws-lambda/)\
[Reference 3: AWS Tutorial - Publishing a Custom Runtime](https://docs.aws.amazon.com/lambda/latest/dg/runtimes-walkthrough.html)

(for EC2 memory management - R requires a lot of space for compiling readr and some other packages)\
(run below when creating EC2 instance on AWS prior to installing R)


`sudo /bin/dd if=/dev/zero of=/var/swap.1 bs=1M count=12288`\
`sudo /sbin/mkswap /var/swap.1`\
`sudo /sbin/swapon /var/swap.1`\
`sudo sh -c 'echo "/var/swap.1 swap swap defaults 0 0 " >> /etc/fstab`

# Run this script
[r-build.sh - in terminal with copy and paste]

(Copy zip output files to S3 Bucket)\
`aws s3 cp R.zip s3://war-reserve-cos/R-3.6.2/`


(For Additional R Packages Layer)\
`mkdir -p /opt/R/new_library/R/library`\
`sudo chmod -R a+rwx /opt/R/new_library/R/library`  #make it writeable

 
[Modifications to r-build.sh: R command line @root]\
`install.packages(c("dplyr","tidyr", "fuzzyjoin", "data.table", "magrittr", "stringr", "readr","xgboost"),`\
`lib = '/opt/R/new_library/R/library', repos="http://cran.r-project.org")`

`cd /opt/R/new_library && zip -r -q packages.zip R/`

`aws s3 cp packages.zip s3://war-reserve-cos/R-3.6.2/`


(Lambda limit is 50MB - did some final post processing with linux split command. Reposted to S3)\
`split -b 40M packages.zip "packages-2.zip"`  # And then renames\
`zip R.zip bootstrap runtime.R`  # Bundle Base R Layer with Boostrap/Runtime.R environment


(Finally - publish everything to Lambda as seperate layers)

#(this worked)\
`aws lambda publish-layer-version \` \
`      --layer-name wr-cos-baser  \` \
`     --zip-file fileb://R.zip`  \`

(this didn't work)\
`aws lambda publish-layer-version \  ` \
`    --layer-name wr-cos-packageA \  ` \
`    --zip-file fileb://packageA.zip `
	
	
(this didn't work)	\
`aws lambda publish-layer-version \  ` \
`    --layer-name wr-cos-packageB \  ` \
`    --zip-file fileb://packageB.zip` 
	

*Can't use zip - Have to manually split up packages with their R dependencies - slow process..probably a better way*\
*After manually reducing file size*


(This works - updated packages are good to go. Need to figure out base R upgrade to R version 3.6.2) \
`aws lambda publish-layer-version \ `   \
`       --layer-name wr-cos-package1\ ` \
`      --zip-file fileb://packages1.zip`
       
`aws lambda publish-layer-version \ `  \
`      --layer-name wr-cos-package2 \`  \
`      --zip-file fileb://packages2.zip`
	

These precompiled layers work but R version 3.6.0:\
arn:aws:lambda:us-east-1:131329294410:layer:r-runtime-3_6_0:13\
arn:aws:lambda:us-east-1:131329294410:layer:r-recommended-3_6_0:13

Once Base R and Packages layers are published...a pretty simple process to use lambda functions. \
See References 1 and 2.
	
	
	
	
# aws-lambda-r-setup
