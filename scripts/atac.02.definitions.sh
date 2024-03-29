#!/bin/bash

#
# Variable definitions used for atac data files.
#

module purge
source /etc/profile.d/modules.sh
module load modules modules-init modules-gs
module load tbb/2020_U2
module load bedtools/2.29.2
module load gcc/8.1.0
module load R/3.6.1

#
# Executable paths.
#
BEDTOOLS="bedtools"
BOWTIE2_BUILD="/net/bbi/vol1/data/sw_install/bowtie2-2.4.1/bin/bowtie2-build"
FACOUNT="/net/bbi/vol1/data/sw_install/kent_util/bin/faCount"


#
# R scripts.
#
R_GENERATE_TSS_FILE="/net/bbi/vol1/data/scripts/bbi-genome-data/R/generate_tss_file.R"
R_GENERATE_GENE_BODY_FILE="/net/bbi/vol1/data/scripts/bbi-genome-data/R/generate_gene_body_file.R"

#
# bowtie2-build index prefix.
#
INDEX_PREFIX="$ORGANISM"

#
# Files.
#
CHROMOSOME_SIZES_FASTA_FINISHED_FILE="chromosome_sizes_fasta_finished.txt"
CHROMOSOME_SIZES_ATAC_FILE="chromosome_sizes_atac.txt"
CHROMOSOME_WITH_MT_SIZES_ATAC_FILE="chromosome_with_mt_sizes_atac.txt"
WHITELIST_REGIONS_BED="whitelist_regions.bed"
WHITELIST_WITH_MT_REGIONS_BED="whitelist_with_mt_regions.bed"
TSS_BED="tss.bed"
TSS_FOUND_BIOTYPES_FILE="tss.found_biotypes.lst"
TSS_SELECT_BIOTYPES_FILE="tss.select_biotypes.lst"
TSS_SELECTED_BIOTYPE_COUNTS="tss.selected_biotype.counts.lst"
TSS_GENE_MAP="tss_gene_map.txt"
GENE_BODIES_BED="gene_bodies.bed"
GENE_BODIES_PLUS_UPSTREAM_BED="gene_bodies.plus_2kb_upstream.bed"
GENE_BODIES_FOUND_BIOTYPES_FILE="gene_bodies.found_biotypes.lst"
GENE_BODIES_SELECTED_BIOTYPE_COUNTS="gene_bodies.selected_biotype.counts.lst"
GENE_BODIES_SELECT_BIOTYPES_FILE="gene_bodies.select_biotypes.lst"
GENE_BODIES_GENE_MAP="gene_bodies_gene_map.txt"
EFFECTIVE_GENOME_SIZE="effective_genome_size.txt"

