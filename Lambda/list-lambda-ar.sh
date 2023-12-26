#!/bin/bash

# Header for the table
echo "Region | Lambda Function Name"

# Get all AWS regions
regions=$(aws ec2 describe-regions --query "Regions[].RegionName" --output text)

# Iterate over each region
for region in $regions; do
    # Get Lambda functions in the current region
    lambda_functions=$(aws lambda list-functions --region "$region" --query 'Functions[*].FunctionName' --output text)

    # Check if there are Lambda functions in the region
    if [ -n "$lambda_functions" ]; then
        # Print each function name with the region
        for function in $lambda_functions; do
            echo "$region | $function"
        done
    else
        echo "$region | No Lambda functions"
    fi
done
