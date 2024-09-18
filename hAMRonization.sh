#!/usr/local/bin/env bash

# docker installation
# docker pull finlaymaguire/hamronization:latest
# https://github.com/pha4ge/hAMRonization

# mamba create --name hamronization --channel conda-forge --channel bioconda --channel defaults hamronization
mamba activate hamronization
hamronize abricate "abricate/${SAMPLE}/amr_summary.txt" \
--reference_database_version 3.2.5 --analysis_software_version 1.0.0 \ 
--format tsv --output "hamronize/${SAMPLE}/"
# tsv or json
mamba deactivate


