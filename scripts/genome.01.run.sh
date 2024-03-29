#!/bin/bash

#
# Build source genome files (except for barnyard).
#


if [ "$1" == "" ]
then
  echo "Usage: genome.01.run.sh <organism_name>"
  exit -1
fi


set -o pipefail  # trace ERR through pipes
set -o errtrace  # trace ERR through 'time command' and other functions
set -o nounset   # set -u : exit the script if you try to use an uninitialised variable
set -o errexit   # set -e : exit the script if any statement returns a non-true return value


SCRIPT_DIR=`pwd`
source ${SCRIPT_DIR}/all.00.definitions.sh


ORGANISM_NAME="$1"
ORGANISM_DEFINITION_FILE="${ORGANISM_FILE_DIR}/genome.${ORGANISM_NAME}.sh"
if [ ! -f "$ORGANISM_DEFINITION_FILE" ]
then
  echo "ERROR: unable to find file \'$ORGANISM_DEFINITION_FILE\' for $ORGANISM_NAME. Exiting."
  exit -1
fi


source $ORGANISM_DEFINITION_FILE
source ${SCRIPT_DIR}/all.02.definitions.sh
source ${SCRIPT_DIR}/genome.02.definitions.sh
source ${SCRIPT_DIR}/genome.03.get_fasta_file.sh
source ${SCRIPT_DIR}/genome.04.make_genome_files.sh
source ${SCRIPT_DIR}/genome.05.get_gtf_file.sh

echo "The genome output files will be written to"
echo
echo "  ${STAGE_DIR}/${ORGANISM_NAME}"
echo
echo -n "Is this correct (y/[n])? "
read query
if [ "${query}" != "y" ]
then
  exit 0
fi
echo

echo "================================================================================"
echo
echo "Downloading genome files from"
echo
echo "  ${SOURCE_DNA_URL}"
echo "  ${SOURCE_GTF_URL}"
echo
echo -n "Is this correct (y/[n])? "
read query
if [ "${query}" != "y" ]
then
  exit 0
fi
echo
echo "================================================================================"
echo

source ${SCRIPT_DIR}/genome.10.make_clean_directory.sh

mkdir -p $GENOME_DIR

pushd $GENOME_DIR

echo "${BBI_GENOME_DATA_VERSION}" | proc_stdout ${RECORD} "bbi-genome-data scripts version"
echo "${ORGANISM_DEFINITION_FILE}" | proc_stdout ${RECORD} "Genome definition file path"

get_fasta_file
get_fasta_info

if [ "${GENOME_SOURCE}" == 'ensembl' ]
then
  sequences_to_keep_ref
elif [ "${GENOME_SOURCE}" == 'gencode' ]
then
  sequences_to_keep_all
fi

filter_fasta_file
finish_fasta_file
compress_finish_fasta_file
make_chromosome_sizes_files
get_gtf_file
get_gtf_info

if [ "${GENOME_SOURCE}" == 'gencode' ]
then
  gencode_edit_gtf
fi
make_clean_directory

popd

