#!/usr/local/bin/env bash

if [ ! -d "assembly" ] ; then
    mkdir -p assembly
fi
mkdir "assembly/${SAMPLE}"

"""assembly and binning"""
echo "Genome assembly with metaflye..."
# mamba create -n flye flye
mamba activate flye # $ --nanp-raw / --nano-hq
flye --nano-hq "dehost/${SAMPLE}_dehost.fastq.gz" \ 
--out-dir "assembly/${SAMPLE}" --meta --read-error 0.03 --threads $(nproc)

# mv assembly/${SAMPLE}/assembly.fasta assembly/${SAMPLE}/${SAMPLE}_assembly.fasta
# mv assembly/${SAMPLE}/assembly_graph.gfa assembly/${SAMPLE}/${SAMPLE}_assembly_graph.gfa
# mv assembly/${SAMPLE}/assembly_info.txt assembly/${SAMPLE}/${SAMPLE}_assembly_info.txt

mamba deactivate