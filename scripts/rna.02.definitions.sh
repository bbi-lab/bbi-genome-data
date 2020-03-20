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
## RNA_DIR="${STAGE_DIR}/${ORGANISM}"
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
## # Log file tag for pulling key information from the log files.
## #
## TAG_DATE=`date '+%Y%m%d:%H%M%S'`
## TAG="TAG_${TAG_DATE}"


module purge
source /etc/profile.d/modules.sh
module load modules modules-init modules-gs
module load bedtools/2.28.0
module load mpfr/2.4.1
module load gmp/6.1.2
module load gcc/4.7.0
module load STAR/2.5.2b


#
# Executable paths.
#
STAR_ALIGNER="STAR"
BEDTOOLS="bedtools"
DATAMASH_PATH="/net/bbi/vol1/data/sw_install/datamash-1.0.6/bin/datamash"


#
# star aligner index name.
#
INDEX_PREFIX="$ORGANISM"
 
#
# Files.
#
# Use Jonathan's file names embedded in the rna.*.sh scripts.
#
