#!/bin/bash

#
# Variable definitions used for source genome data files.
#

##
## in all.02.definitions.sh
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
module load samtools/1.9
module load bedtools/2.28.0


#
# Executable paths.
#
#MD5_SEQ="/net/bbi/vol1/data/src/sequtil/md5_seq"
#FASTA_GETSEQS="/net/bbi/vol1/data/src/sequtil/fasta_getseqs"
MD5_SEQ="/net/gs/vol1/home/bge/eclipse-workspace/bbi-genome-data/src/sequtil/md5_seq"
FASTA_GETSEQS="/net/gs/vol1/home/bge/eclipse-workspace/bbi-genome-data/src/sequtil/fasta_getseqs"
SAMTOOLS="samtools"
BEDTOOLS="bedtools"

#
# Files.
#
CHECKSUMS="CHECKSUMS"
README="README"
LOG="${GENOME_DIR}/log.out"
FINAL_IDS_FILE="sequences_to_keep.txt"
