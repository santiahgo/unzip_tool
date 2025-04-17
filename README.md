# How to Use

## Initial Setup

- Unzip the script into the directory of your choice
- Visit this [link](https://stackoverflow.com/questions/38782928/how-to-add-man-and-zip-to-git-bash-installation-on-windows)
  - Follow the answer with 129 upvotes made by NSJonas and edited by Mickverm
- Open the script in VS Code and edit lines 13, 14, and 120 (and if you want, line 49) so that the directories are the host of your files
  - For ZIP Files: The zip files I download from canvas are located in my downloads folder, so line 13 will be the relative path to my downloads folder.
    - Same thing can be said about the zip files you wish to delete from your downloads folder
  - For the contents of the zip after unzipping: the contents after unzipping will be located in my **grading** folder

## Running the Script

1. Open a Git Bash Terminal and go to the directory that contains the bash script
2. Run the script
    - The script takes two arguments:
        - The first argument is the name of the zip file you want to unzip
        - The second argument is the name of the directory you want to unzip to
    - Example: ./unzip_folder.sh test projects/student
        - This unzips the **test.zip** file to the **student directory contained in the projects directory**

## What the Script does

1. Deletes any previous projects contained in the destination directory
2. Deletes any unwanted files/folders from the unzipped directory (as of 1/15/2025)
    - node_modules
    - .history
    - .DS_Store
    - __MACOSX
    - .vscode
3. Unzip the file to the directory of your choice
4. Installs dependencies from the package.json file if the package.json exists
5. Opens VS Code
6. Deletes the original zip file from your downloads directory

> If you have any confusions, please let me know and I can help you.
