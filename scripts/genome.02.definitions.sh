#!/bin/bash

#
# Variable definitions used for source genome data files.
#

module purge
source /etc/profile.d/modules.sh
module load modules modules-init modules-gs
module load samtools/1.9
module load bedtools/2.28.0


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
CHECKSUMS="CHECKSUMS"
README="README"
FINAL_IDS_FILE="sequences_to_keep.txt"
