# AUMNH Web Portal Export

This repository contains the resources needed to generate, standardize, and package Auburn University Museum of Natural History (AUMNH) Specify Web Portal exports from Specify 7.

The repository serves two primary purposes:

1. Document which Specify queries should be used when exporting portal data from each collection management instance.
2. Provide supporting files and scripts needed to combine multiple collection exports into a single package.

## Repository Structure

```text
.
├── aumnh-fish/
│   ├── flds.json
│   ├── Web Portal Export - Fish.json
│   └── ...
├── aumnh-herbarium/
│   ├── flds.json
│   ├── Web Portal Export - Herbarium.json
│   └── ...
├── aumnh-inverts/
│   ├── flds.json
│   ├── Web Portal Export - Invertebrates.json
│   ├── Web Portal Export - Entomology.json
│   └── ...
├── aumnh-tetrapods/
│   ├── flds.json
│   ├── Web Portal Export - Herps Mammals.json
│   ├── Web Portal Export - Birds.json
│   └── ...
├── Combine_WebPortalExports.R
└── README.md
```

### Instance Folders

Each instance's folder contains:

- `flds.json`
  - The web portal field configuration file used by the portal.
  - Must remain synchronized with the corresponding export query outputs.

- Query definition files (`.json`)
  - Exported Specify query definitions.
  - These are the same queries used to generate Web Portal exports.
  - They provide a backup of the query configuration and document exactly which fields are expected in each export.
    - Queries linked in this document are stored on a user account. If this account goes away or the queries are deleted, the links will not work.

> [!NOTE]
> Some export queries use table formats and/ or aggregations. These will not be applied unless defined in the appropriate Record Formatter in app resources.

### R Script

`Combine_WebPortalExports.R` [:link:](Combine_WebPortalExports.R)

This script:

- Unzips downloaded portal export packages.
- Combines multiple `PortalData.csv` files into a single dataset.
- Preserves a customized `flds.json` file.
- Replaces the combined `PortalData.csv` within a web portal export package.
- Creates a new ZIP file ready for deployment.
- Deletes all other files within the directory.

## General Workflow

### 1. Export Data from Specify

For each database instance:

1. Create a temporary working folder on your computer.
2. Run the appropriate Web Portal Export query.
3. Click the **Export to Web Portal** button from the query results window.
4. Save the downloaded ZIP file into the temporary working folder.
5. Repeat for every collection listed for that instance.

### 2. Combine Exports

1. Open `Combine_WebPortalExports.R` in RStudio (or your IDE of choice).
2. Update [line 6](Combine_WebPortalExports.R#L6) with the folder path where you put the downloaded ZIP files.
3. Run through the script.
4. Verify the resulting combined `PortalData.csv`.
5. Confirm that customized files such as `flds.json` were carried forward correctly.
6. Send or upload the resulting ZIP package to the managing party of the web portal.


## Collection-Specific Instructions

<details>
<summary> <b>Herbarium</b> </summary>

> <ins>**Specify Instance**</ins>
> ---
> [https://aumnh-herbarium.specifycloud.org/](https:://aumnh-herbarium.specifycloud.org)
>
> <ins>**Query**</ins> 
> ---
> **Web Portal Export – Herbarium** [:link:](https://aumnh-herbarium.specifycloud.org/specify/query/50/)
> 
> **Used for:**
> - BRYO
> - LICH
> - FUNG
> - VASC
>
> Query definition is stored in: [`aumnh-herbarium/`](aumnh-herbarium/)
>
> <ins>**Output**</ins>
> ---
> A ZIP file named `aumnh-herbarium_YYYY-mm-dd.zip` with contents:
> ```text
>  .
> ├── PortalFiles/
> │   ├── flds.json
> |   ├── PortalData.csv
> |   ├── PortalInstanceSetting.json
> │   └── SolrFldSchema.xml
> ```
> If any post-export edits are required, only modify cells in `PortalData.csv`.
</details>

<details>
<summary> <b>Tetrapods</b> </summary>

> <ins>**Specify Instance**</ins>
> ---
> [https://aumnh-tetrapods.specifycloud.org/](https://aumnh-tetrapods.specifycloud.org)
>
> <ins>**Queries**</ins>
>  ---
> **Web Portal Export – Herps / Mammals** [:link:](https://aumnh-tetrapods.specifycloud.org/specify/query/42/)
> 
> **Used for:**
> - Herpetology Vouchers
> - Herpetology Tissues
> - Mammalogy Vouchers
> - Mammalogy Tissues
>
> ---
> **Web Portal Export – Birds** [:link:](https://aumnh-tetrapods.specifycloud.org/specify/query/43/)
>
> **Used for:**
> 
> - Ornithology Vouchers
> - Ornithology Tissues
>
> Query definitions are stored in [`aumnh-tetrapods/`](aumnh-tetrapods/)
>
> <ins>**Output**</ins>
> ---
> A ZIP file named `aumnh-tetrapods_YYYY-mm-dd.zip` with contents:
> ```text
>  .
> ├── PortalFiles/
> │   ├── flds.json
> |   ├── PortalData.csv
> |   ├── PortalInstanceSetting.json
> │   └── SolrFldSchema.xml
> ```
> If any post-export edits are required, only modify cells in `PortalData.csv`.
</details>


<details>
<summary> <b>Invertebrates</b> </summary>

> <ins>**Specify Instance**</ins>
> ---
> [https://aumnh-inverts.specifycloud.org/](https://aumnh-inverts.specifycloud.org/)
>
> <ins>**Queries**</ins>
>  ---
> **Web Portal Export – Invertebrates** [:link:](https://aumnh-inverts.specifycloud.org/specify/query/151/)
>
> **Used for:**
>
> - Invertebrates
> - Malacology
>
> ---
> **Web Portal Export – Entomology** [:link:](https://aumnh-inverts.specifycloud.org/specify/query/152/)
>
> **Used for:**
>
> - Entomology
> - Arachnids and Myriapods
>
> Query definitions are stored in [`aumnh-inverts/`](aumnh-inverts/)
>
> <ins>**Output**</ins>
> ---
> A ZIP file named `aumnh-inverts_YYYY-mm-dd.zip` with contents:
> ```text
>  .
> ├── PortalFiles/
> │   ├── flds.json
> |   ├── PortalData.csv
> |   ├── PortalInstanceSetting.json
> │   └── SolrFldSchema.xml
> ```
> If any post-export edits are required, only modify cells in `PortalData.csv`.
</details>

<details>
<summary> <b>Fish</b> </summary>

> <ins>**Specify Instance**</ins>
> ---
> [https://aumnh-fish.specifycloud.org/](https://aumnh-fish.specifycloud.org/)
>
> <ins>**Queries**</ins>
>  ---
> **Web Portal Export – Fish** [:link:](https://aumnh-fish.specifycloud.org/specify/query/47/)
>
> **Used for:**
>
> - Fish Vouchers
>
> Query definition stored in [`aumnh-fish/`](aumnh-fish/)
>
> <ins>**Output**</ins>
> ---
> A ZIP file named `aumnh-fish_YYYY-mm-dd.zip` with contents:
> ```text
>  .
> ├── PortalFiles/
> │   ├── flds.json
> |   ├── PortalData.csv
> |   ├── PortalInstanceSetting.json
> │   └── SolrFldSchema.xml
> ```
> If any post-export edits are required, only modify cells in `PortalData.csv`.
</details>

## Important Notes

### Query Changes Impact Portal Configuration

Changes to an export query can affect:

- `PortalData.csv`
- `flds.json`
- `SolrFldSchema.xml`
- Any downstream portal indexing processes

\
Before modifying a query:

1. Review the current query definition in this repository.
2. Determine whether field additions, removals, or name changes require updates to supporting configuration files.
3. Test the resulting export before publishing.



### Maintaining `flds.json`

The `flds.json` files in this repository represent the field configuration for each portal instance.

If a customized version already exists in production:

- Compare it against the repository version.
- Merge changes carefully.
- Ensure all exported fields remain represented correctly.

> [!TIP]
> 
> Check out [Web Portal Configuration Instructions](https://speciforum.org/t/web-portal-configuration-instructions/1144) and other posts on [Speciforum](https://speciforum.org) for more information about the Specify Web Portal.

## Version Control

When updates are made:

- Commit updated query JSON files whenever query definitions change.
- Commit updated `flds.json` files whenever portal field configurations change.
- Document significant changes in commit messages.
- Triple check the resulting ZIP package before upload.

## Requirements

- R
- RStudio (recommended)
- Access to the relevant Specify instance(s) (Specify 7)
- Permission to run Web Portal Export queries on the collections

## Contact

For questions regarding export query design, workflow, contact Emmy Delekta (emd0083@auburn.edu).