#!/bin/bash

#
# Build rna files.
#


if [ "$1" == "" ]
then
  echo "Usage: rna.01.run.sh <organism_name>"
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
  echo "ERROR: unable to find file \'$ORGANISM_DEFINITION_FILE\' for organism $ORGANISM_NAME. Exiting."
  exit -1
fi


source $ORGANISM_DEFINITION_FILE
source ${SCRIPT_DIR}/all.02.definitions.sh
source ${SCRIPT_DIR}/rna.02.definitions.sh
source ${SCRIPT_DIR}/rna.03.make_bed_files.sh
source ${SCRIPT_DIR}/rna.04.make_aligner_index.sh

echo "The RNA-seq output files will be written to"
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

source ${SCRIPT_DIR}/rna.10.make_clean_directory.sh

#
# Make bed files in directory <organism>.
#
mkdir -p $RNA_DIR

pushd $RNA_DIR

echo "${BBI_GENOME_DATA_VERSION}" | proc_stdout ${RECORD} "bbi-genome-data scripts version"

setup_source_files_bed
get_gene_annotations
get_transcript_annotations
extend_3p_utr_gene_annotations
extend_3p_utr_transcript_annotations
get_number_exons_per_transcript
make_extended_utr_gtf
make_scirna_pipeline_bed_files
get_rrna_gene_annotations
make_clean_bed_directory

popd


#
# Make star index files in directory <organism>_star.
#
mkdir -p $STAR_DIR

pushd $STAR_DIR

setup_source_files_star
make_aligner_index
make_clean_star_directory

popd

