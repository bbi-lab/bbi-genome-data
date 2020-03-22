#!/bin/bash

#
# Build atac files.
#

set -o pipefail  # trace ERR through pipes
set -o errtrace  # trace ERR through 'time command' and other functions
set -o nounset   # set -u : exit the script if you try to use an uninitialised variable
set -o errexit   # set -e : exit the script if any statement returns a non-true return value

ORGANISM="$1"

if [ "$ORGANISM" == "" ]
then
  echo "Usage: atac.01.run.sh <organism>"
  exit -1
fi


ORGANISM_FILE="genome.${ORGANISM}.sh"
if [ ! -f "$ORGANISM_FILE" ]
then
  echo "Unable to find file \'$ORGANISM_FILE\' for organism $ORGANISM"
  exit -1
fi



SCRIPT_DIR="."

source ${SCRIPT_DIR}/$ORGANISM_FILE
source ${SCRIPT_DIR}/all.02.definitions.sh
source ${SCRIPT_DIR}/atac.02.definitions.sh
source ${SCRIPT_DIR}/atac.03.make_bed_files.sh
source ${SCRIPT_DIR}/atac.04.make_aligner_index.sh
source ${SCRIPT_DIR}/atac.10.make_clean_directory.sh


mkdir -p $ATAC_DIR

pushd $ATAC_DIR

setup_source_files
make_whitelist_regions_file
make_tss_file
compress_tss_temp_file
make_gene_bodies_file
compress_gene_bodies_temp_file
make_aligner_index
make_clean_directory

popd

