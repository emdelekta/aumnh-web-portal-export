library(dplyr)
library(readr)
library(stringr)

target_folder <- "/Users/emd0083/Downloads/inverts_exports"
setwd(target_folder)
getwd()

# This is for the base query export (download as csv) from Sp7
query <- read_csv(file = "YOUR_FILE_PATH_HERE.csv", 
                         col_types = cols(.default = col_character())
                  )

# Unzip the web portal export of interest
# This is the "PortalData.csv" in a zip folder
portal <- read_csv(file = "PortalFiles/PortalData.csv",
                          col_types = cols(.default = col_character())
                   )


# Do the two dataframes have the same column names? 
colnames(query)
colnames(portal)

# No, these are different so we'll have to rename some
# The first 4 columns are auto-assigned in web export.
# glimpse(portal_export)
names(query) <- names(portal)[5:ncol(portal)]

id_col <- "catalogNumber"

# Ensure columns are ordered consistently
common_cols <- intersect(names(portal), names(query))

df_portal <- portal[, common_cols]
df_query <- query[, common_cols]

# Combine and prefer updated values
df_combined <- rows_update(df_portal, df_query, by = "catalogNumber")

df_combined

# In the case more has been added since the query export was done
# Find catalogNumbers not in df_query
new_objects <- setdiff(df_portal$catalogNumber, df_query$catalogNumber)

# These should return the same number
nrow(portal) - length(new_objects)
nrow(query)

# Add first 4 columns from portal export
tmp <- left_join(df_query, portal, by = "catalogNumber",
                 suffix = c(".df_query", ".portal"))
nrow(tmp)
nrow(df_query)
names(tmp)

tmp2 <- tmp %>%
  select(1:length(portal)) %>%
  rename_with(~sub("\\..*", "", .)) %>%
  select(names(portal))

new_rows <- portal %>%
  filter(catalogNumber %in% new_objects)

# VERIFY: These two should match
nrow(new_rows)
length(new_objects)

# Then we can add them together
merged_data <- bind_rows(tmp2, new_rows)

# VERIFY: These two should match...
nrow(merged_data)
nrow(portal)

# Then fix the `contents` and `geoc` columns...
library(stringr)
tst <- merged_data %>%
  mutate(across(5:last_col(), ~replace_na(as.character(.), ""))) %>%
  # Strip trailing decimal zereos from target columns
  mutate(
    # This was causing it to round to sig digs, not desired!
    # latitude1  = sprintf("%g", as.numeric(latitude1)),
    # longitude1 = sprintf("%g", as.numeric(longitude1))
    across(
      c(latitude1, longitude1),
      ~ .x |>
        stringr::str_remove("0+$") |>
        stringr::str_remove("\\.$")
    )
  ) %>%
  unite("contents_new", 5:last_col(), sep = "\t", remove = FALSE, na.rm = FALSE) %>%
  # do unite call
  unite("geoc_new", c("latitude1", "longitude1"), sep = " ", remove = FALSE, na.rm = FALSE) %>%
  mutate(geoc_new = na_if(geoc_new, "NA NA")) %>%
  mutate(across(everything(), ~ na_if(., "")))

# VERIFY: Each couplet should return pretty much the same values
head(tst$contents)[1]
head(tst$contents_new)[1]

head(tst$geoc)
head(tst$geoc_new)

# Then make it formatted like the original...
output <- tst %>%
  select(-c(geoc, contents)) %>%
  rename_with(~ str_remove(., "_new")) %>%
  select(names(portal))

# VERIFY: Make sure the number of records matches.
nrow(output)
nrow(portal)

# Save the new and improved csv file 
# THIS WILL OVERWRITE WHAT WAS IN THE UNZIPPED PortalFiles/ FOLDER!!!
write_csv(output, "PortalFiles/PortalData.csv",
          na = "")

# Then you can rezip the folder and replace the old one :) 
# Note: You will need to  manually delete the old folder if this doesn't overwrite it

zip_name <- paste0(unique(output$collectionName),
                   ".zip")

zip::zip(
  zipfile = zip_name,
  files = "PortalFiles",
  recurse = TRUE
)

# Clear R environment
rm(list = ls())

# Now, you should be OK to move on to Combine_WebPortalExports.R!

