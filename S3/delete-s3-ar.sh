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

    # Check if versioning is enabled and delete all versions and markers
    if aws s3api get-bucket-versioning --bucket "$bucket" | grep -q "Enabled"; then
        echo "Bucket has versioning enabled. Deleting all versions and delete markers."

        # Delete all versions
        aws s3api list-object-versions --bucket "$bucket" --output json | jq -r '.Versions[] | select(.Key != null) | [.Key, .VersionId] | @tsv' | while IFS=$'\t' read -r key version; do 
            aws s3api delete-object --bucket "$bucket" --key "$key" --version-id "$version"
        done

        # Delete all delete markers
        aws s3api list-object-versions --bucket "$bucket" --output json | jq -r '.DeleteMarkers[] | select(.Key != null) | [.Key, .VersionId] | @tsv' | while IFS=$'\t' read -r key version; do 
            aws s3api delete-object --bucket "$bucket" --key "$key" --version-id "$version"
        done
    fi

    # Empty the bucket (non-versioned objects)
    aws s3 rm "s3://$bucket" --recursive

    # Delete the bucket
    aws s3api delete-bucket --bucket "$bucket" --region $(aws s3api get-bucket-location --bucket "$bucket" --query 'LocationConstraint' --output text)
done

echo "All S3 buckets have been deleted."
