#!/bin/bash


#
# Choose aligner subject squences, keeping reference sequences.
# Notes:
#   o  this is written to use the current Ensembl fasta headers,
#      in which the fourth token is the sequence type.
#   o  select all sequences in which the fourth token is 'REF', which
#      we expect to be reference sequences.
#   o  use sequences_to_keep_ref(), sequences_to_keep_named(), or
#      sequences_to_keep_all to make the file $FINAL_IDS_FILE.
#
function sequences_to_keep_ref()
{
  echo "Keep the REF sequences for read alignments in ${FASTA}..." | proc_stdout
  date '+%Y.%m.%d:%H.%M.%S' | proc_stdout
  cat ${FASTA}.headers \
    | awk '{if($4=="REF"){print$1}}' \
    | sed 's/^>//' > $FINAL_IDS_FILE
  echo | proc_stdout

  echo "CHECKPOINT" | proc_stdout
  cat $FINAL_IDS_FILE | proc_stdout
  echo | proc_stdout

  echo 'Done.' | proc_stdout
  echo | proc_stdout
}


#
# Choose aligner subject sequences named in the environment variable SEQUENCES_TO_KEEP_ALIGNER...
# Notes:
#   o  select sequences named in the variable SEQUENCES_TO_KEEP_ALIGNER, which
#      must be set appropriately in the files 'genome.<organims>.sh'.
#   o  use sequences_to_keep_ref(), sequences_to_keep_named(), or
#      sequences_to_keep_all to make the file $FINAL_IDS_FILE.
#
function sequences_to_keep_named()
{
  if [ "${SEQUENCES_TO_KEEP_ALIGNER}" == "" ]
  then
    echo "Error: SEQUENCES_TO_KEEP_ALIGNER variable is not set"
    echo "       Edit genome.<organism>.txt"
    exit -1
  fi

  echo "Keep the named sequences for read alignments in ${FASTA}..." | proc_stdout
  date '+%Y.%m.%d:%H.%M.%S' | proc_stdout
  echo "Sequences kept from fasta: ${SEQUENCES_TO_KEEP_ALIGNER}" | proc_stdout ${RECORD} fasta_seqs_kept
  echo | proc_stdout
  echo "$SEQUENCES_TO_KEEP_ALIGNER" | sed 's/[ ][ ]*/\n/g' > $FINAL_IDS_FILE
  echo | proc_stdout

  echo "CHECKPOINT" | proc_stdout
  cat $FINAL_IDS_FILE | proc_stdout
  echo | proc_stdout

  echo 'Done.' | proc_stdout
  echo | proc_stdout
}


#
# Keep all fasta sequences for the aligner.
# Notes:
#   o  select sequences named in the variable SEQUENCES_TO_KEEP_ALIGNER, which
#      must be set appropriately in the files 'genome.<organims>.sh'.
#   o  use either sequences_to_keep_ref() or sequences_to_keep_named() to
#      make the file $FINAL_IDS_FILE but not both.
#
function sequences_to_keep_all()
{
  echo "Keep all genome sequences for read alignments in ${FASTA}..." | proc_stdout
  date '+%Y.%m.%d:%H.%M.%S' | proc_stdout
  cat ${FASTA}.headers \
    | awk '{print$1}' \
    | sed 's/^>//' > $FINAL_IDS_FILE
  echo | proc_stdout

  echo "CHECKPOINT" | proc_stdout
  cat $FINAL_IDS_FILE | proc_stdout
  echo | proc_stdout

  echo 'Done.' | proc_stdout
  echo | proc_stdout
}


#
# Extract the specified sequences into a new fasta file called ${FASTA}.filtered.
#
function filter_fasta_file()
{ 
  echo "Extract selected sequences from the fasta file ${FASTA}..." | proc_stdout
  date '+%Y.%m.%d:%H.%M.%S' | proc_stdout
  $FASTA_GETSEQS $FINAL_IDS_FILE $FASTA > $FASTA_FILTERED
  echo | proc_stdout

  echo "CHECKPOINT" | proc_stdout
  echo "Count the sequences in the filtered fasta file ${FASTA_FILTERED}..." | proc_stdout ${RECORD}
  grep '^>' $FASTA_FILTERED | wc -l | proc_stdout ${RECORD}
  echo | proc_stdout
  
  echo "Calculate filtered fasta file sequence md5 checksums for ${FASTA}..." | proc_stdout
  $MD5_SEQ $FASTA_FILTERED > $FASTA_FILTERED.md5_seq
  echo | proc_stdout

  echo "Compare the md5 checksums for the downloaded and filtered fasta files..." | proc_stdout
  echo | proc_stdout
  sort -k1,1 $FASTA.md5_seq > $FASTA.md5_seq.sort
  sort -k1,1 $FASTA_FILTERED.md5_seq > $FASTA_FILTERED.md5_seq.sort
  join -1 1 -2 1 ${FASTA}.md5_seq.sort ${FASTA_FILTERED}.md5_seq.sort \
    | sort -k1,1V \
    | awk '{printf( "%s\t%s\t%s\t%s\t%s\n", $1, $3, $5, $2, $4);}' | proc_stdout
  echo | proc_stdout

  echo "CHECKPOINT" | proc_stdout
  echo "Check for inconsistent md5 checksums for the downloaded and filtered fasta files and report differences as ERRORs..." | proc_stdout ${RECORD}
  join -1 1 -2 1 $FASTA.md5_seq.sort $FASTA_FILTERED.md5_seq.sort \
    | sort -k1,1V \
    | awk '{printf( "%s\t%s\t%s\n", $1, $3, $5, $2, $4);}' \
    | awk 'BEGIN{eflag=0;}{if($2!=$3){printf("ERROR: inconsistent md5sum values for chromosome %s ((lengths %s %s)\n",$1,$4,$5);eflag=1;}}END{if(eflag==0){printf("No differences.\n");}}' | proc_stdout ${RECORD}
  echo | proc_stdout

  echo 'Done.' | proc_stdout
  echo | proc_stdout
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
    echo "bedtools version: " | proc_stdout ${RECORD}
    ${BEDTOOLS} --version | proc_stdout ${RECORD}
    echo | proc_stdout

    echo "Mask pseudo-autosomal regions in $FASTA_FILTERED to make ${FASTA_FINISHED}..." | proc_stdout ${RECORD}
    date '+%Y.%m.%d:%H.%M.%S' | proc_stdout
    make_par_bed
    echo "PAR bed file" | proc_stdout ${RECORD}
    cat $PAR_BED | proc_stdout ${RECORD}
    ${BEDTOOLS} maskfasta -fi $FASTA_FILTERED -bed $PAR_BED -fo $FASTA_FINISHED
    echo | proc_stdout
  else
    echo "Copy $FASTA_FILTERED to ${FASTA_FINISHED}..." | proc_stdout ${RECORD}
    date '+%Y.%m.%d:%H.%M.%S' | proc_stdout
    cp $FASTA_FILTERED $FASTA_FINISHED
    echo | proc_stdout
  fi
  echo | proc_stdout

  echo "Calculate $FASTA_FINISHED file sequence md5 checksums..." | proc_stdout
  date '+%Y.%m.%d:%H.%M.%S' | proc_stdout
  $MD5_SEQ $FASTA_FINISHED > $FASTA_FINISHED.md5_seq
  sort -k1,1 $FASTA_FINISHED.md5_seq > $FASTA_FINISHED.md5_seq.sort
  echo | proc_stdout

  echo "CHECKPOINT" | proc_stdout
  echo "Report different md5 checksums from the filtered and finished fasta files (there may be none)..." | proc_stdout ${RECORD}
  echo "Masking pseudo-autosomal, paralogous, regions changes sequences."
  join -1 1 -2 1 ${FASTA_FILTERED}.md5_seq.sort ${FASTA_FINISHED}.md5_seq.sort \
    | sort -k1,1V \
    | awk '{printf( "%s\t%s\t%s\t%s\t%s\n", $1, $3, $5, $2, $4);}' \
    | awk 'BEGIN{eflag=0;}{if($2!=$3){printf("  ** chromosome %s differs (lengths %s %s)\n",$1,$4,$5);eflag=1;}}END{if(eflag==0){printf("No differences.\n");}}' | proc_stdout ${RECORD}
  echo | proc_stdout

  echo 'Done.' | proc_stdout
  echo | proc_stdout
}


#
# Compress finished fasta file (keep original).
#
function compress_finish_fasta_file()
{
  echo "Compress a copy of $FASTA_FINISHED to make ${FASTA_FINISHED}.bz2..." | proc_stdout
  date '+%Y.%m.%d:%H.%M.%S' | proc_stdout
  bzip2 -k $FASTA_FINISHED
  echo "Finished file compression" | proc_stdout
  date '+%Y.%m.%d:%H.%M.%S' | proc_stdout
  echo | proc_stdout

  echo 'Done.' | proc_stdout
  echo | proc_stdout
}


#
# Get sequence/chromosome sizes.
#
function make_chromosome_sizes_files()
{
  if [ "${SEQUENCES_TO_KEEP_ATAC_ANALYSIS}" == "" ]
  then
    echo "Error: SEQUENCES_TO_KEEP_ATAC_ANALYSIS variable is not set"
    echo "       Edit genome.<organism>.txt"
    exit -1
  fi

  if [ "${SEQUENCES_WITH_MT_TO_KEEP_ATAC_ANALYSIS}" == "" ]
  then
    echo "Error: SEQUENCES_WITH_MT_TO_KEEP_ATAC_ANALYSIS variable is not set"
    echo "       Edit genome.<organism>.txt"
    exit -1
  fi

  echo "samtools version: " | proc_stdout
  ${SAMTOOLS} --version | proc_stdout
  echo | proc_stdout

  echo "Make chromosome sizes file ${CHROMOSOME_SIZES_FASTA_FINISHED_FILE}..." | proc_stdout
  date '+%Y.%m.%d:%H.%M.%S' | proc_stdout
  ${SAMTOOLS} faidx $FASTA_FINISHED
  cat $FASTA_FINISHED.fai | awk '{printf( "%s\t%s\n",$1,$2); }' > $CHROMOSOME_SIZES_FASTA_FINISHED_FILE
  echo | proc_stdout

  echo "CHECKPOINT" | proc_stdout
  cat $CHROMOSOME_SIZES_FASTA_FINISHED_FILE | proc_stdout
  echo | proc_stdout

  echo "Make sci-ATAC chromosome sizes file ${CHROMOSOME_SIZES_ATAC_FILE}..." | proc_stdout
  date '+%Y.%m.%d:%H.%M.%S' | proc_stdout
  ${SAMTOOLS} faidx $FASTA_FINISHED
  REXP=`echo "$SEQUENCES_TO_KEEP_ATAC_ANALYSIS" \
    | sed 's/[ ][ ]*/|/g' \
    | sed 's/^/(/' \
    | sed 's/$/)/'`
  cat $FASTA_FINISHED.fai | awk '{if($1~/^'$REXP'$/) { printf( "%s\t%s\n",$1,$2); } }' > $CHROMOSOME_SIZES_ATAC_FILE
  echo | proc_stdout
 
  echo "CHECKPOINT" | proc_stdout
  echo "Contents of chromosome sizes file ${CHROMOSOME_SIZES_FASTA_FINISHED_FILE}." | proc_stdout $RECORD
  cat $CHROMOSOME_SIZES_ATAC_FILE | proc_stdout $RECORD
  echo | proc_stdout $RECORD

  echo "Make sci-ATAC chromosome with Mt sizes file ${CHROMOSOME_WITH_MT_SIZES_ATAC_FILE}..." | proc_stdout
  date '+%Y.%m.%d:%H.%M.%S' | proc_stdout
  ${SAMTOOLS} faidx $FASTA_FINISHED
  REXP=`echo "$SEQUENCES_WITH_MT_TO_KEEP_ATAC_ANALYSIS" \
    | sed 's/[ ][ ]*/|/g' \
    | sed 's/^/(/' \
    | sed 's/$/)/'`
  cat $FASTA_FINISHED.fai | awk '{if($1~/^'$REXP'$/) { printf( "%s\t%s\n",$1,$2); } }' > $CHROMOSOME_WITH_MT_SIZES_ATAC_FILE
  echo | proc_stdout

  echo "CHECKPOINT" | proc_stdout
  echo "Contents of chromosome sizes with Mt file ${CHROMOSOME_SIZES_FASTA_FINISHED_FILE}." | proc_stdout $RECORD
  cat $CHROMOSOME_WITH_MT_SIZES_ATAC_FILE | proc_stdout $RECORD
  echo | proc_stdout $RECORD

  echo 'Done.' | proc_stdout
  echo | proc_stdout
}

