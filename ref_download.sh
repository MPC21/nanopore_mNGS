#!/usr/local/bin/env bash

# download human reference genome (T2T-CHM13v2.0) for host depletion
mkdir -p "reference" && cd reference
wget https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/009/914/755/GCF_009914755.1_T2T-CHM13v2.0/GCF_009914755.1_T2T-CHM13v2.0_genomic.fna.gz
human_reference="GCF_009914755.1_T2T-CHM13v2_genomic.fna.gz"

# download RefSeq database for taxonomic classification
mamba create -n genome_updater -c genome_updater
mamba activate genome_updater
genome_updater.sh -d "refseq" -g "archaea,bacteria,fungi,protozoa,viral" \ 
-l "complete genome,chromosome" -f "genomic.fna.gz,protein.faa.gz" -o "refseq" \ 
-t $(nproc) -A "species:1" -m -a -p

# Update (e.g. some days later)...?
# genome_updater.sh -o "refseq" -m

genome_updater.sh -d "genbank" -g "archaea,bacteria,fungi,protozoa,viral" \
-l "complete genome,chromosome" -f "genomic.fna.gz,protein.faa.gz" \
-o "refseq-abv" -t $(nproc) -A "species:1" -m -a -p

mamba deactivate

# prepare refseq taxonomy csv file for taxor by taxonkit
cd refseq/2023-03-15_12-56-12
mkdir -p taxdump
# download taxdump.tar.gz from NCBI
tar -zxvf taxdump.tar.gz -C taxdump

mamba create -n taxonkit -c taxonkit
mamba activate taxonkit
cut -f 1,7,20 assembly_summary.txt | \
taxonkit lineage -i 2 -r -n -L --data-dir taxdump | \
taxonkit reformat -I 2 -P -t --data-dir taxdump | \
cut -f 1,2,3,4,6,7 > refseq_accessions_taxonomy.csv
mamba deactivate

# build the hierarchical interleaved XOR filter (HIXF) index:
mamba create -n taxor -c taxor
mamba activate taxor
taxor build --input-file refseq_accessions_taxonomy.csv \ 
--input-sequence-dir files \ 
--output-filename ../refseq-abfv-k22-s12.hixf --threads $(nproc) \
--kmer-size 22 --syncmer-size 12 --use-syncmer 

# build custom database for sourmash (other than GTDB or genbank)
git clone https://github.com/sourmash-bio/database-examples.git

# build a 'fromfile' for sourmash to use
# ./fasta-to-fromfile.py <reference.fasta/fa/fna.gz> -o build.csv
or
./genbank-to-fromfile.py file/* -o build.csv -S assembly_summary.txt
# missing protein files: .error.report.txt
# Names for the genomes are taken from the NCBI assembly_summary.txt

# build the signature database using sourmash
sourmash sketch fromfile build.csv -o ../RefSeq.zip -p dna