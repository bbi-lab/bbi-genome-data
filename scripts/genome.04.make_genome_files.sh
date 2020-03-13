#!/bin/bash


#
# Choose aligner subject squences, keeping reference sequences.
# Notes:
#   o  this is written to use the current Ensembl fasta headers,
#      in which the fourth token is the sequence type.
#   o  select all sequences in which the fourth token is 'REF', which
#      we expect to be reference sequences.
#   o  use either sequences_to_keep_ref() or sequences_to_keep_named() to
#      make the file $FINAL_IDS_FILE but not both.
#
function sequences_to_keep_ref()
{
  echo "Keep the REF sequences for read alignments in ${FASTA}..." | tee -a ${LOG}
  date '+%Y.%m.%d:%H.%M.%S' | tee -a ${LOG}
  cat ${FASTA}.headers \
    | awk '{if($4=="REF"){print$1}}' \
    | sed 's/^>//' > $FINAL_IDS_FILE
  echo | tee -a ${LOG}

  echo "CHECKPOINT" | tee -a ${LOG}
  cat $FINAL_IDS_FILE | tee -a ${LOG}
  echo | tee -a ${LOG}

  echo 'Done.' | tee -a ${LOG}
  echo | tee -a ${LOG}
}


#
# Choose aligner subject sequences named in the environment variable SEQUENCES_TO_KEEP_ALIGNER...
# Notes:
#   o  select sequences named in the variable SEQUENCES_TO_KEEP_ALIGNER, which
#      must be defined appropriately in the files 'genome.<organims>.sh'.
#   o  use either sequences_to_keep_ref() or sequences_to_keep_named() to
#      make the file $FINAL_IDS_FILE but not both.
#
function sequences_to_keep_named()
{
  echo "Keep the named sequences for read alignments in ${FASTA}..." | tee -a ${LOG}
  date '+%Y.%m.%d:%H.%M.%S' | tee -a ${LOG}
  echo | tee -a ${LOG}
  echo "$SEQUENCES_TO_KEEP_ALIGNER" | sed 's/[ ][ ]*/\n/g' > $FINAL_IDS_FILE
  echo | tee -a ${LOG}

  echo "CHECKPOINT" | tee -a ${LOG}
  cat $FINAL_IDS_FILE | tee -a ${LOG}
  echo | tee -a ${LOG}

  echo 'Done.' | tee -a ${LOG}
  echo | tee -a ${LOG}
}


#
# Extract the specified sequences into a new fasta file.
#
function filter_fasta_file()
{ 
  echo "Extract selected sequences from the fasta file ${FASTA}..." | tee -a ${LOG}
  date '+%Y.%m.%d:%H.%M.%S' | tee -a ${LOG}
  $FASTA_GETSEQS $FINAL_IDS_FILE $FASTA > $FASTA_FILTERED
  echo | tee -a ${LOG}

  echo "CHECKPOINT" | tee -a ${LOG}
  echo "Count the sequences in the filtered fasta file ${FASTA_FILTERED}..." | tee -a ${LOG}
  grep '^>' $FASTA_FILTERED | wc -l | tee -a ${LOG}
  echo | tee -a ${LOG}
  
  echo "Calculate filtered fasta file sequence md5 checksums for ${FASTA}..." | tee -a ${LOG}
  $MD5_SEQ $FASTA_FILTERED > $FASTA_FILTERED.md5_seq
  echo | tee -a ${LOG}

  echo "Compare the md5 checksums for the downloaded and filtered fasta files..." | tee -a ${LOG}
  echo | tee -a ${LOG}
  sort -k1,1 $FASTA.md5_seq > $FASTA.md5_seq.sort
  sort -k1,1 $FASTA_FILTERED.md5_seq > $FASTA_FILTERED.md5_seq.sort
  join -1 1 -2 1 $FASTA.md5_seq.sort $FASTA_FILTERED.md5_seq.sort \
    | sort -k1,1V \
    | awk '{printf( "%s\t%s\t%s\n", $1, $3, $5);}' | tee -a ${LOG}
  echo | tee -a ${LOG}

  echo "CHECKPOINT" | tee -a ${LOG}
  echo "Check for inconsistent md5 checksums for the downloaded and filtered fasta files and report differences as ERRORs..." | tee -a ${LOG}
  join -1 1 -2 1 $FASTA.md5_seq.sort $FASTA_FILTERED.md5_seq.sort \
    | sort -k1,1V \
    | awk '{printf( "%s\t%s\t%s\n", $1, $3, $5);}' \
    | awk '{if($2!=$3){printf("ERROR: inconsistent md5sum values for chromosome %s\n",$1);}}' | tee -a ${LOG}
  echo | tee -a ${LOG}

  echo 'Done.' | tee -a ${LOG}
  echo | tee -a ${LOG}
}


#
# Make finished fasta file.
#   o  mask pseudo-autosomal regions, if define.
#   o  other edits as required...
#
function finish_fasta_file()
{
  if [[ "$PAR_DEFINED" -eq 1 ]]
  then
    echo -n "$TAG bedtools version: " | tee -a ${LOG}
    ${BEDTOOLS} --version | tee -a ${LOG}
    echo | tee -a ${LOG}

    echo "Mask pseudo-autosomal regions in $FASTA_FILTERED to make ${FASTA_FINISHED}..." | tee -a ${LOG}
    echo "$TAG Mask pseudo-autosomal regions in $FASTA_FILTERED to make ${FASTA_FINISHED}..." | tee -a ${LOG}
    date '+%Y.%m.%d:%H.%M.%S' | tee -a ${LOG}
    make_par_bed
    ${BEDTOOLS} maskfasta -fi $FASTA_FILTERED -bed $PAR_BED -fo $FASTA_FINISHED
    echo | tee -a ${LOG}
  else
    echo "Copy $FASTA_FILTERED to ${FASTA_FINISHED}..." | tee -a ${LOG}
    echo "$TAG Copy $FASTA_FILTERED to ${FASTA_FINISHED}..." | tee -a ${LOG}
    date '+%Y.%m.%d:%H.%M.%S' | tee -a ${LOG}
    cp $FASTA_FILTERED $FASTA_FINISHED
    echo | tee -a ${LOG}
  fi
  echo | tee -a ${LOG}

  echo "Calculate $FASTA_FINISHED file sequence md5 checksums..." | tee -a ${LOG}
  date '+%Y.%m.%d:%H.%M.%S' | tee -a ${LOG}
  $MD5_SEQ $FASTA_FINISHED > $FASTA_FINISHED.md5_seq
  sort -k1,1 $FASTA_FINISHED.md5_seq > $FASTA_FINISHED.md5_seq.sort
  echo | tee -a ${LOG}

  echo "CHECKPOINT" | tee -a ${LOG}
  echo "Report different md5 checksums from the filtered and finished fasta files (there may be none)..." | tee -a ${LOG}
  join -1 1 -2 1 $FASTA_FILTERED.md5_seq.sort $FASTA_FINISHED.md5_seq.sort \
    | sort -k1,1V \
    | awk '{printf( "%s\t%s\t%s\n", $1, $3, $5);}' \
    | awk '{if($2!=$3){printf("  ** chromosome %s differs\n",$1);}}' | tee -a ${LOG}
  echo | tee -a ${LOG}

  echo 'Done.' | tee -a ${LOG}
  echo | tee -a ${LOG}
}


#
# Compress finished fasta file (keep original).
#
function compress_finish_fasta_file()
{
  echo "Compress a copy of $FASTA_FINISHED to make ${FASTA_FINISHED}.bz2..." | tee -a ${LOG}
  date '+%Y.%m.%d:%H.%M.%S' | tee -a ${LOG}
  bzip2 -k $FASTA_FINISHED
  echo "Finished file compression" | tee -a ${LOG}
  date '+%Y.%m.%d:%H.%M.%S' | tee -a ${LOG}
  echo | tee -a ${LOG}

  echo 'Done.' | tee -a ${LOG}
  echo | tee -a ${LOG}
}


#
# Get sequence/chromosome sizes.
#
function make_chromosome_sizes_file()
{
  echo -n "$TAG samtools version: " | tee -a ${LOG}
  ${SAMTOOLS} --version | tee -a ${LOG}
  echo | tee -a ${LOG}
 
 
  echo "Make chromosome sizes file ${CHROMOSOME_SIZES_FILE}..." | tee -a ${LOG}
  date '+%Y.%m.%d:%H.%M.%S' | tee -a ${LOG}
  ${SAMTOOLS} faidx $FASTA_FILTERED
  REXP=`echo "$SEQUENCES_TO_KEEP_ANALYSIS" \
    | sed 's/[ ][ ]*/|/g' \
    | sed 's/^/(/' \
    | sed 's/$/)/'`
  cat $FASTA_FILTERED.fai | awk '{if($1~/^'$REXP'$/) { printf( "%s\t%s\n",$1,$2); } }' > $CHROMOSOME_SIZES_FILE
  echo | tee -a ${LOG}
 
  echo "CHECKPOINT" | tee -a ${LOG}
  cat $CHROMOSOME_SIZES_FILE | tee -a ${LOG}
  echo | tee -a ${LOG}

  echo 'Done.' | tee -a ${LOG}
  echo | tee -a ${LOG}
}

