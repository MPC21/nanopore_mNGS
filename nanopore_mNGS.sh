#!/usr/local/bin/env bash

# Check if the "sample" directory exists and create it if not

main() {
    # Quality evaluation and filtering by NanoPlot and Chopper from NanoPack2 
    time ./qc_filtering.sh
    # Host depletion using T2T-CHM13v2 human reference genome
    time ./host_depletion.sh
    # Taxonomic classification of dehost reads by taxor
    time ./taxonomic_classification.sh
    # De novo assembly of dehost reads by flye
    time ./assembly.sh
    # Binning of assembled contigs by MetaCoAG
    time ./binning.sh
    # Quality evaluation of bins by checkm
    time ./qc_binning.sh
    # MAGs classification by sourmash
    time ./MAG_classification.sh
    # AMR genes, PlasmidFinder and Viruluence
    time ./abricate_APV.sh
    # Sample Raw sequences archiving
    time ./archive.sh
}

if [ ! -d "log" ] ; then
    mkdir -p log
fi

if [ -d "sample" ]; then
    for file in sample/*.fastq(.gz)?; do
        if [ -e "$file" ]; then
            echo "Sample Directory exists and has content. Metagenomic Analysis will begin..."
            SAMPLE=$(basename "$file" | sed -E 's/\.fastq\(\.gz\)\?$//')
            if [[ ! "$SAMPLE" =~ _[12] ]]; then
                # SAMPLE=$(basename "$file" | sed -E '/^((?!.*_[12]).)*$/s/\.fastq(\.gz)?$//')   
                timestamp=$(date "+%Y%m%d-%H%M%S")
                echo "Analysis of sample ${SAMPLE} begins..." 
                time main 2>&1 | tee "log/${SAMPLE}_${timestamp}.log"
                echo "Analysis of sample ${SAMPLE} has been finished!"
            fi
        else
            echo "Sample Directory exists but with NO nanopore sequencing data. Please put your raw sequencing files for initation of sequencing analysis!"
            exit 0
        fi
    done
else
    echo "Sample directory does not exist!"
    mkdir -p "sample"
    echo "Sample directory has now been created. Please put your raw sequencing files for initation of sequencing analysis!"
    exit 1
fi