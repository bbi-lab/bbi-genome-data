#!/bin/bash

#
# Variable definitions used for source genome data files.
#

module purge
source /etc/profile.d/modules.sh
module load modules modules-init modules-gs
module load samtools/1.9
module load bedtools/2.29.2


#
# Executable paths.
#
MD5_SEQ="/net/bbi/vol1/data/sw_install/sequtils/bin/md5_seq"
FASTA_GETSEQS="/net/bbi/vol1/data/sw_install/sequtils/bin/fasta_getseqs"
SAMTOOLS="samtools"
BEDTOOLS="bedtools"

#
# Files.
#
if [ "${GENOME_SOURCE}" == "ensembl" ]
then
  CHECKSUMS="CHECKSUMS"
  README="README"
elif [ "${GENOME_SOURCE}" == "gencode" ]
then
  CHECKSUMS="MD5SUMS"
  README="_README.TXT"
else
  echo "Error: unknown GENOME_SOURCE"
  exit -1
fi

FINAL_IDS_FILE="sequences_to_keep.txt"
