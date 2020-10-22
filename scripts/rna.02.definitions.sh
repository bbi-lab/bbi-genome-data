#!/bin/bash

#
# Variable definitions used for atac data files.
#

module purge
source /etc/profile.d/modules.sh
module load modules modules-init modules-gs
module load bedtools/2.29.2
module load gmp/6.1.2
module load mpfr/4.0.1
module load gcc/8.1.0
module load STAR/2.6.1d


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
