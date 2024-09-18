#!/usr/local/bin/env bash

# Check if the "qc_raw" and "qc_filtered" directory exists and create it if not
if [ ! -d "qc_raw" ] || [ ! -d "qc_filtered" ]; then
    mkdir -p qc_raw qc_filtered
fi

# qc_raw="qc_raw"
# qc_filtered="qc_filtered"

# input .fastq/.fastq.gz
echo "QC the raw data from genome sequencer by nanoplot..."
# mamba create -n nanoplot -c nanoplot
mamba activate nanoplot
NanoPlot -t $(nproc) --fastq "sample/${SAMPLE}.fastq.gz" --outdir "qc_raw/${SAMPLE}/"
mamba deactivate

echo "Quality filtering and trimming: chopper for Q10 & >=1000bp..."
# recommend gunzip .fastq.gz for faster processing
# mamba create -n chopper -c chopper
mamba activate chopper
gunzip -c "sample/${SAMPLE}.fastq.gz" | chopper -q 10 -l 1000 | \
gzip > "sample/${SAMPLE}_filtered.fastq.gz"
mamba deactivate

echo "QC filtered sequences by nanoplot..."
mamba activate nanoplot
NanoPlot -t $(nproc) --fastq "sample/${SAMPLE}_filtered.fastq.gz" --outdir "qc_filtered/${SAMPLE}/"
mamba deactivate

"""
Wouter De Coster, Rosa Rademakers. NanoPack2: population-scale evaluation of long-read sequencing data. Bioinformatics, Volume 39, Issue 5, May 2023, btad311.
https://github.com/wdecoster/nanopack.git
"""

"""
# mamba create -n fastqc -c fastqc
# mamba activate fastqc
fastqc ${SN}_1.fastq.gz ${SN}_2.fastq.gz --outdir=<$PATH>
fastqc -t $(nproc) <FASTQ>/*.fastq.gz -o <$PATH>
# mamba deactivate
"""
