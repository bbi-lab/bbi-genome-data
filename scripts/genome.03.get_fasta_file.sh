#!/bin/bash

function get_fasta_file
{
  rm -f $FASTA_GZ
  rm -f $FASTA
  rm -f ${CHECKSUMS}.dna
  rm -f ${README}.dna

  echo "Download and uncompress fasta file" | proc_stdout
  date '+%Y.%m.%d:%H.%M.%S' | proc_stdout ${RECORD} fasta_download_date

  echo "URL is ${ENSEMBL_DNA_URL}" | proc_stdout
  echo "Fasta filename is $FASTA_GZ" | proc_stdout

  echo "Download fasta file..." | proc_stdout
  echo "Genome fasta file URL: ${ENSEMBL_DNA_URL}/$FASTA_GZ" | proc_stdout ${RECORD} fasta_url

  wget --no-verbose ${ENSEMBL_DNA_URL}/$FASTA_GZ 2>&1 | proc_stdout
  echo | proc_stdout

  echo "Download ${CHECKSUMS}..." | proc_stdout
  wget --no-verbose ${ENSEMBL_DNA_URL}/${CHECKSUMS} 2>&1 | proc_stdout
  mv ${CHECKSUMS} ${CHECKSUMS}.dna 2>&1 | proc_stdout
  echo | proc_stdout

  echo "Download ${README}..." | proc_stdout
  wget --no-verbose ${ENSEMBL_DNA_URL}/${README} 2>&1 | proc_stdout
  mv ${README} ${README}.dna 2>&1 | proc_stdout
  echo | proc_stdout

  echo "CHECKPOINT" | proc_stdout
  echo "Calculated $FASTA_GZ checksum is " | proc_stdout ${RECORD}
  sum $FASTA_GZ | tee ${FASTA_GZ}.checksum | proc_stdout ${RECORD}
  echo "Expected $FASTA_GZ checksum is " | proc_stdout ${RECORD}
  grep $FASTA_GZ ${CHECKSUMS}.dna | awk '{print$1,$2}' 2>&1 | proc_stdout ${RECORD}
  echo | proc_stdout

  echo "Uncompress $FASTA file..." | proc_stdout
  zcat $FASTA_GZ > $FASTA
  echo | proc_stdout

  echo 'Done.' | proc_stdout
  echo | proc_stdout
}


#
# Count the Ensembl sequence types in the fasta file.
#
function get_fasta_info()
{
  echo "Calculate $FASTA file sequence md5 checksums..." | proc_stdout
  date '+%Y.%m.%d:%H.%M.%S' | proc_stdout
  $MD5_SEQ $FASTA > $FASTA.md5_seq
  echo | proc_stdout

  echo "md5 checksums of sequences in $FASTA (reporting only names that match '([0-9]+|[XY]|MT)' )..." | proc_stdout ${RECORD}
  echo "(The ATAC-seq pipeline requires that these have the order 1 ... <n> X Y MT)" | proc_stdout ${RECORD}
  cat $FASTA.md5_seq | awk '$1~/^([0-9]+|[XY]|MT)/' | proc_stdout ${RECORD}
  echo | proc_stdout

  echo "Get fasta sequence headers in $FASTA file..." | proc_stdout
  grep '^>' $FASTA > $FASTA.headers
  echo | proc_stdout

  echo "CHECKPOINT" | proc_stdout
  echo "Fasta sequence header in $FASTA file..." | proc_stdout
  cat $FASTA.headers | proc_stdout
  echo | proc_stdout

  echo "CHECKPOINT" | proc_stdout
  echo "Fasta sequence type counts in $FASTA file..." | proc_stdout
  awk '{print$4}' $FASTA.headers  \
    | sort \
    | uniq -c | proc_stdout
  echo | proc_stdout

  echo 'Done.' | proc_stdout
  echo | proc_stdout
}
