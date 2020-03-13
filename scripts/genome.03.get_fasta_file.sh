#!/bin/bash

function get_fasta_file
{
  rm -f $FASTA_GZ
  rm -f $FASTA
  rm -f ${CHECKSUMS}.dna
  rm -f ${README}.dna

  echo "Download and uncompress fasta file" | tee -a ${LOG}
  date '+%Y.%m.%d:%H.%M.%S' | tee -a ${LOG}
  echo "URL is ${ENSEMBL_DNA_URL}" | tee -a ${LOG}
  echo "Fasta filename is $FASTA_GZ" | tee -a ${LOG}
  echo "Download fasta file..." | tee -a ${LOG}
  echo "${TAG} Genome fasta file URL: ${ENSEMBL_DNA_URL}/$FASTA_GZ" | tee -a ${LOG}
  wget --no-verbose ${ENSEMBL_DNA_URL}/$FASTA_GZ 2>&1 | tee -a ${LOG}
  echo | tee -a ${LOG}

  echo "Download ${CHECKSUMS}..." | tee -a ${LOG}
  wget --no-verbose ${ENSEMBL_DNA_URL}/${CHECKSUMS} 2>&1 | tee -a ${LOG}
  mv ${CHECKSUMS} ${CHECKSUMS}.dna 2>&1 | tee -a ${LOG}
  echo | tee -a ${LOG}

  echo "Download ${README}..." | tee -a ${LOG}
  wget --no-verbose ${ENSEMBL_DNA_URL}/${README} 2>&1 | tee -a ${LOG}
  mv ${README} ${README}.dna 2>&1 | tee -a ${LOG}
  echo | tee -a ${LOG}

  echo "CHECKPOINT" | tee -a ${LOG}
  echo -n "Calculated $FASTA_GZ checksum is " | tee -a ${LOG}
  sum $FASTA_GZ | tee ${FASTA_GZ}.checksum | tee -a ${LOG}
  echo -n "Expected $FASTA_GZ checksum is " | tee -a ${LOG}
  grep $FASTA_GZ ${CHECKSUMS}.dna | awk '{print$1,$2}' 2>&1 | tee -a ${LOG}
  echo | tee -a ${LOG}

  echo "Uncompress $FASTA file..." | tee -a ${LOG}
  zcat $FASTA_GZ > $FASTA
  echo | tee -a ${LOG}

  echo 'Done.' | tee -a ${LOG}
  echo | tee -a ${LOG}
}


#
# Count the Ensembl sequence types in the fasta file.
#
function get_fasta_info()
{
  echo "Calculate $FASTA file sequence md5 checksums..." | tee -a ${LOG}
  date '+%Y.%m.%d:%H.%M.%S' | tee -a ${LOG}
  $MD5_SEQ $FASTA > $FASTA.md5_seq
  echo | tee -a ${LOG}

  echo "Get fasta sequence headers in $FASTA file..." | tee -a ${LOG}
  grep '^>' $FASTA > $FASTA.headers
  echo | tee -a ${LOG}
 
  echo "CHECKPOINT" | tee -a ${LOG}
  echo "Fasta sequence header in $FASTA file..." | tee -a ${LOG}
  cat $FASTA.headers | tee -a ${LOG}
  echo | tee -a ${LOG}

  echo "CHECKPOINT" | tee -a ${LOG}
  echo "Fasta sequence type counts in $FASTA file..." | tee -a ${LOG}
  awk '{print$4}' $FASTA.headers  \
    | sort \
    | uniq -c | tee -a ${LOG}
  echo | tee -a ${LOG}

  echo 'Done.' | tee -a ${LOG}
  echo | tee -a ${LOG}
}

