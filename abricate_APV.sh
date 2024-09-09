#!/usr/local/env/bin bash

if [ ! -d "abricate" ] ; then
    mkdir -p abricate
fi
mkdir abricate/${SAMPLE}

# mamba create -n abricate -c conda-forge -c bioconda -c defaults abricate
mamba activate abricate
# abricate --check
# abricate --list

output_amr=abricate/${SAMPLE}/amr.txt
output_pf="abricate/${SAMPLE}/pf.txt"
output_vf="abricate/${SAMPLE}/vf.txt"
log_amr="abricate/${SAMPLE}/amr.log"
log_pf="abricate/${SAMPLE}/pf.log"
log_vf="abricate/${SAMPLE}/vf.log"
  
echo "Abricate AMR" # default --mincov 80
abricate --threads $(nproc) --db abricate binning/${SAMPLE}/bins/*.fasta > "$output_amr" 2> "$log_amr"
echo "Abricate Plasmidfinder"
abricate --threads $(nproc) --db plasmidfinder binning/${SAMPLE}/bins/*.fasta > "$output_pf" 2>"$log_pf"
echo "Abricate Virulence factor"
abricate --threads $(nproc) --db vfdb binning/${SAMPLE}/bins/*.fasta > "$output_vf" 2> "$log_vf"
echo "abricate has been done"
    
echo "abricate summary"
sum_amr="abricate/${SAMPLE}/amr_summary.txt"
sum_pf="abricate/${SAMPLE}/pf_summary.txt"
sum_vf="abricate/${SAMPLE}/vf_summary.txt"

echo "Abricate AMR Summary"
abricate --summary "$input_amr" > "$sum_amr"
echo "Abricate Plasmidfinder Summary"
abricate --summary "$input_pf" > "$sum_pf"
echo "Abricate Virulence factor Summary"
abricate --summary "$input_vf" > "$sum_vf"
echo "abricate summary has been done"

mamba deactivate