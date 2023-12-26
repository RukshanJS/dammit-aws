#!/bin/bash

# Header for the table
echo "Bucket Name | Creation Region"

# Get all S3 buckets along with their regions
buckets=$(aws s3api list-buckets --query 'Buckets[].Name' --output text)

# Iterate over each bucket
for bucket in $buckets; do
    # Get the region where the bucket was created
    region=$(aws s3api get-bucket-location --bucket "$bucket" --query 'LocationConstraint' --output text)

    # AWS returns 'null' for buckets in the us-east-1 region, so we handle that case
    if [ "$region" == "null" ]; then
        region="us-east-1"
    fi

    # Print each bucket name with its creation region
    echo "$bucket | $region"
done
