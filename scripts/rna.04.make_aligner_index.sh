#!/bin/bash

function setup_source_files_star()
{
  echo "Make copies of and soft links to required files from ${GENOME_DIR}..." | proc_stdout
  date '+%Y.%m.%d:%H.%M.%S' | proc_stdout

  if [ ! -f "${GENOME_DIR}/${FASTA_FINISHED}" ]
  then
    echo "ERROR: cannot find file ${GENOME_DIR}/${FASTA_FINISHED}. Exiting..." | proc_stdout
    exit -1
  fi

  if [ ! -f "${GENOME_DIR}/${GTF_GZ}" ]
  then
    echo "ERROR: cannot find file ${GENOME_DIR}/${GTF_GZ}. Exiting..." | proc_stdout
    exit -1
  fi

  ln -s ${GENOME_DIR}/${FASTA_FINISHED} .
  ln -s ${GENOME_DIR}/${GTF_GZ} .

  echo | proc_stdout
  echo 'Done.' | proc_stdout
  echo | proc_stdout
}


function make_aligner_index()
{
  echo "STAR version: " | proc_stdout ${RECORD}
  ${STAR_ALIGNER} --version | proc_stdout ${RECORD}

  echo "Uncompress gtf file ${GTF_GZ}..." | proc_stdout
  date '+%Y.%m.%d:%H.%M.%S' | proc_stdout
  zcat ${GTF_GZ} > ${GTF}
  
  echo "Build STAR genome index using ${FASTA_FINISHED} and ${GTF_GZ}..." | proc_stdout ${RECORD}
  date '+%Y.%m.%d:%H.%M.%S' | proc_stdout ${RECORD}

  #
  # Write a script to submit bowtie2-build to SGE
  #
  echo "Write script run_star_index.sh to submit SGE job..." | proc_stdout
  date '+%Y.%m.%d:%H.%M.%S' | proc_stdout
  rm -f ${STAR_DIR}/run_star_index.sh
  echo "#!/bin/bash" >> ${STAR_DIR}/run_star_index.sh
  echo "#$ -S /bin/bash" >> ${STAR_DIR}/run_star_index.sh
  echo "#$ -pe serial 4" >> ${STAR_DIR}/run_star_index.sh
  echo "#$ -l mfree=32G" >> ${STAR_DIR}/run_star_index.sh
  echo "#$ -o `pwd`/star_index.stdout" >> ${STAR_DIR}/run_star_index.sh
  echo "#$ -e `pwd`/star_index.stderr" >> ${STAR_DIR}/run_star_index.sh
  echo >> ${STAR_DIR}/run_star_index.sh
  echo "source /etc/profile.d/modules.sh" >> ${STAR_DIR}/run_star_index.sh
  echo "module load modules modules-init modules-gs" >> ${STAR_DIR}/run_star_index.sh
  echo "module load mpfr/2.4.1"  >> ${STAR_DIR}/run_star_index.sh
  echo "module load gmp/6.1.2"  >> ${STAR_DIR}/run_star_index.sh
  echo "module load gcc/4.7.0"  >> ${STAR_DIR}/run_star_index.sh
  echo "module load STAR/2.5.2b"  >> ${STAR_DIR}/run_star_index.sh
  echo >> ${STAR_DIR}/run_star_index.sh
  echo "$STAR_ALIGNER --runThreadN 4 --runMode genomeGenerate --genomeDir $STAR_DIR --genomeFastaFiles ${STAR_DIR}/${FASTA_FINISHED} --sjdbGTFfile ${RNA_DIR}/tmp.transcripts.3p.UTR.extended.500.bp.gtf --sjdbOverhang 100" >> ${STAR_DIR}/run_star_index.sh
  echo >> ${STAR_DIR}/run_star_index.sh

  echo "submit run_star_index.sh to cluster" | proc_stdout
  date '+%Y.%m.%d:%H.%M.%S' | proc_stdout
  qsub ${STAR_DIR}/run_star_index.sh
  date '+%Y.%m.%d:%H.%M.%S' | proc_stdout

  #echo $(( ( $(stat -c%s ${STAR_DIR}/Genome) + $(stat -c%s ${STAR_DIR}/SAindex) + $(stat -c%s ${STAR_DIR}/SA) )/1000000000 + 5)) | proc_stdout ${RECORD} alignment_gigs 

  echo | proc_stdout
  echo 'Done.' | proc_stdout
  echo | proc_stdout

}

