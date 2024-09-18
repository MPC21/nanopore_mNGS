#!/usr/local/bin/env bash

if [ ! -d "taxor_result" ] ; then
    mkdir -p taxor_result
fi

# taxor="taxor_result"

echo "Taxonomic classification from long read metagenomics sequencing data with Taxor against RefSeq database..."
# mamba create -n taxor -c taxor
mamba activate taxor
"""
# build the hierarchical interleaved XOR filter (HIXF) index: done in ref_download.sh
taxor build --input-file refseq_accessions_taxonomy.csv \ 
--input-sequence-dir refseq/2023-03-15_12-56-12/files \ 
--output-filename refseq-abfv-k22-s12.hixf --threads $(nproc) \
--kmer-size 22 --syncmer-size 12 --use-syncmer
"""
# query the sample fastq file against the index allowing 15% error rate
taxor search --index-file database/refseq-abv/refseq-abfv-k22-s12.hixf \
--query-file "sample/${SAMPLE}.fastq.gz" --output-file "taxor_result/${SAMPLE}_search.txt" \
--error-rate 0.15 --threads $(nproc)

# taxonomy profiling: input SAMPLE.search.txt
taxor profile --search-file "${taxor}/${SAMPLE}_search.txt" \
--cami-report-file "taxor_result/${SAMPLE}.report" --seq-abundance-file "taxor_result/${SAMPLE}.abundance" \
--binning-file "taxor_result/${SAMPLE}.binning" --sample-id ${SAMPLE} --threads $(nproc)

mamba deactivate

"""
Output: 
1. taxonomic abundances
2. sequence abundances in CAMI report format
3. binning file with final read to reference assignments
"""