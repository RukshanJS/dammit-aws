#!/bin/bash

# First confirmation with default 'no'
read -p "Are you sure you want to delete ALL S3 buckets and their contents? (y/N) " -r first_confirmation
if [[ ! $first_confirmation =~ ^[Yy]$ ]]
then
    echo "Operation cancelled."
    exit 1
fi

# Second confirmation
read -p "Are you REALLY sure? This action cannot be undone. (y/N) " -r second_confirmation
if [[ ! $second_confirmation =~ ^[Yy]$ ]]
then
    echo "Operation cancelled."
    exit 1
fi

# Get all S3 buckets
buckets=$(aws s3api list-buckets --query 'Buckets[].Name' --output text)

# Iterate over each bucket
for bucket in $buckets; do
    echo "Deleting bucket: $bucket"

    # Empty the bucket first (necessary before deletion)
    aws s3 rm "s3://$bucket" --recursive

    # Delete the bucket
    aws s3api delete-bucket --bucket "$bucket" --region $(aws s3api get-bucket-location --bucket "$bucket" --query 'LocationConstraint' --output text)
done

echo "All S3 buckets have been deleted."
