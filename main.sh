#!/bin/bash
# This script is the main entry point for the application.

# read user input to get .csv data name in the current directory
echo "Enter the .csv data file name in the current directory:"
read -rp "> " DATA
echo "Data: $DATA"

# check if the file exists
if [ ! -f "$DATA" ]; then
    echo "File not found!"
    exit 1
fi

# read user input to get the API URL
echo "Enter the API URL:"
read -rp "> " API_URL
echo "API URL: $API_URL"

# store the data in a variable
DATA=$(cat "$DATA")

# define funtion to convert each data row into JSON format
function convert2json () {
    # Get the header
    header=$(echo "$DATA" | head -n 1)
    echo "Header: $header"

    # Get the data
    data="$1"
    echo "Data: $data"

    # Combine the header and data
}

# Loop through the data and convert each row to JSON with the header as keys
echo "$DATA" | tail -n +2 | while read -r line; do
    # echo "Line: $line"

    # Convert the line to JSON
    convert2json "$line"

    # Sleep for 1 second
    sleep 1
done
