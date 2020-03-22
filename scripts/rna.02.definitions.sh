#!/bin/bash

#
# Variable definitions used for atac data files.
#

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
