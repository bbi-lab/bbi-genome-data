#!/bin/bash

#
# Build atac files.
#

ORGANISM="$1"

if [ "$ORGANISM" == "" ]
then
  echo "Usage: genome.01.setup_genome_source.sh <organism>"
  exit -1
fi


ORGANISM_FILE="genome.${ORGANISM}.sh"
if [ ! -f "$ORGANISM_FILE" ]
then
  echo "Unable to file \'$ORGANISM_FILE\' for organism $ORGANISM"
  exit -1
fi



SCRIPT_DIR="."

source ${SCRIPT_DIR}/$ORGANISM_FILE
source ${SCRIPT_DIR}/all.02.definitions.sh
source ${SCRIPT_DIR}/atac.02.definitions.sh
source ${SCRIPT_DIR}/atac.03.make_gene_bed_files.sh
source ${SCRIPT_DIR}/atac.04.make_aligner_indices.sh
source ${SCRIPT_DIR}/atac.10.remove_unnecessary_files.sh


mkdir -p $ATAC_DIR

pushd $ATAC_DIR


setup_source_files
make_whitelist_regions_file
make_tss_file
compress_tss_temp_file
make_gene_bodies_file
compress_gene_bodies_temp_file
make_aligner_index
#remove_unnecessary_files

popd

