#!/bin/bash
# This script is the main entry point for the application.

# read the specs file to initialize the data and server variables
specs=$(cat specs.json)
if [ -f specs.json ]; then
    data=$(echo "$specs" | jq -r '.data')
    server=$(echo "$specs" | jq -r '.server')
    method=$(echo "$specs" | jq -r '.method')
else
    echo "No specs file found"
    exit 1
fi

# check if the data file is exist
if [ ! -f "$data" ]; then
    echo "Data file not found"
    exit 1
fi

# clean the file and log if it's exist
if [ -f payload.txt ]; then
    rm payload.txt
fi

# check if the log folder is exist
if [ ! -d log ]; then
    mkdir log
fi

# if log folder is exist, then clean the log files
if [ -d log ]; then
    rm log/*
fi

# Read the header line and split it into an array
readarray -t header_array < <(head -n 1 "$data" | tr ',' '\n')

# Loop through each line (starting from the second line) and process it
tail -n +2 "$data" | while IFS=, read -r fields || [[ -n "$fields" ]]; do
    # echo "Processing line: $fields"
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
    # echo "$json"

    # log the JSON data to a file
    echo "$json" >> payload.txt
done

# read the json file and print the data
payload=$(cat payload.txt)

# check if the file is exist and not empty
if [ -s payload.txt ]; then
    # loop through the data and send it to the server
    while IFS= read -r line; do
        echo "Sending data to the server: $line"

        # send the data to the server and log the response and its http status code
        response=$(curl -i -X "$method" -H "Content-Type: application/json" -d "$line" "$server")
        status_code=$(echo "$response" | grep HTTP | awk '{print $2}')
        # echo "Status Code: $status_code"
        # echo "Response: $response"

        # log the response into a file in log folder with current date, status code, & payload
        echo "$(date +'%d-%m-%Y-%H:%M:%S') - status: $(echo "$status_code" | jq -r '.statusCode') - payload: '$line'" >> log/"$(date +"%Y%m%d-%H:%M")".log
    done <<< "$payload"
else
    echo "File payload.txt is not exist"
fi