#!/bin/bash

#
# Variable definitions used for all data files (genome and atac).
#


#
# Staging directory.
#
STAGE_DIR="/net/bbi/vol1/data/genomes/stage_dir"


#
# Output directories.
#   variable       description
#   --------       -----------
#   GENOME_DIR     genome source directory
#   RNA_DIR        sci-RNA-seq files
#   STAR_DIR       STAR aligner index files
#   ATAC_DIR       sci-ATAC-seq files
#
GENOME_DIR="${STAGE_DIR}/${ORGANISM}_gsrc"
RNA_DIR="${STAGE_DIR}/${ORGANISM}_rna"
STAR_DIR="${STAGE_DIR}/${ORGANISM}_star"
ATAC_DIR="${STAGE_DIR}/${ORGANISM}_atac"

#
# Common file names.
#
FASTA=`echo $FASTA_GZ | sed 's/\.gz$//'`
FASTA_FILTERED="${FASTA}.filtered"
FASTA_FINISHED="${FASTA}.finished"
CHROMOSOME_SIZES_FILE="chromosome_sizes.txt"
GTF=`echo $GTF_GZ | sed 's/\.gz$//'`

#
# Barnyard-specific file names.
#
BARNYARD_FASTA_FINISHED="barnyard.fa.finished"
BARNYARD_GTF_GZ="barnyard.gtf.gz"

#
# Log file tag from pulling key information from the log files.
#
TAG_DATE=`date '+%Y%m%d:%H%M%S'`
TAG="TAG_${TAG_DATE}"
