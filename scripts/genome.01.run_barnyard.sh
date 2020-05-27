#!/bin/bash

#
# Build source barnyard genome files.
# This script requires that the human and mouse files
# are in the human_gsrc and mouse_gsrc directories;
# that is, it does not download the files from Ensembl
# or make the 'finished' fasta files, etc.
#


set -o pipefail  # trace ERR through pipes
set -o errtrace  # trace ERR through 'time command' and other functions
set -o nounset   # set -u : exit the script if you try to use an uninitialised variable
set -o errexit   # set -e : exit the script if any statement returns a non-true return value


SCRIPT_DIR="."
#
# Need an absolute path for SCRIPT_DIR in genome.06.barnyard.sh.
#
if [ "$SCRIPT_DIR" == "." ]
then
  SCRIPT_DIR=`pwd`
fi
source ${SCRIPT_DIR}/all.00.definitions.sh


ORGANISM_NAME="barnyard"
ORGANISM_DEFINITION_FILE="${ORGANISM_FILE_DIR}/genome.${ORGANISM_NAME}.sh"
if [ ! -f "$ORGANISM_DEFINITION_FILE" ]
then
  echo "ERROR: unable to find file \'$ORGANISM_DEFINITION_FILE\' for organism $ORGANISM_NAME. Exiting."
  exit -1
fi


source $ORGANISM_DEFINITION_FILE
source ${SCRIPT_DIR}/all.02.definitions.sh
source ${SCRIPT_DIR}/genome.02.definitions.sh
source ${SCRIPT_DIR}/genome.06.barnyard.sh


mkdir -p $GENOME_DIR

pushd $GENOME_DIR

barnyard_setup_source_files
barnyard_compress_finish_fasta_file

popd

