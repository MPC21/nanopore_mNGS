#!/usr/local/bin/env bash

if [ ! -d "binning_qc" ] ; then
    mkdir -p binning_qc
fi
mkdir "binning_qc/${SAMPLE}"

echo "QC binned MAGs by Checkm..."
# installation through conda
# mamba create -n checkm python=3.9
mamba activate checkm
# mamba install -c bioconda numpy matplotlib pysam hmmer prodigal pplacer
# pip3 install checkm-genome

# upgrade checkm
# pip3 install checkm-genome --upgrade --no-deps

"""
download reference data from
1. https://data.ace.uq.edu.au/public/CheckM_databases
2. https://zenodo.org/record/7401545#.Y44ymHbMJD8
decompress into
"""
# export CHECKM_DATA_PATH=/path/to/checkm_data_dir
# checkm data setRoot <checkm_data_dir>

# checkm usage
checkm lineage_wf -t $(nproc) -x fasta "binning/${SAMPLE}/bins" "binning_qc/${SAMPLE}"

mamba deactivate