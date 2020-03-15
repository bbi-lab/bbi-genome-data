#!/bin/bash

#
# Build source barnyard genome files.
# This script requires that the human and mouse files
# are in the human_gsrc and mouse_gsrc directories;
# that is, it does not download the files from Ensembl
# or make the 'finished' fasta files, etc.
#

ORGANISM="barnyard"

if [ "$ORGANISM" == "" ]
then
  echo "Usage: genome.01.run_barnyard.sh <organism>"
  exit -1
fi


ORGANISM_FILE="genome.${ORGANISM}.sh"
if [ ! -f "$ORGANISM_FILE" ]
then
  echo "ERROR: unable to file \'$ORGANISM_FILE\' for organism $ORGANISM. Exiting."
  exit -1
fi



SCRIPT_DIR="."
if [ "$SCRIPT_DIR" == "." ]
then
  SCRIPT_DIR=`pwd`
fi

source ${SCRIPT_DIR}/$ORGANISM_FILE
source ${SCRIPT_DIR}/all.02.definitions.sh
source ${SCRIPT_DIR}/genome.02.definitions.sh
source ${SCRIPT_DIR}/genome.06.barnyard.sh

mkdir -p $GENOME_DIR

pushd $GENOME_DIR

barnyard_setup_source_files
barnyard_compress_finish_fasta_file

popd

