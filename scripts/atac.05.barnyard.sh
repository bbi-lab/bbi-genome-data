#!/bin/bash


function barnyard_setup_source_files()
{
  echo "Make copies of and soft links to required files from ${GENOME_DIR}..." | tee -a ${LOG}
  date '+%Y.%m.%d:%H.%M.%S' | tee -a ${LOG}
 
  echo -n "PWD: "
  pwd
 
  source ${SCRIPT_DIR}/genome.human.sh
  source ${SCRIPT_DIR}/all.02.definitions.sh

  echo "human: src: ${GENOME_DIR}/${FASTA_FINISHED}  dst: human.${FASTA_FINISHED}"


  source ${SCRIPT_DIR}/genome.mouse.sh
  source ${SCRIPT_DIR}/all.02.definitions.sh
 
  echo "mouse: src: ${GENOME_DIR}/${FASTA_FINISHED}  dst: human.${FASTA_FINISHED}"


#   echo "Make copies of and soft links to required files from ${GENOME_DIR}..." | tee -a ${LOG}
#   date '+%Y.%m.%d:%H.%M.%S' | tee -a ${LOG}
# 
#   if [ ! -f "${GENOME_DIR}/${CHROMOSOME_SIZES_FILE}" ]
#   then
#     echo "ERROR: cannot find file ${GENOME_DIR}/${CHROMOSOME_SIZES_FILE}. Exiting..." | tee -a ${LOG}
#     exit -1
#   fi
# 
#   if [ ! -f "${GENOME_DIR}/${FASTA_FINISHED}" ]
#   then
#     echo "ERROR: cannot find file ${GENOME_DIR}/${FASTA_FINISHED}. Exiting..." | tee -a ${LOG}
#     exit -1
#   fi
# 
#   if [ ! -f "${GENOME_DIR}/${GTF_GZ}" ]
#   then
#     echo "ERROR: cannot find file ${GENOME_DIR}/${GTF_GZ}. Exiting..." | tee -a ${LOG}
#     exit -1
#   fi
# 
#   cp ${GENOME_DIR}/${CHROMOSOME_SIZES_FILE} .
#   ln -s ${GENOME_DIR}/${FASTA_FINISHED} .
#   ln -s ${GENOME_DIR}/${GTF_GZ} .
# 
#   echo | tee -a ${LOG}
#   echo 'Done.' | tee -a ${LOG}
#   echo | tee -a ${LOG}
}

