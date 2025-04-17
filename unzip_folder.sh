#!/bin/bash

# Loading environment variables (testing something rq)
source .env

# Check if the number of arguments is correct, it has to be the project/exercise folder name and destination folder name (in that order)
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <input_file> <output_file>"
    exit 1
fi

# Zip file and destination folder default locations
ZIP_FILE=$DOWNLOADS_DIR
DEST_FOLDER=$DEST_FOLDER

# Get the arguments
arg1=$1
arg2=$2

ZIP_FILE+=$arg1
ZIP_FILE+=".zip" # added this because it wouldn't delete the zip file after it had been unzipped
DEST_FOLDER+=$arg2

# Check if the zip file exists
if [ ! -f $ZIP_FILE ]; then
    echo "ZIP file does not exist"
    exit 1
fi

# Check is the zip is empty
if ! zipinfo -t $ZIP_FILE > /dev/null 2>&1; then
    echo "Zip is empty..."
    rm -rf $ZIP_FILE
    exit 1
fi

# create the destination folder if it doesn't exist
if [ ! -d "$DEST_FOLDER" ]; then
    echo -e "Destination folder does not exist currently. Creating it...\n"
    mkdir -p "$DEST_FOLDER"
fi

# Deleting the contents of the destination folder one first
if [ -d "$DEST_FOLDER" ] && find "$DEST_FOLDER" -mindepth 1 -print -quit 2>/dev/null | grep -q .; then
    rm -r "$DEST_FOLDER/"*
fi

# removing unwanted folders
unwanted_folders=(".vscode" "__MACOSX" "node_modules" ".DS_Store" ".history" ".git")
TEMP_DIR=$(mktemp -d)

echo -e "Extracting '$ZIP_FILE' to temporary directory...\n"
unzip -q "$ZIP_FILE" -d "$TEMP_DIR"

if [ $? -ne 0 ]; then
    echo "Error: Failed to extract ZIP file."
    rm -rf "$TEMP_DIR"
    exit 1
fi

echo "Removing unwanted files/folders..."
for folder in "${unwanted_folders[@]}"; do
    echo "Searching for '$folder'..."
    find "$TEMP_DIR" -type d -name "$folder" -exec rm -rf {} +
    find "$TEMP_DIR" -type f -name "$folder" -exec rm -f {} +
done

echo -e "Removal complete\n"

NEW_ZIP_FILE="${ZIP_FILE%.zip}_cleaned.zip"
cd "$TEMP_DIR" || exit 1
zip -qr "$NEW_ZIP_FILE" .

if [ $? -ne 0 ]; then
    echo "Error: Failed to create cleaned ZIP file."
    rm -rf "$TEMP_DIR"
    exit 1
fi

# Replace the original zip file with the cleaned version
mv "$NEW_ZIP_FILE" "$ZIP_FILE"

# Getting the top level folder name from the zip file
FOLDER_NAME=$(zipinfo -1 "$ZIP_FILE" | grep -o '^[^/]*/' | sort -u | head -n 1 | tr -d '/')
echo "Top-level folder: $ZIP_FILE"

# remove the temp directory
rm -rf "$TEMP_DIR"

# Unzip the file
echo "Unzipping '$ZIP_FILE' to '$DEST_FOLDER'"
unzip -q "$ZIP_FILE" -d "$DEST_FOLDER"

if [ $? -eq 0 ]; then
    echo -e "Unzip successful\n"
else
    echo "Unzip failed"
    exit 1
fi

if  [ -f "$DEST_FOLDER/$FOLDER_NAME/package.json" ]; then
    echo "Installing dependencies..."
    cd "$DEST_FOLDER/"* || exit 1
    npm install
else
    echo "No package.json found. Skipping npm install."
fi

# Open the destination folder in VS Code
code "$DEST_FOLDER/$FOLDER_NAME"

if [ $? -eq 0 ]; then
    echo -e "VS Code opened '$DEST_FOLDER/$FOLDER_NAME'\n"
else
    echo "Error: Failed to open VS Code. Ensure 'code' command is available in your PATH."
    exit 1
fi

# Remove the zip file
DOWNLOADS=$DOWNLOADS_DIR
if [[ "$ZIP_FILE" =~ ^$DOWNLOADS_DIR/.* ]]; then
    echo "Removing '$ZIP_FILE'"
    rm -rf "$ZIP_FILE"
    if [ $? -eq 0 ]; then
        echo "Successfully removed '$ZIP_FILE'"
    else
        echo "Error: Failed to remove '$ZIP_FILE'"
        exit 1
    fi
else
    echo "'$ZIP_FILE' is not in '$DOWNLOADS_DIR'. Skipping removal..."
    exit 1
fi