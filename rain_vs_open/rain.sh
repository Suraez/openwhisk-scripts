#!/bin/bash

# Output CSV file
output_file="only_in_rainbowcake.csv"

# Write the header row to the CSV file
echo "File Name,Lines Count" > "$output_file"

# Initialize total lines count
total_lines=0

# Find files that are only in ./RainbowCake-ASPLOS24/ and end with .scala
while IFS= read -r line; do
    # Extract the relative path of the file
    file=$(echo "$line" | sed -n 's|Only in ./RainbowCake-ASPLOS24/\(.*\): \(.*\.scala\)|./RainbowCake-ASPLOS24/\1/\2|p')
    
    # Debugging output to check paths
    echo "Processing file: $file"
    
    # Check if the file exists and is a regular file
    if [[ -f "$file" ]]; then
        # Count the number of lines in the file
        line_count=$(wc -l < "$file")
        
        # Print the results to the console
        echo "$(basename "$file"): $line_count lines"
        
        # Append the results to the CSV file
        echo "$(basename "$file"),$line_count" >> "$output_file"
        
        # Update total lines count
        total_lines=$((total_lines + line_count))
    else
        echo "Warning: $file not found or not a regular file, skipping."
    fi
done < <(diff -rq ./openwhisk ./RainbowCake-ASPLOS24/ | grep -E "Only in ./RainbowCake-ASPLOS24/.*\.scala")

# Write the total row to the CSV file
echo "Total,$total_lines" >> "$output_file"

# Notify user of CSV generation
echo "CSV report generated at $output_file"

