#!/usr/local/bin/env bash

if [ ! -d "MAGs" ] ; then
    mkdir -p MAGs
fi
mkdir "MAGs/${SAMPLE}"

echo "MAG classification by sourmash against Genbank database..."
mamba activate sourmash

for bin in binning/${SAMPLE}/bins/*.fasta; do 
    # get signatures from binned contigs
    sourmash sketch dna -p scaled=1000,k=31,abund --name-from-first ${bin} -o "MAGs/${SAMPLE}/${bin}.sig"
    # sourmash sketch dna -p k=31,abund SRR8859675*.gz -o SRR8859675.sig.gz --name SRR8859675
    # find matching genome 
    sourmash gather "MAGs/${SAMPLE}/${bin}.sig" database/genbank/genbank.zip -o "MAGs/${SAMPLE}/${bin}.csv"
done

mamba deactivate

"""
# Another Option
sourmash gather contigs.sig RefSeq.zip --save-matches sourmash_results.zip
sourmash gather contigs.sig sourmash_results.zip -o bin_0.refseq.csv
sourmash tax metagenome -g bin_0.refseq.csv \
    -t refseq_taxonomy_sourmash.sqldb -F human -r order

# prepare SQLite taxonomy spreadsheet for faster access later on
sourmash tax prepare -t refseq_taxonomy_sourmash.csv  \ 
-o refseq_taxonomy_sourmash.sqldb -F sql

sourmash tax metagenome -g bin_0_results.csv \ 
-t ../../../../database/refseq/refseq-abv/2024-07-21_09-17-06/refseq_taxonomy_sourmash.sqldb \ 
-F human -r order
"""