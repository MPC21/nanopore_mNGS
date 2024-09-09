#!/usr/local/bin/env bash

if [ ! -d "binning" ] ; then
    mkdir -p binning
fi
mkdir binning/${SAMPLE}

# binning by MetCoAG
"""requirement:
1. flye assembly (from assembly.sh)
2. abundance.tsv by CoverM
"""
# mamba create -n coverm coverm
mamba activate coverm
coverm contig --single dehost/${SAMPLE}_dehost.fastq.gz \ 
-r assembly/${SAMPLE}/assembly.fasta \ 
-o binning/${SAMPLE}/abundance.tsv -t $(nproc)
# remove the header of the file
sed -i '1d' binning/${SAMPLE}/abundance.tsv	
mamba deactivate

# mamba create -n metacoag -c bioconda metacoag
mamba activate metacoag
metacoag --assembler flye --nthreads $(nproc) \ 
--graph assembly/${SAMPLE}/assembly_graph.gfa \ 
--contigs assembly/${SAMPLE}/assembly.fasta \ 
--paths assembly/${SAMPLE}/assembly_graph.txt \ 
--abundance binning/${SAMPLE}/abundance.tsv --output binning/${SAMPLE}

mamba deactivate

"""
Output:
1. contig_to_bin.tsv containing the comma separated records of contig id, bin number
2. bins containing the identified bins (FASTA file for each bin)
3. low_quality_bins containing the identified low-quality bins, 
i.e., having a fraction of marker genes lower than bin_mg_threshold (FASTA file for each bin)
4. *.frag.faa, *.frag.ffn and *.frag.gff files containing FragGeneScan output
5. *.hmmout containing HMMER output
"""


"""
BASALT: binning and post-binning refinement
git clone https://github.com/EMBL-PKU/BASALT.git
cd BASALT
python BASALT_setup.py
mamba env create -n BASALT --file basalt_env.yml
chmod -R 777 <PATH_TO_CONDA>/envs/BASALT/bin/*
# Download the trained models for neural networks
wget https://figshare.com/ndownloader/files/41093033
mv 41093033 BASALT.zip
mv BASALT.zip ~/.cache
cd ~/.cache
unzip BASALT.zip

BASALT [-h] [-a ASSEMBLIES] [-s SR_DATASETS] [-l LONG_DATASETS] \ 
[-hf HIFI_DATASET] [-c HI_C_DATASET] [-t THREADS] [-m RAM] \ 
[-e EXTRA_BINNER] [-qc QC_SOFTWARE] [--min-cpn MIN_COMPLETENESS] \ 
[--max-ctn MAX_CONTAMINATION] [--mode RUNNING_MODE] \
[--module FUNCTIONAL_MODULE] [--autopara AUTOBINING_PARAMETERS] \ 
[--refinepara REFINEMENT_PARAMTER]![image](https://github.com/EMBL-PKU/BASALT/assets/62051720/61fb5b05-2844-4867-9598-f91e0709fa9a)

BASALT -a as1.fa,as2.fa,as3.fa \
-s srs1_r1.fq,srs1_r2.fq/srs2_r1.fq,srs2_r2.fq \
-l lr1.fq,lr2.fq -hf hifi1.fq \
-t $(nproc) -m 250 \    # -m: RAM
--autopara sensitive --refinepara quick --min-cpn 40 \ 
--max-ctn 15 -qc checkm2
"""