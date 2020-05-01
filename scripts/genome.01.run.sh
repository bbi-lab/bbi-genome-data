#!/bin/bash

#
# Build source genome files (except for barnyard).
#

set -o pipefail  # trace ERR through pipes
set -o errtrace  # trace ERR through 'time command' and other functions
set -o nounset   # set -u : exit the script if you try to use an uninitialised variable
set -o errexit   # set -e : exit the script if any statement returns a non-true return value

DEFINITION="$1"

if [ "$DEFINITION" == "" ]
then
  echo "Usage: genome.01.run.sh <definition>"
  exit -1
fi


DEFINITION_FILE="genome.${DEFINITION}.sh"
if [ ! -f "$DEFINITION_FILE" ]
then
  echo "ERROR: unable to find file \'$DEFINITION_FILE\' for $DEFINITION. Exiting."
  exit -1
fi



SCRIPT_DIR="."

source ${SCRIPT_DIR}/$DEFINITION_FILE
source ${SCRIPT_DIR}/all.02.definitions.sh
source ${SCRIPT_DIR}/genome.02.definitions.sh
source ${SCRIPT_DIR}/genome.03.get_fasta_file.sh
source ${SCRIPT_DIR}/genome.04.make_genome_files.sh
source ${SCRIPT_DIR}/genome.05.get_gtf_file.sh
source ${SCRIPT_DIR}/genome.10.make_clean_directory.sh


mkdir -p $GENOME_DIR

pushd $GENOME_DIR

get_fasta_file
get_fasta_info
sequences_to_keep_ref
filter_fasta_file
finish_fasta_file
compress_finish_fasta_file
make_chromosome_sizes_file
get_gtf_file
get_gtf_info
make_clean_directory

popd

