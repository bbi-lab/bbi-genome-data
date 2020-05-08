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

DEFINITION="barnyard"


DEFINITION_FILE="genome.${DEFINITION}.sh"
if [ ! -f "$DEFINITION_FILE" ]
then
  echo "ERROR: unable to find file \'$DEFINITION_FILE\' for organism $DEFINITION. Exiting."
  exit -1
fi


SCRIPT_DIR="."
if [ "$SCRIPT_DIR" == "." ]
then
  SCRIPT_DIR=`pwd`
fi

source ${SCRIPT_DIR}/$DEFINITION_FILE
source ${SCRIPT_DIR}/all.02.definitions.sh
source ${SCRIPT_DIR}/genome.02.definitions.sh
source ${SCRIPT_DIR}/genome.06.barnyard.sh


mkdir -p $GENOME_DIR

pushd $GENOME_DIR

barnyard_setup_source_files
barnyard_compress_finish_fasta_file

popd

