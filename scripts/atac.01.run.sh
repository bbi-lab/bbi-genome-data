#!/bin/bash

#
# Build atac files.
#


if [ "$1" == "" ]
then
  echo "Usage: atac.01.run.sh <organism_name>"
  exit -1
fi


set -o pipefail  # trace ERR through pipes
set -o errtrace  # trace ERR through 'time command' and other functions
set -o nounset   # set -u : exit the script if you try to use an uninitialised variable
set -o errexit   # set -e : exit the script if any statement returns a non-true return value


SCRIPT_DIR="."
source ${SCRIPT_DIR}/all.00.definitions.sh


ORGANISM_NAME="$1"
ORGANISM_DEFINITION_FILE="${ORGANISM_FILE_DIR}/genome.${ORGANISM_NAME}.sh"
if [ ! -f "$ORGANISM_DEFINITION_FILE" ]
then
  echo "ERROR: unable to find file \'$ORGANISM_DEFINITION_FILE\' for organism $ORGANISM_NAME. Exiting."
  exit -1
fi


source $ORGANISM_DEFINITION_FILE
source ${SCRIPT_DIR}/all.02.definitions.sh
source ${SCRIPT_DIR}/atac.02.definitions.sh
source ${SCRIPT_DIR}/atac.03.make_bed_files.sh
source ${SCRIPT_DIR}/atac.04.make_aligner_index.sh
source ${SCRIPT_DIR}/atac.05.misc.sh

source ${SCRIPT_DIR}/atac.10.make_clean_directory.sh


mkdir -p $ATAC_DIR

pushd $ATAC_DIR

setup_source_files
make_whitelist_regions_file
make_tss_file
compress_tss_temp_file
make_gene_bodies_file
compress_gene_bodies_temp_file
estimate_effective_genome_size
make_aligner_index
make_clean_directory

popd

