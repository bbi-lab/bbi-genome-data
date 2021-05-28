#!/bin/bash


function barnyard_setup_source_files()
{
  echo "Make copies of and soft links to required files from ${GENOME_DIR}..." | proc_stdout
  date '+%Y.%m.%d:%H.%M.%S' | proc_stdout
  echo | proc_stdout

  HUMAN_FASTA_FINISHED="human.fa.finished"
  HUMAN_GTF="human.gtf"
  HUMAN_CHROMOSOME_SIZES_FASTA_FINISHED_FILE="human.chromosome_sizes_fasta_finished.txt"
  HUMAN_CHROMOSOME_SIZES_ATAC_FILE="human.chromosome_sizes_atac.txt"
  HUMAN_CHROMOSOME_WITH_MT_SIZES_ATAC_FILE="human.chromosome_with_mt_sizes_atac.txt"
  MOUSE_FASTA_FINISHED="mouse.fa.finished"
  MOUSE_GTF="mouse.gtf"
  MOUSE_CHROMOSOME_SIZES_FASTA_FINISHED_FILE="mouse.chromosome_sizes_fasta_finished.txt"
  MOUSE_CHROMOSOME_SIZES_ATAC_FILE="mouse.chromosome_sizes_atac.txt"
  MOUSE_CHROMOSOME_WITH_MT_SIZES_ATAC_FILE="mouse.chromosome_with_mt_sizes_atac.txt"

  #
  # Copy and edit human fasta and gtf files.
  # 
  source ${ORGANISM_FILE_DIR}/genome.human.sh
  source ${SCRIPT_DIR}/all.02.definitions.sh
  SRC_HUMAN_FASTA_FINISHED="${GENOME_DIR}/${FASTA_FINISHED}"

  echo "Edit human ${FASTA_FINISHED} into ${HUMAN_FASTA_FINISHED} by adding 'HUMAN_' to chr names..." | proc_stdout
  date '+%Y.%m.%d:%H.%M.%S' | proc_stdout
  sed 's/^>/>HUMAN_/' ${SRC_HUMAN_FASTA_FINISHED} > ${HUMAN_FASTA_FINISHED}
  echo | proc_stdout

  echo "Edit human ${GTF_GZ} into ${HUMAN_GTF} by adding 'HUMAN_' to chr names..." | proc_stdout
  date '+%Y.%m.%d:%H.%M.%S' | proc_stdout
  SRC_GTF_GZ=${GENOME_DIR}/${GTF_GZ}
  zcat $SRC_GTF_GZ | grep -v '^#' | sed 's/^/HUMAN_/' > $HUMAN_GTF
  echo | proc_stdout

  echo "Edit human ${CHROMOSOME_SIZES_FASTA_FINISHED_FILE} into ${HUMAN_CHROMOSOME_SIZES_FASTA_FINISHED_FILE} by adding 'HUMAN_' to chr names..." | proc_stdout
  date '+%Y.%m.%d:%H.%M.%S' | proc_stdout
  SRC_CHROMOSOME_SIZES_FASTA_FINISHED_FILE=${GENOME_DIR}/${CHROMOSOME_SIZES_FASTA_FINISHED_FILE}
  sed 's/^/HUMAN_/' $SRC_CHROMOSOME_SIZES_FASTA_FINISHED_FILE > $HUMAN_CHROMOSOME_SIZES_FASTA_FINISHED_FILE
  echo | proc_stdout

  echo "Edit human ${CHROMOSOME_SIZES_ATAC_FILE} into ${HUMAN_CHROMOSOME_SIZES_ATAC_FILE} by adding 'HUMAN_' to chr names..." | proc_stdout
  date '+%Y.%m.%d:%H.%M.%S' | proc_stdout
  SRC_CHROMOSOME_SIZES_ATAC_FILE=${GENOME_DIR}/${CHROMOSOME_SIZES_ATAC_FILE}
  sed 's/^/HUMAN_/' $SRC_CHROMOSOME_SIZES_ATAC_FILE > $HUMAN_CHROMOSOME_SIZES_ATAC_FILE
  echo | proc_stdout

  echo "Edit human ${CHROMOSOME_WITH_MT_SIZES_ATAC_FILE} into ${HUMAN_CHROMOSOME_WITH_MT_SIZES_ATAC_FILE} by adding 'HUMAN_' to chr names..." | proc_stdout
  date '+%Y.%m.%d:%H.%M.%S' | proc_stdout
  SRC_CHROMOSOME_WITH_MT_SIZES_ATAC_FILE=${GENOME_DIR}/${CHROMOSOME_WITH_MT_SIZES_ATAC_FILE}
  sed 's/^/HUMAN_/' $SRC_CHROMOSOME_WITH_MT_SIZES_ATAC_FILE > $HUMAN_CHROMOSOME_WITH_MT_SIZES_ATAC_FILE
  echo | proc_stdout
 
  #
  # Copy and edit mouse fasta and gtf files.
  # 
  source ${ORGANISM_FILE_DIR}/genome.mouse.sh
  source ${SCRIPT_DIR}/all.02.definitions.sh
  SRC_MOUSE_FASTA_FINISHED="${GENOME_DIR}/${FASTA_FINISHED}"


  echo "Edit mouse ${FASTA_FINISHED} into ${MOUSE_FASTA_FINISHED} by adding 'MOUSE_' to chr names..." | proc_stdout
  date '+%Y.%m.%d:%H.%M.%S' | proc_stdout
  sed 's/^>/>MOUSE_/' ${SRC_MOUSE_FASTA_FINISHED} > ${MOUSE_FASTA_FINISHED}
  echo | proc_stdout

  echo "Edit mouse ${GTF_GZ} into ${MOUSE_GTF} by adding 'MOUSE_' to chr names..." | proc_stdout
  date '+%Y.%m.%d:%H.%M.%S' | proc_stdout
  SRC_GTF_GZ=${GENOME_DIR}/${GTF_GZ}
  zcat $SRC_GTF_GZ | grep -v '^#' | sed 's/^/MOUSE_/' > $MOUSE_GTF
  echo | proc_stdout

  echo "Edit mouse ${CHROMOSOME_SIZES_FASTA_FINISHED_FILE} into ${MOUSE_CHROMOSOME_SIZES_FASTA_FINISHED_FILE} by adding 'MOUSE_' to chr names..." | proc_stdout
  date '+%Y.%m.%d:%H.%M.%S' | proc_stdout
  SRC_CHROMOSOME_SIZES_FASTA_FINISHED_FILE=${GENOME_DIR}/${CHROMOSOME_SIZES_FASTA_FINISHED_FILE}
  sed 's/^/MOUSE_/' $SRC_CHROMOSOME_SIZES_FASTA_FINISHED_FILE > $MOUSE_CHROMOSOME_SIZES_FASTA_FINISHED_FILE
  echo | proc_stdout

  echo "Edit mouse ${CHROMOSOME_SIZES_ATAC_FILE} into ${MOUSE_CHROMOSOME_SIZES_ATAC_FILE} by adding 'MOUSE_' to chr names..." | proc_stdout
  date '+%Y.%m.%d:%H.%M.%S' | proc_stdout
  SRC_CHROMOSOME_SIZES_ATAC_FILE=${GENOME_DIR}/${CHROMOSOME_SIZES_ATAC_FILE}
  sed 's/^/MOUSE_/' $SRC_CHROMOSOME_SIZES_ATAC_FILE > $MOUSE_CHROMOSOME_SIZES_ATAC_FILE
  echo | proc_stdout

  echo "Edit mouse ${CHROMOSOME_WITH_MT_SIZES_ATAC_FILE} into ${MOUSE_CHROMOSOME_WITH_MT_SIZES_ATAC_FILE} by adding 'MOUSE_' to chr names..." | proc_stdout
  date '+%Y.%m.%d:%H.%M.%S' | proc_stdout
  SRC_CHROMOSOME_WITH_MT_SIZES_ATAC_FILE=${GENOME_DIR}/${CHROMOSOME_WITH_MT_SIZES_ATAC_FILE}
  sed 's/^/MOUSE_/' $SRC_CHROMOSOME_WITH_MT_SIZES_ATAC_FILE > $MOUSE_CHROMOSOME_WITH_MT_SIZES_ATAC_FILE
  echo | proc_stdout

  #
  # Concatenate fasta, gtf, and chromosome_sizes files.
  #
  source ${ORGANISM_FILE_DIR}/genome.barnyard.sh
  source ${SCRIPT_DIR}/all.02.definitions.sh

  echo "Concatenate ${HUMAN_FASTA_FINISHED} ${MOUSE_FASTA_FINISHED} into ${BARNYARD_FASTA_FINISHED}..." | proc_stdout
  date '+%Y.%m.%d:%H.%M.%S' | proc_stdout
  cat ${HUMAN_FASTA_FINISHED} ${MOUSE_FASTA_FINISHED} > ${BARNYARD_FASTA_FINISHED}
  echo | proc_stdout

  echo "Concatenate ${HUMAN_GTF} ${MOUSE_GTF} into ${BARNYARD_GTF_GZ}..." | proc_stdout
  date '+%Y.%m.%d:%H.%M.%S' | proc_stdout
  cat ${HUMAN_GTF} ${MOUSE_GTF} | gzip > ${BARNYARD_GTF_GZ}
  echo | proc_stdout

  echo "Concatenate ${HUMAN_CHROMOSOME_SIZES_FASTA_FINISHED_FILE} ${MOUSE_CHROMOSOME_SIZES_FASTA_FINISHED_FILE} into ${CHROMOSOME_SIZES_FASTA_FINISHED_FILE}..." | proc_stdout
  date '+%Y.%m.%d:%H.%M.%S' | proc_stdout
  cat ${HUMAN_CHROMOSOME_SIZES_FASTA_FINISHED_FILE} ${MOUSE_CHROMOSOME_SIZES_FASTA_FINISHED_FILE} > ${CHROMOSOME_SIZES_FASTA_FINISHED_FILE}

  echo "Concatenate ${HUMAN_CHROMOSOME_SIZES_ATAC_FILE} ${MOUSE_CHROMOSOME_SIZES_ATAC_FILE} into ${CHROMOSOME_SIZES_ATAC_FILE}..." | proc_stdout
  date '+%Y.%m.%d:%H.%M.%S' | proc_stdout
  cat ${HUMAN_CHROMOSOME_SIZES_ATAC_FILE} ${MOUSE_CHROMOSOME_SIZES_ATAC_FILE} > ${CHROMOSOME_SIZES_ATAC_FILE}
  echo | proc_stdout

  echo "Concatenate ${HUMAN_CHROMOSOME_WITH_MT_SIZES_ATAC_FILE} ${MOUSE_CHROMOSOME_WITH_MT_SIZES_ATAC_FILE} into ${CHROMOSOME_WITH_MT_SIZES_ATAC_FILE}..." | proc_stdout
  date '+%Y.%m.%d:%H.%M.%S' | proc_stdout
  cat ${HUMAN_CHROMOSOME_WITH_MT_SIZES_ATAC_FILE} ${MOUSE_CHROMOSOME_WITH_MT_SIZES_ATAC_FILE} > ${CHROMOSOME_WITH_MT_SIZES_ATAC_FILE}
  echo | proc_stdout

  #
  # Checks.
  #
  echo "Calculate ${BARNYARD_FASTA_FINISHED} file sequence md5 checksums..." | proc_stdout
  date '+%Y.%m.%d:%H.%M.%S' | proc_stdout
  $MD5_SEQ ${BARNYARD_FASTA_FINISHED} > ${BARNYARD_FASTA_FINISHED}.md5_seq
  echo | proc_stdout


  echo "CHECKPOINT" | proc_stdout
  echo "Check for inconsistent md5 checksums for human sequences in ${SRC_HUMAN_FASTA_FINISHED} and ${BARNYARD_FASTA_FINISHED}..." | proc_stdout ${RECORD}
  grep '^HUMAN_' ${BARNYARD_FASTA_FINISHED}.md5_seq | sed 's/^HUMAN_//' | sort -k 1,1 > tmp.out
  join -1 1 -2 1 ${SRC_HUMAN_FASTA_FINISHED}.md5_seq.sort tmp.out \
    | sort -k1,1V \
    | awk '{printf( "%s\t%s\t%s\t%s\t%s\n", $1, $3, $5, $2, $4);}' \
    | awk 'BEGIN{eflag=0;}{if($2!=$3){printf("  ** chromosome %s differs (lengths %s %s)\n",$1,$4,$5);eflag=1;}}END{if(eflag==0){printf("No differences.\n");}}' | proc_stdout ${RECORD}
  echo | proc_stdout

  echo "CHECKPOINT" | proc_stdout
  echo "Check for inconsistent md5 checksums for mouse sequences in ${SRC_MOUSE_FASTA_FINISHED} and ${BARNYARD_FASTA_FINISHED}..." | proc_stdout ${RECORD}
  grep '^MOUSE_' ${BARNYARD_FASTA_FINISHED}.md5_seq | sed 's/^MOUSE_//' | sort -k 1,1 > tmp.out
  join -1 1 -2 1 ${SRC_MOUSE_FASTA_FINISHED}.md5_seq.sort tmp.out \
    | sort -k1,1V \
    | awk '{printf( "%s\t%s\t%s\t%s\t%s\n", $1, $3, $5, $2, $4);}' \
    | awk 'BEGIN{eflag=0;}{if($2!=$3){printf("  ** chromosome %s differs (lengths %s %s)\n",$1,$4,$5);eflag=1;}}END{if(eflag==0){printf("No differences.\n");}}' | proc_stdout ${RECORD}
  echo | proc_stdout

  rm -f tmp.out

  echo "CHECKPOINT" | proc_stdout
  echo "Count total number of annotations per sequence in ${BARNYARD_GTF_GZ}..." | proc_stdout
  date '+%Y.%m.%d:%H.%M.%S' | proc_stdout
  zcat $BARNYARD_GTF_GZ \
    | grep -v '^#' \
    | awk '{print$1}' \
    | sort \
    | uniq -c \
    | sort -k2,2V \
    | awk '{printf( "%s\t%s\n", $1, $2 );}' | proc_stdout
  echo | proc_stdout

  echo "CHECKPOINT" | proc_stdout
  echo "$CHROMOSOME_SIZES_ATAC_FILE file"
  cat $CHROMOSOME_SIZES_ATAC_FILE | proc_stdout
  echo | proc_stdout

  echo "CHECKPOINT" | proc_stdout
  echo "$CHROMOSOME_WITH_MT_SIZES_ATAC_FILE file"
  cat $CHROMOSOME_WITH_MT_SIZES_ATAC_FILE | proc_stdout
  echo | proc_stdout

  echo 'Done.' | proc_stdout
  echo | proc_stdout

}


#
# Compress finished fasta file (keep original).
#
function barnyard_compress_finish_fasta_file()
{
  echo "Compress a copy of $BARNYARD_FASTA_FINISHED to make ${BARNYARD_FASTA_FINISHED}.bz2..." | proc_stdout
  date '+%Y.%m.%d:%H.%M.%S' | proc_stdout
  bzip2 -k $BARNYARD_FASTA_FINISHED
  echo "Finished file compression" | proc_stdout
  date '+%Y.%m.%d:%H.%M.%S' | proc_stdout
  echo | proc_stdout

  echo 'Done.' | proc_stdout
  echo | proc_stdout
}

