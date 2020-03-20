#!/bin/bash


function make_aligner_index()
{
  module load gcc/8.1.0

  echo "Bowtie2-build version: " | proc_stdout ${RECORD}
  ${BOWTIE2_BUILD} --version | proc_stdout ${RECORD}
  
  echo "Build bowtie2 index files using fasta file ${FASTA_FINISHED}..." | proc_stdout
  date '+%Y.%m.%d:%H.%M.%S' | proc_stdout
  ${BOWTIE2_BUILD} $FASTA_FINISHED $INDEX_PREFIX 2>&1 | proc_stdout

  echo | proc_stdout
  echo 'Done.' | proc_stdout
  echo | proc_stdout

  #
  # Write a script to submit bowtie2-build to SGE
  #
#   echo "Write script run_bowtie2_build.sh to submit SGE job" | proc_stdout
#   date '+%Y.%m.%d:%H.%M.%S' | proc_stdout
#   rm -f ${ATAC_DIR}/run_bowtie2_build.sh
#   echo "#!/bin/bash" >> ${ATAC_DIR}/run_bowtie2_build.sh
#   echo "#$ -S /bin/bash" >> ${ATAC_DIR}/run_bowtie2_build.sh
#   echo "#$ -pe serial 16" >> ${ATAC_DIR}/run_bowtie2_build.sh
#   echo "#$ -l mfree=64G" >> ${ATAC_DIR}/run_bowtie2_build.sh
#   echo "#$ -o `pwd`/bowtie2_build.stdout" >> ${ATAC_DIR}/run_bowtie2_build.sh
#   echo "#$ -e `pwd`/bowtie2_build.stderr" >> ${ATAC_DIR}/run_bowtie2_build.sh
#   echo >> ${ATAC_DIR}/run_bowtie2_build.sh
#   echo "source /etc/profile.d/modules.sh" >> ${ATAC_DIR}/run_bowtie2_build.sh
#   echo "module load modules modules-init modules-gs" >> ${ATAC_DIR}/run_bowtie2_build.sh
#   echo "module load tbb/2019_U5 bowtie2/2.3.5.1" >> ${ATAC_DIR}/run_bowtie2_build.sh
#   echo "module load gcc/8.1.0"  >> ${ATAC_DIR}/run_bowtie2_build.sh
#   echo >> ${ATAC_DIR}/run_bowtie2_build.sh
#   echo "bowtie2-build --threads 16 ${ATAC_DIR}/$FASTA_FINISHED ${ATAC_DIR}/$INDEX_PREFIX" >> ${ATAC_DIR}/run_bowtie2_build.sh
#   echo >> ${ATAC_DIR}/run_bowtie2_build.sh
# 
#   echo "submit run_bowtie2build.sh to cluster" | proc_stdout
#   date '+%Y.%m.%d:%H.%M.%S' | proc_stdout
#   qsub ${ATAC_DIR}/run_bowtie2_build.sh
#   date '+%Y.%m.%d:%H.%M.%S' | proc_stdout

  echo | proc_stdout
  echo 'Done.' | proc_stdout
  echo | proc_stdout
}
