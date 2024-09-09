Nanopore Metagenomics: Bash script to integrate mainly command-line tools for nanopore metagenomics from direct clinical specimens for taxonomic classification and antimicrobial resistance detection

Workflow of nanopore_mNGS pipeline:

1. Data preparation
a. Make sure your have nanopore sequencing data in the sample directory.
b. Reference will be download by ref_download.sh if no reference data exists.

2. Raw reads will undergo quality evaluation and filtering by qc_filtering.sh
Nanopack2:

3. Host genome will be depleted from filtered reads by host_depletion.sh

4. Taxonomic classification of depleted reads by taxor through taxonomic_classification.sh

5. Depleted reads will also be assembled by flye to generate contigs through assembly.sh

6. Contigs will undergo binning by MetaCoAG to generate MAGs through binning.sh

7. Qulaity control of binning results by checkm qc_binning.sh

8. Classification for MAGs using sourmash in MAG_classification.sh

9. Detection of AMR genes, plasmids and virulence factors by abricate abricate_APV.sh

10. Abricate through hAMRonization.sh