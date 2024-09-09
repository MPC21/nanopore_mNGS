#!/usr/local/bin/env bash

# Check if the "sample" directory exists and create it if not
if [ -d "sample" ]; then
    for file in sample/*.fastq.gz; do
        if [ -e "$file" ]; then
            echo "Sample Directory exists and has content. Metagenomic Analysis will begin..."
            SAMPLE=$(basename "$file" | sed -E 's/\.fastq.gz//')   
            echo "Analysis begins for sample $SAMPLE..." 
            # Quality evaluation and filtering by NanoPlot and Chopper from NanoPack2 
            ./qc_filtering.sh
            # Host depletion using T2T-CHM13v2 human reference genome
            ./host_depletion.sh
            # Taxonomic classification of dehost reads by taxor
            ./taxonomic_classification.sh
            # De novo assembly of dehost reads by flye
            ./assembly.sh
            # Binning of assembled contigs by MetaCoAG
            ./binning.sh
            # Quality evaluation of bins by checkm
            ./qc_binning.sh
            # MAGs classification by sourmash
            ./MAG_classification.sh
            # AMR genes, PlasmidFinder and Viruluence
            ./abricate_APV.sh

        else
            echo "Sample Directory exists but with NO sequencing data. Please put your raw sequencing files for initation of sequencing analysis!"
            exit 0
        fi
    done
else
    echo "Sample directory does not exist!"
    mkdir -p "sample"
    echo "Sample directory has now been created. Please put your raw sequencing files for initation of sequencing analysis!"
    exit 1
fi




