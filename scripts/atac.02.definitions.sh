#!/bin/bash

#
# Variable definitions used for atac data files.
#

## in all.02.definitions.sh
## 
## #
## # Staging directory.
## #
## STAGE_DIR="/net/bbi/vol1/data/genomes/stage_dir"
## 
## #
## # Output directories.
## #   variable       description
## #   --------       -----------
## #   GENOME_DIR     genome source directory
## #   RNA_DIR        sci-RNA-seq files
## #   STAR_DIR       STAR aligner index files
## #   ATAC_DIR       sci-ATAC-seq files
## #
## GENOME_DIR="${STAGE_DIR}/${ORGANISM}_gsrc"
## RNA_DIR="${STAGE_DIR}/${ORGANISM}_rna"
## STAR_DIR="${STAGE_DIR}/${ORGANISM}_star"
## ATAC_DIR="${STAGE_DIR}/${ORGANISM}_atac"
## 
## #
## # Common file names.
## #
## FASTA=`echo $FASTA_GZ | sed 's/\.gz$//'`
## FASTA_FILTERED="${FASTA}.filtered"
## FASTA_FINISHED="${FASTA}.finished"
## CHROMOSOME_SIZES_FILE="chromosome_sizes.txt"
## GTF=`echo $GTF_GZ | sed 's/\.gz$//'`
## 
## #
## # Barnyard-specific file names.
## #
## BARNYARD_FASTA_FINISHED="barnyard.fa.finished"
## BARNYARD_GTF_GZ="barnyard.gtf.gz"
## 
## #
## # Log file tag from pulling key information from the log files.
## #
## TAG_DATE=`date '+%Y%m%d:%H%M%S'`
## TAG="TAG_${TAG_DATE}"


module purge
source /etc/profile.d/modules.sh
module load modules modules-init modules-gs
module load tbb/2019_U5
module load bedtools/2.28.0
module load R/3.6.1
module load gcc/8.1.0

#
# Executable paths.
#
BEDTOOLS="bedtools"
BOWTIE2_BUILD="/net/bbi/vol1/data/sw_install/bowtie2-2.4.1/bin/bowtie2-build"


#
# R scripts.
#
R_GENERATE_TSS_FILE="/net/gs/vol1/home/bge/eclipse-workspace/bbi-genome-data/R/generate_tss_file.R"
R_GENERATE_GENE_BODY_FILE="/net/gs/vol1/home/bge/eclipse-workspace/bbi-genome-data/R/generate_gene_body_file.R"

#
# bowtie2-build index prefix.
#
INDEX_PREFIX="$ORGANISM"
 
#
# Files.
#
LOG="${ATAC_DIR}/log.out"
CHROMOSOME_SIZES_FILE="chromosome_sizes.txt"
WHITELIST_REGIONS_BED="whitelist_regions.bed"
TSS_BED="tss.bed"
TSS_FOUND_BIOTYPES_FILE="tss.found_biotypes.lst"
TSS_SELECT_BIOTYPES_FILE="tss.select_biotypes.lst"
TSS_GENE_MAP="tss_gene_map.txt"
GENE_BODIES_BED="gene_bodies.bed"
GENE_BODIES_PLUS_UPSTREAM_BED="gene_bodies.plus_2kb_upstream.bed"
GENE_BODIES_FOUND_BIOTYPES_FILE="gene_bodies.found_biotypes.lst"
GENE_BODIES_SELECT_BIOTYPES_FILE="gene_bodies.select_biotypes.lst"
GENE_BODIES_GENE_MAP="gene_bodies_gene_map.txt"

