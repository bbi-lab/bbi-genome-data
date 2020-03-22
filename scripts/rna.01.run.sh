#!/bin/bash

#
# Build rna files.
#

set -o pipefail  # trace ERR through pipes
set -o errtrace  # trace ERR through 'time command' and other functions
set -o nounset   # set -u : exit the script if you try to use an uninitialised variable
set -o errexit   # set -e : exit the script if any statement returns a non-true return value

ORGANISM="$1"

if [ "$ORGANISM" == "" ]
then
  echo "Usage: rna.01.run.sh <organism>"
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
source ${SCRIPT_DIR}/rna.02.definitions.sh
source ${SCRIPT_DIR}/rna.03.make_bed_files.sh
source ${SCRIPT_DIR}/rna.04.make_aligner_index.sh
source ${SCRIPT_DIR}/rna.10.make_clean_directory.sh


#
# Make bed files in directory <organism>.
#
mkdir -p $RNA_DIR

pushd $RNA_DIR

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

