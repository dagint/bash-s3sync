#!/bin/bash

BUCKETNAME='dagint'

for region in `aws ec2 describe-regions --output text | cut -f3`; do
	if [[ -z $(aws s3api head-bucket --bucket $BUCKETNAME-$region 2>&1) ]]; then
        echo "$BUCKETNAME-$region - bucket exists"
	else
        echo "$BUCKETNAME-$region - bucket does not exist or permission is not there to view it.  Attempting to create bucket"
		if [ $region == 'us-east-1' ]; then
			aws s3api create-bucket --bucket $BUCKETNAME-$region --region $region 2>&1
		else
			aws s3api create-bucket --bucket $BUCKETNAME-$region --region $region --create-bucket-configuration LocationConstraint=$region 2>&1
		fi
		if [[ -z $(aws s3api head-bucket --bucket $BUCKETNAME-$region 2>&1) ]]; then
			echo "$BUCKETNAME-$region - bucket exists"
		else
			echo "ERROR: Unable to create bucket: $BUCKETNAME-$region"
		fi
	fi
	echo "Syncing files to S3 bucket: $BUCKETNAME-$region"
	aws s3 sync ./s3syncfolder/ "s3://$BUCKETNAME-$region" --acl public-read
done
