#!/usr/local/bin/env bash

"""MAG generation"""
# metaflye assembly, 5 rounds of iteration
flye --nano-raw --meta --iteration 5 --threads $(nproc) \ 
$dehost/$(SAMPLE)_dehost.fastq.gz --out-dir assembly/$(SAMPLE) 

"""4 rounds of Racon polishing"""
# git clone https://github.com/lbcb-sci/racon && cd racon && mkdir build && cd build
# cmake -DCMAKE_BUILD_TYPE=Release .. && make
# racon -t $(nproc) <sequences> <overlaps> <target sequences>

assembly="assembly/$(SAMPLE)/assembly.fasta"
reads="$dehost/$(SAMPLE)_dehost.fastq.gz"

for i in {1..4}
do
    echo "Round $i of polishing"
    if [ $i -eq 1 ]; then
        input=$assembly
    else
        input="assembly/$(SAMPLE)/polished$((i-1)).fasta"
    fi
    
    minimap2 -ax map-ont $input $reads > aln$i.sam
    racon -t $(nproc) $reads aln$i.sam $input > assembly/$(SAMPLE)/polished$i.fasta
done

echo "Polishing complete. Final assembly is assembly/$(SAMPLE)/polished4.fasta"

"""1 round of medaka"""
# virtualenv medaka --python=python3 --prompt "(medaka) "
# . medaka/bin/activate
# pip install --upgrade pip
# pip install medaka

source ${MEDAKA}  # i.e. medaka/venv/bin/activate
DRAFT=assembly/$(SAMPLE)/polished4.fasta
OUTDIR=medaka_consensus
medaka_consensus -i ${reads} -d ${DRAFT} -o ${OUTDIR} -t $(nproc) \
-m r1041_e82_400bps_hac_g632

# BUSCO
busco -i $input_assembly -o $output_dir -m genome -l $BUSCO_LINEAGE -c $(nproc)

""""""
#!/bin/bash

# Set variables
READS="path/to/your/nanopore_reads.fastq"
THREADS=16  # Adjust based on your system
GENOME_SIZE="10m"  # Adjust based on your expected metagenome size
OUTPUT_DIR="metaflye_output"
ITERATIONS=5
BUSCO_LINEAGE="bacteria_odb10"  # Adjust based on your expected organisms

# Function to run metaFlye
run_metaflye() {
    local iteration=$1
    local input_reads=$2
    local output_dir="${OUTPUT_DIR}/iteration_${iteration}"
    
    flye --nano-raw $input_reads --out-dir $output_dir --meta --genome-size $GENOME_SIZE --threads $THREADS
    
    echo "${output_dir}/assembly.fasta"
}

# Function to run Racon
run_racon() {
    local input_assembly=$1
    local iteration=$2
    
    minimap2 -ax map-ont -t $THREADS $input_assembly $READS > aln.sam
    racon -t $THREADS $READS aln.sam $input_assembly > racon_polished_${iteration}.fasta
    
    echo "racon_polished_${iteration}.fasta"
}

# Function to run Medaka
run_medaka() {
    local input_assembly=$1
    
    medaka_consensus -i $READS -d $input_assembly -o medaka_output -t $THREADS -m r941_min_high_g360
    
    echo "medaka_output/consensus.fasta"
}

# Function to run BUSCO
run_busco() {
    local input_assembly=$1
    local stage=$2
    local output_dir="busco_${stage}"
    
    busco -i $input_assembly -o $output_dir -m genome -l $BUSCO_LINEAGE -c $THREADS
    
    echo "BUSCO analysis for ${stage} completed. Results in ${output_dir}"
}

# Main workflow
current_assembly=$READS

# Run metaFlye iterations
for i in $(seq 1 $ITERATIONS); do
    echo "Running metaFlye iteration $i"
    current_assembly=$(run_metaflye $i $current_assembly)
done

# Run BUSCO on final metaFlye assembly
echo "Running BUSCO on final metaFlye assembly"
run_busco $current_assembly "metaflye"

# Run Racon polishing
for i in $(seq 1 4); do
    echo "Running Racon polishing round $i"
    current_assembly=$(run_racon $current_assembly $i)
done

# Run BUSCO on Racon-polished assembly
echo "Running BUSCO on Racon-polished assembly"
run_busco $current_assembly "racon"

# Run Medaka polishing
echo "Running Medaka polishing"
final_assembly=$(run_medaka $current_assembly)

# Run BUSCO on final Medaka-polished assembly
echo "Running BUSCO on final Medaka-polished assembly"
run_busco $final_assembly "medaka"

echo "Final polished assembly: $final_assembly"
echo "BUSCO analyses completed for metaFlye, Racon, and Medaka stages"

https://github.com/jwanglab/fmlrc2