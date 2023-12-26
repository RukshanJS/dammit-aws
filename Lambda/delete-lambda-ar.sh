#!/bin/bash

# First confirmation with default 'no'
read -p "Are you sure you want to delete ALL Lambda functions in ALL regions? (y/N) " -r first_confirmation
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

# Get all AWS regions
regions=$(aws ec2 describe-regions --query "Regions[].RegionName" --output text)

# Iterate over each region
for region in $regions; do
    echo "Processing region: $region"

    # Get Lambda functions in the current region
    lambda_functions=$(aws lambda list-functions --region "$region" --query 'Functions[*].FunctionName' --output text)

    # Check if there are Lambda functions in the region
    if [ -n "$lambda_functions" ]; then
        # Delete each function
        for function in $lambda_functions; do
            echo "Deleting function: $function in region: $region"
            aws lambda delete-function --function-name "$function" --region "$region"
        done
    else
        echo "No Lambda functions found in region: $region"
    fi
done

echo "All Lambda functions in all regions have been deleted."
