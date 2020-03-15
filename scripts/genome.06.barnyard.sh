#!/bin/bash
 
 
function barnyard_setup_source_files()
{
  echo "Make copies of and soft links to required files from ${GENOME_DIR}..." | tee -a ${LOG}
  date '+%Y.%m.%d:%H.%M.%S' | tee -a ${LOG}
  echo | tee -a ${LOG}

  HUMAN_FASTA_FINISHED="human.fa.finished"
  HUMAN_GTF="human.gtf"
  HUMAN_CHROMOSOME_SIZES_FILE="human.chromosome_sizes.txt"
  MOUSE_FASTA_FINISHED="mouse.fa.finished"
  MOUSE_GTF="mouse.gtf"
  MOUSE_CHROMOSOME_SIZES_FILE="mouse.chromosome_sizes.txt"

  #
  # Copy and edit human fasta and gtf files.
  # 
  source ${SCRIPT_DIR}/genome.human.sh
  source ${SCRIPT_DIR}/all.02.definitions.sh
  SRC_HUMAN_FASTA_FINISHED="${GENOME_DIR}/${FASTA_FINISHED}"

  echo "Edit human ${FASTA_FINISHED} into ${HUMAN_FASTA_FINISHED} by adding 'HUMAN_' to chr names..." | tee -a ${LOG}
  date '+%Y.%m.%d:%H.%M.%S' | tee -a ${LOG}
  sed 's/^>/>HUMAN_/' ${SRC_HUMAN_FASTA_FINISHED} > ${HUMAN_FASTA_FINISHED}
  echo | tee -a ${LOG}

  echo "Edit human ${GTF_GZ} into ${HUMAN_GTF} by adding 'HUMAN_' to chr names..." | tee -a ${LOG}
  date '+%Y.%m.%d:%H.%M.%S' | tee -a ${LOG}
  SRC_GTF_GZ=${GENOME_DIR}/${GTF_GZ}
  zcat $SRC_GTF_GZ | grep -v '^#' | sed 's/^/HUMAN_/' > $HUMAN_GTF
  echo | tee -a ${LOG}

  echo "Edit human ${CHROMOSOME_SIZES_FILE} into ${HUMAN_CHROMOSOME_SIZES_FILE} by adding 'HUMAN_' to chr names..." | tee -a ${LOG}
  date '+%Y.%m.%d:%H.%M.%S' | tee -a ${LOG}
  SRC_CHROMOSOME_SIZES_FILE=${GENOME_DIR}/${CHROMOSOME_SIZES_FILE}
  sed 's/^/HUMAN_/' $SRC_CHROMOSOME_SIZES_FILE > $HUMAN_CHROMOSOME_SIZES_FILE
  echo | tee -a ${LOG}

 
  #
  # Copy and edit mouse fasta and gtf files.
  # 
  source ${SCRIPT_DIR}/genome.mouse.sh
  source ${SCRIPT_DIR}/all.02.definitions.sh
  SRC_MOUSE_FASTA_FINISHED="${GENOME_DIR}/${FASTA_FINISHED}"


  echo "Edit mouse ${FASTA_FINISHED} into ${MOUSE_FASTA_FINISHED} by adding 'MOUSE_' to chr names..." | tee -a ${LOG}
  date '+%Y.%m.%d:%H.%M.%S' | tee -a ${LOG}
  sed 's/^>/>MOUSE_/' ${SRC_MOUSE_FASTA_FINISHED} > ${MOUSE_FASTA_FINISHED}
  echo | tee -a ${LOG}

  echo "Edit mouse ${GTF_GZ} into ${MOUSE_GTF} by adding 'MOUSE_' to chr names..." | tee -a ${LOG}
  date '+%Y.%m.%d:%H.%M.%S' | tee -a ${LOG}
  SRC_GTF_GZ=${GENOME_DIR}/${GTF_GZ}
  zcat $SRC_GTF_GZ | grep -v '^#' | sed 's/^/MOUSE_/' > $MOUSE_GTF
  echo | tee -a ${LOG}
 
  echo "Edit mouse ${CHROMOSOME_SIZES_FILE} into ${MOUSE_CHROMOSOME_SIZES_FILE} by adding 'MOUSE_' to chr names..." | tee -a ${LOG}
  date '+%Y.%m.%d:%H.%M.%S' | tee -a ${LOG}
  SRC_CHROMOSOME_SIZES_FILE=${GENOME_DIR}/${CHROMOSOME_SIZES_FILE}
  sed 's/^/MOUSE_/' $SRC_CHROMOSOME_SIZES_FILE > $MOUSE_CHROMOSOME_SIZES_FILE
  echo | tee -a ${LOG}

  #
  # Concatenate fasta, gtf, and chromosome_sizes files.
  #
  source ${SCRIPT_DIR}/genome.barnyard.sh
  source ${SCRIPT_DIR}/all.02.definitions.sh

  echo "Concatenate ${HUMAN_FASTA_FINISHED} ${MOUSE_FASTA_FINISHED} into ${BARNYARD_FASTA_FINISHED}..." | tee -a ${LOG}
  date '+%Y.%m.%d:%H.%M.%S' | tee -a ${LOG}
  cat ${HUMAN_FASTA_FINISHED} ${MOUSE_FASTA_FINISHED} > ${BARNYARD_FASTA_FINISHED}
  echo | tee -a ${LOG}

  echo "Concatenate ${HUMAN_GTF} ${MOUSE_GTF} into ${BARNYARD_GTF_GZ}..." | tee -a ${LOG}
  date '+%Y.%m.%d:%H.%M.%S' | tee -a ${LOG}
  cat ${HUMAN_GTF} ${MOUSE_GTF} | gzip > ${BARNYARD_GTF_GZ}
  echo | tee -a ${LOG}

  echo "Concatenate ${HUMAN_CHROMOSOME_SIZES_FILE} ${MOUSE_CHROMOSOME_SIZES_FILE} into ${CHROMOSOME_SIZES_FILE}..." | tee -a ${LOG}
  date '+%Y.%m.%d:%H.%M.%S' | tee -a ${LOG}
  cat ${HUMAN_CHROMOSOME_SIZES_FILE} ${MOUSE_CHROMOSOME_SIZES_FILE} > ${CHROMOSOME_SIZES_FILE}
  echo | tee -a ${LOG}

  #
  # Checks.
  #
  echo "Calculate ${BARNYARD_FASTA_FINISHED} file sequence md5 checksums..." | tee -a ${LOG}
  date '+%Y.%m.%d:%H.%M.%S' | tee -a ${LOG}
  $MD5_SEQ ${BARNYARD_FASTA_FINISHED} > ${BARNYARD_FASTA_FINISHED}.md5_seq
  echo | tee -a ${LOG}


  echo "CHECKPOINT" | tee -a ${LOG}
  echo "Check for inconsistent md5 checksums for ${SRC_HUMAN_FASTA_FINISHED} and human chromosomes in ${BARNYARD_FASTA_FINISHED} the ERRORs..." | tee -a ${LOG}
  grep '^HUMAN_' ${BARNYARD_FASTA_FINISHED}.md5_seq | sed 's/^HUMAN_//' | sort -k 1,1 > tmp.out
  join -1 1 -2 1 ${SRC_HUMAN_FASTA_FINISHED}.md5_seq.sort tmp.out \
    | sort -k1,1V \
    | awk '{printf( "%s\t%s\t%s\n", $1, $3, $5);}' \
    | awk '{if($2!=$3){printf("ERROR: inconsistent md5sum values for chromosome %s\n",$1);}}' | tee -a ${LOG}
  echo | tee -a ${LOG}

  echo "CHECKPOINT" | tee -a ${LOG}
  echo "Check for inconsistent md5 checksums for ${SRC_MOUSE_FASTA_FINISHED} and mouse chromosomes in ${BARNYARD_FASTA_FINISHED} the ERRORs..." | tee -a ${LOG}
  grep '^MOUSE_' ${BARNYARD_FASTA_FINISHED}.md5_seq | sed 's/^MOUSE_//' | sort -k 1,1 > tmp.out
  join -1 1 -2 1 ${SRC_MOUSE_FASTA_FINISHED}.md5_seq.sort tmp.out \
    | sort -k1,1V \
    | awk '{printf( "%s\t%s\t%s\n", $1, $3, $5);}' \
    | awk '{if($2!=$3){printf("ERROR: inconsistent md5sum values for chromosome %s\n",$1);}}' | tee -a ${LOG}
  echo | tee -a ${LOG}

  rm -f tmp.out

  echo "CHECKPOINT" | tee -a ${LOG}
  echo "Count total number of annotations per sequence in ${BARNYARD_GTF_GZ}..." | tee -a ${LOG}
  date '+%Y.%m.%d:%H.%M.%S' | tee -a ${LOG}
  zcat $BARNYARD_GTF_GZ \
    | grep -v '^#' \
    | awk '{print$1}' \
    | sort \
    | uniq -c \
    | sort -k2,2V \
    | awk '{printf( "%s\t%s\n", $1, $2 );}' | tee -a ${LOG}
  echo | tee -a ${LOG}

  echo "CHECKPOINT" | tee -a ${LOG}
  cat $CHROMOSOME_SIZES_FILE | tee -a ${LOG}
  echo | tee -a ${LOG}

  echo 'Done.' | tee -a ${LOG}
  echo | tee -a ${LOG}

}


#
# Compress finished fasta file (keep original).
#
function barnyard_compress_finish_fasta_file()
{
  echo "Compress a copy of $BARNYARD_FASTA_FINISHED to make ${BARNYARD_FASTA_FINISHED}.bz2..." | tee -a ${LOG}
  date '+%Y.%m.%d:%H.%M.%S' | tee -a ${LOG}
  bzip2 -k $BARNYARD_FASTA_FINISHED
  echo "Finished file compression" | tee -a ${LOG}
  date '+%Y.%m.%d:%H.%M.%S' | tee -a ${LOG}
  echo | tee -a ${LOG}

  echo 'Done.' | tee -a ${LOG}
  echo | tee -a ${LOG}
}

