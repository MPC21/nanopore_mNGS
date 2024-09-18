#!/usr/local/bin/env bash

if [ ! -d "dehost" ] ; then
    mkdir -p dehost
fi

# dehost="dehost"
echo "Host depletion with human genome (T2T-CHM13v2.0)..."
# host depletion from quality filtered sequence .fastq/.fastq.gz
# Minimap2-fpga with human genome (T2T-CHM13v2.0) and samtools
# mamba create -n minimap2 minimap2
# sudo apt install samtools
# mamba activate minimap2
human_reference="database/GCF_009914755.1_T2T-CHM13v2_genomic.fna.gz"
minimap2 -ax map-ont "${human_reference}" "qc_filtered/${SAMPLE}_filtered.fastq.gz" | \
samtools view -@ $(nproc) -bh -f 4 | \    # -f 4 for long-read?
samtools fastq -@ $(nproc) | gzip > "dehost/${SAMPLE}_dehost.fastq.gz"
# mamba deactivate