#!/bin/bash
# This script is the main entry point for the application.

# Read data from the file
data="sample.csv"

# clean the file and log if it's exist
if [ -f json.txt ]; then
    rm json.txt
fi

# Read the header line and split it into an array
readarray -t header_array < <(head -n 1 "$data" | tr ',' '\n')

# Loop through each line (starting from the second line) and process it
tail -n +2 "$data" | while IFS=, read -r fields || [[ -n "$fields" ]]; do
    echo "Processing line: $fields"
    # Create JSON data using header as key and fields as value
    # if value is empty, then it will be empty string
    json="{"
    for i in "${!header_array[@]}"; do
        key=$(echo "${header_array[$i]}" | tr -d '\r')
        value=$(echo "$fields" | cut -d',' -f$((i + 1)) | tr -d '\r')
        json="$json\"$key\":\"$value\","
    done
    json="${json%,}"
    json="$json}"

    # Print the JSON data
    echo "$json"

    # log the JSON data to a file
    echo "$json" >> json.txt
done

# read the json file and print the data
formatedData=$(cat json.txt)

# check if the file is exist and not empty
if [ -s json.txt ]; then
    echo "$formatedData"
else
    echo "No data found"
fi