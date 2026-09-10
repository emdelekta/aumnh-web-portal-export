library(readr)
library(dplyr)


# Point it at the correct folder first
target_folder <- "YOUR_FILE_PATH_HERE" # <-- Change this to the folder where the zip files are located

setwd(target_folder)
getwd() # Confirm it set to the folder location

# Which database instance are you combining for?
# List choices & prompt user to select
choices <- c("aumnh-herbarium", "aumnh-inverts", "aumnh-tetrapods", "aumnh-fish", "aumnh-paleo")
selection <- menu(choices, title = "Select the Specify instance you are combining the files for:")

instance <- choices[selection]

zip_files <- list.files(pattern = "\\.zip$")

# Verify that it sees all the folders
zip_files
message(paste("There are", length(zip_files), "zipped folders in the target folder."))

# Extract all the data from each of the PortalData.csv files within each zip 
# folder of of the working directory.
all_data <- lapply(zip_files, function(z) {
  
  contents <- unzip(z, list = TRUE)
  
  portal_file <- contents$Name[
    grepl("PortalData\\.csv$", contents$Name)
  ][1]
  
  cat("Reading", z, "->", portal_file, "\n")
  
  read_csv(
    unz(z, portal_file),
    col_types = cols(.default = col_character())
  )
})

# In cases where there are two different queries for one instance, it is 
# critical you make sure there are no columns being added.
#
# Check to see how many columns are in the original data. These should all be equal.
lapply(all_data, ncol)

# combined <- bind_rows(all_data)
# ncol(combined)

# # If combined has more columns than what it should, figure out what's causing it
# lapply(all_data, names)
# # or
# column_counts <- table(unlist(lapply(all_data, colnames)))
# names(column_counts[column_counts < length(all_data)])

# The queries all have to be in the same exact order, even if there is more 
# than one query used. This can result in the field name being different 
# depending on the schema of that discipline.
#
# To make sure column addition won't be a problem, we can force R to combine the
# dataframes present in `all_data` without paying mind to the column names.
new_names <- names(all_data[[1]])
all_data <- lapply(all_data, setNames, new_names)

combined <- bind_rows(all_data)
ncol(combined)

# Make sure all collections are represented!
if (instance == "aumnh-herbarium") {
  unique(combined$description)
} else {
  unique(combined$collectionName)
}

write_csv(combined, "Combined_PortalData.csv", na = "")

# Verify the contents of "Combined_PortalData.csv" are correct!

# Establish basis of your "new" combined file(s)...
# Copy and rename a zip file
# Extract the first file from the list of zip files
# This makes it work regardless of zip file names
zip_target <- zip_files[1]

file.copy(from = zip_target,
          to = "PortalFiles.zip",
          overwrite = TRUE)

# Unzip the folder you just made...
unzip("PortalFiles.zip")

# Assuming there is a zip folder called PortalFiles in the working directory,
# overwrite the exisitng PortalData.csv in that folder with Combined_PortalData.csv

file.copy(
  from = "Combined_PortalData.csv",
  to = file.path("PortalFiles", "PortalData.csv"),
  overwrite = TRUE
)

# Check that it worked...
tmp <- read_csv("PortalFiles/PortalData.csv", 
                col_types = cols(.default = col_character()))

nrow(combined) # Records in what we've combined
nrow(tmp) # Records in the saved PortalData.csv

# Out of curiosity, check to see if overlapping spids
length(unique(combined$spid))

# How many are duplicated???
length(unique(combined$spid[duplicated(combined$spid)]))

# # See which are duplicates [FOR aumnh-herbarium only]
# dupes <- combined %>%
#   group_by(spid) %>%
#   filter(n() > 1) |>
#   ungroup() %>%
#   select(description, name, text2, fieldNumber) %>%
#   unique() %>%
#   rename("Collection Name" = description, "AUA#" = name, "Barcode#" = text2, "Collector#" = fieldNumber)
# 
# dupes
# 
# # Duplications are happening because there is more than 1 preparation for those
# # collection objects.
# 
# write_csv(dupes, "AdditionalPreps.csv", na = "")

# Make any edits to flds.json (see https://speciforum.org/t/web-portal-configuration-instructions/1144)
# You may want to edit things like 'title' and 'advancedsearch'.

# Grab flds.json from GitHub (or copy from another directory)
# Define the raw GitHub URL and target filepath
json_url <- paste0("https://raw.githubusercontent.com/emdelekta/aumnh-web-portal-export/refs/heads/main/", choices[selection], "/flds.json")
target_filepath <- paste0(getwd(),"/PortalFiles/flds.json")

# Download and save the file, overwriting the original.
download.file(url = json_url, destfile = target_filepath)

# Once everything is good, re-zip the folder
# Define the file name to use
zip_name <- paste0(instance,
                   "_",
                   format(Sys.Date(), "%Y-%m-%d"),
                   ".zip")

# Re-zip the folder
zip::zip(
  zipfile = zip_name,
  files = "PortalFiles",
  recurse = TRUE
)

# Now, cleanup the directory.
# Get a list of all files in the directory
all_items <- list.files()

# Filter out the file to keep
items_to_delete <- setdiff(all_items, zip_name)

# MAKE SURE YOU WANT TO DELETE THESE FILES!
print(items_to_delete)

# Permanently delete the rest of the files within the directory
# This cannot be undone!
unlink(items_to_delete, recursive = TRUE)

# Clear R environment
rm(list = ls())
