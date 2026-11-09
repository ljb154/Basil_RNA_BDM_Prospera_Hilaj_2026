# Basil_RNA_BDM_Prospera_Hilaj_2026

RNA-seq differential gene expression analysis in basil using DESeq2, with protein annotation by BLASTP against UniProt/Swiss-Prot and Gene Ontology (GO) analyses.

## Repository layout

``` text
Basil_RNA_BDM_Prospera_Hilaj_2026/
├── README.md
├── install_packages.R
├── calculate_DEGs_deseq2_pub.Rmd
└── inputs/
    ├── gene_count_matrix.txt
    ├── metadata_LB.csv
    └── Perrie_v1.0_blast_results.tsv.gz  # must be generated as too large to host on GitHub
```

The analysis creates `results/` (tables and figures) and `objects/` (saved R objects). The large BLASTP results file is **not included** in the repository and must be generated before knitting the R Markdown document.

## Requirements

-   R and RStudio, with packages installed using `install_packages.R`.
-   For generating the annotation file: a Linux/macOS terminal (or equivalent Linux environment), `curl`, `gzip`, and NCBI BLAST+ (`makeblastdb` and `blastp`), plus enough free disk space, memory, and time. A computing cluster is recommended for the full protein search.
-   Internet access for downloading sequence/database files, installing R packages, and accessing GO annotation data during the analysis.

## 1. Download the repository

Clone the repository and extract it. Keep the `.Rmd` file and `inputs/` folder in the layout shown above. The count matrix and metadata should already be in `inputs/`.

## 2. Generate the BLASTP annotation file (required)

The analysis expects this compressed file:

``` text
inputs/Perrie_v1.0_blast_results.tsv.gz
```

The commands below are intended to be run locally from the root of the downloaded repository in a Linux/macOS terminal, though HPC is likely needed. They create the BLAST database and output in a separate `blast_work/` folder; only the final compressed result is placed in `inputs/`.

### Download the basil protein sequences and Swiss-Prot database

``` bash
mkdir -p blast_work inputs
cd blast_work

curl -L --fail -o Perrie_v1.0_proteins.fa \
  "https://basil.breedbase.org/downloads/Ocimum%20basilicum%20cv.%20'Perrie'/Sequences/Perrie_v1.0_proteins.fa"

curl -L --fail -o uniprot_sprot.fasta.gz \
  "https://ftp.uniprot.org/pub/databases/uniprot/current_release/knowledgebase/complete/uniprot_sprot.fasta.gz"

gunzip uniprot_sprot.fasta.gz
```

The Swiss-Prot URL points to the database release at time of analysis. Results may differ from the original analysis if the database has changed.

### Install BLAST+ if it is not already available

Check first:

``` bash
blastp -version
```

If BLAST+ is not installed, install it for the appropriate operating system or use an available cluster module. The original analysis used **NCBI BLAST+ 2.15.0** on Linux. The following commands install that Linux x86-64 build locally in `blast_work/`:

``` bash
curl -L --fail -o ncbi-blast-2.15.0+-x64-linux.tar.gz \
  'https://ftp.ncbi.nlm.nih.gov/blast/executables/blast+/2.15.0/ncbi-blast-2.15.0+-x64-linux.tar.gz'
tar -xzf ncbi-blast-2.15.0+-x64-linux.tar.gz
export PATH="$PWD/ncbi-blast-2.15.0+/bin:$PATH"
blastp -version
```

### Build the database and run BLASTP

``` bash
makeblastdb -in uniprot_sprot.fasta -dbtype prot -parse_seqids -out swissprot

blastp \
  -query Perrie_v1.0_proteins.fa \
  -db swissprot \
  -evalue 1e-5 \
  -outfmt '6 qseqid sseqid pident length mismatch gapopen qstart qend sstart send evalue bitscore stitle' \
  -out Perrie_v1.0_blast_results.tsv
```

### Compress the result and place it in `inputs/`

``` bash
gzip -c Perrie_v1.0_blast_results.tsv > ../inputs/Perrie_v1.0_blast_results.tsv.gz
ls -lh ../inputs/Perrie_v1.0_blast_results.tsv.gz
```

## 3. Install R packages

Open the repository in RStudio, open `install_packages.R`, and run it once to install the required CRAN and Bioconductor packages. Installation may take some time.

The RNA-seq analysis was performed using **R version 4.5.1 (2025-06-13)**.

The following R package versions were used in the original analysis:

| Package       | Version |
|---------------|---------|
| DESeq2        | 1.50.2  |
| stringr       | 1.6.0   |
| ggplot2       | 4.0.3   |
| gridExtra     | 2.3     |
| gplots        | 3.3.0   |
| viridis       | 0.6.5   |
| dplyr         | 1.2.1   |
| tidyr         | 1.3.1   |
| tibble        | 3.3.1   |
| topGO         | 2.62.0  |
| cowplot       | 1.2.0   |
| eulerr        | 7.1.0   |
| VennDiagram   | 1.8.2   |
| GO.db         | 3.22.0  |
| AnnotationDbi | 1.72.0  |

## 4. Run the RNA-seq analysis

Open `calculate_DEGs_deseq2_pub.Rmd` in RStudio and click **Knit**.

The document determines its project directory from the location of the `.Rmd` file, reads the three input files from `inputs/`, and creates `results/` and `objects/` as needed. No changes to absolute file paths or manual `setwd()` commands are required when knitting.

## Reproducibility notes

-   The BLASTP settings above reproduce the original search parameters, but using the current Swiss-Prot database may yield different hits. To reproduce the December 2025 annotation exactly, an archived copy of the Swiss-Prot release used at that time would be needed.
-   The R Markdown analysis also downloads GOA data from an external source, which can change over time.
-   Running BLASTP against a full Swiss-Prot database may take substantial time and disk space. The original workflow used a computing cluster.
-   `blast_work/` contains large intermediate files and should not be committed to GitHub. Consider adding `blast_work/`, `results/`, `objects/`, and `inputs/Perrie_v1.0_blast_results.tsv.gz` to `.gitignore`.
