#!/bin/bash

# Output CSV file
output_file="scala_diff_report.csv"

# Write the header row to the CSV file
echo "File Name,Lines Added,Lines Deleted" > "$output_file"

# Initialize totals
total_added=0
total_deleted=0

# Loop through the differing .scala files
for file in $(diff -rq ./openwhisk ./RainbowCake-ASPLOS24/ | grep ".scala differ" | awk '{print $2}'); do
    # Calculate the number of lines added
    added_lines=$(diff -u "$file" "${file/openwhisk/RainbowCake-ASPLOS24}" | grep -E '^\+' | grep -v '^+++' | wc -l)
    
    # Calculate the number of lines deleted
    deleted_lines=$(diff -u "$file" "${file/openwhisk/RainbowCake-ASPLOS24}" | grep -E '^\-' | grep -v '^---' | wc -l)
    
    # Print the results to the console
    echo "$file differs with ${file/openwhisk/RainbowCake-ASPLOS24}: $added_lines lines added, $deleted_lines lines deleted"
    
    # Append the results to the CSV file
    echo "$(basename "$file"),$added_lines,$deleted_lines" >> "$output_file"
    
    # Update totals
    total_added=$((total_added + added_lines))
    total_deleted=$((total_deleted + deleted_lines))
done

# Write the total row to the CSV file
echo "Total,$total_added,$total_deleted" >> "$output_file"

# Notify user of CSV generation
echo "CSV report generated at $output_file"

