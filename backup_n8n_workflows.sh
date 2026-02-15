#!/bin/bash

BACKUP_FILE="visual_testing_backup.json"
TEMP_FILE="n8n_data/config/temp_all_workflows.json"
# The docker output path is relative to the container's mount.
DOCKER_OUTPUT_PATH="/home/node/.n8n/temp_all_workflows.json"

echo "Starting backup of 'Visual Tester' and 'Visual Testing - Updater' workflows..."

# Remove old backup file if it exists
if [ -f "$BACKUP_FILE" ]; then
    echo "Removing old backup file: $BACKUP_FILE"
    rm "$BACKUP_FILE"
fi

# Remove old temp file if it exists (just in case)
if [ -f "$TEMP_FILE" ]; then
    rm "$TEMP_FILE"
fi

echo "Exporting all workflows from n8n container..."
# Try running docker without sudo first, fallback to sudo if needed or just let it fail if permissions are wrong.
# Using 'docker' directly is standard.
docker exec n8n-visual-tester n8n export:workflow --all --output="$DOCKER_OUTPUT_PATH"

if [ ! -f "$TEMP_FILE" ]; then
    echo "Error: Export failed. file '$TEMP_FILE' not found."
    echo "Make sure the docker container 'n8n-visual-tester' is running and you have permissions."
    exit 1
fi

echo "Filtering for target workflows..."

# Python script to filter and save separate JSON files
python3 -c "
import json
import sys
import os

input_file = '$TEMP_FILE'

# Define mapping from Workflow Name -> Output Filename
workflow_map = {
    'Visual Tester': 'visual_tester_backup.json',
    'Visual Testing - Updater': 'visual_testing_updater_backup.json'
}

try:
    with open(input_file, 'r') as f:
        data = json.load(f)

    # Ensure data is a list
    if isinstance(data, dict):
        workflows = [data]
    else:
        workflows = data

    found_count = 0
    for wf in workflows:
        name = wf.get('name')
        if name in workflow_map:
            output_file = workflow_map[name]
            print(f'Saving workflow \"{name}\" to {output_file}...')
            with open(output_file, 'w') as out_f:
                json.dump(wf, out_f, indent=2)
            found_count += 1

    if found_count == 0:
        print('Warning: No matching workflows found.')
    else:
        print(f'Successfully saved {found_count} workflow(s).')

except Exception as e:
    print(f'Error processing JSON: {e}')
    sys.exit(1)
"

# Check if backups were created
if [ -f "visual_tester_backup.json" ] || [ -f "visual_testing_updater_backup.json" ]; then
    echo "Backup process completed."
    # Cleanup temp file
    rm "$TEMP_FILE"
    # Cleanup old combined file if it exists
    if [ -f "$BACKUP_FILE" ]; then
        rm "$BACKUP_FILE"
    fi
else
    echo "Error: No backup files were created."
    exit 1
fi
