#!/bin/bash


function get_gtf_file()
{
  rm -f $GTF_GZ
  rm -f ${CHECKSUMS}.gtf
  rm -f ${README}.gtf

  echo "Download and uncompress GTF file ${GTF_GZ}..." | tee -a ${LOG}
  date '+%Y.%m.%d:%H.%M.%S' | tee -a ${LOG}
  echo "URL is ${ENSEMBL_GTF_URL}" | tee -a ${LOG}
  echo "GTF filename is $GTF_GZ" | tee -a ${LOG}
  date '+%Y.%m.%d:%H.%M.%S' | tee -a ${LOG}
  echo "Download GTF file..." | tee -a ${LOG}
  echo "${TAG} genome GTF file URL: ${ENSEMBL_GTF_URL}/$GTF_GZ" | tee -a ${LOG}
  wget --no-verbose ${ENSEMBL_GTF_URL}/$GTF_GZ 2>&1 | tee -a ${LOG}
  echo | tee -a ${LOG}

  echo "Download ${CHECKSUMS}..." | tee -a ${LOG}
  wget --no-verbose ${ENSEMBL_GTF_URL}/${CHECKSUMS} 2>&1 | tee -a ${LOG}
  mv ${CHECKSUMS} ${CHECKSUMS}.gtf 2>&1 | tee -a ${LOG}
  echo | tee -a ${LOG}

  echo "Download ${README}..." | tee -a ${LOG}
  wget --no-verbose ${ENSEMBL_GTF_URL}/${README} 2>&1 | tee -a ${LOG}
  mv ${README} ${README}.gtf 2>&1 | tee -a ${LOG}
  echo | tee -a ${LOG}

  echo "CHECKPOINT" | tee -a ${LOG}
  echo -n "Calculated ${GTF_GZ} checksum is " | tee -a ${LOG}
  sum $GTF_GZ | tee ${GTF_GZ}.checksum | tee -a ${LOG}
  echo -n "Expected $GTF_GZ checksum is " | tee -a ${LOG}
  grep $GTF_GZ CHECKSUMS.gtf | awk '{print$1,$2}' 2>&1 | tee -a ${LOG}
  echo | tee -a ${LOG}

  echo 'Done.' | tee -a ${LOG}
  echo | tee -a ${LOG}
}


function get_gtf_info()
{
  echo "CHECKPOINT" | tee -a ${LOG}
  echo "Count total number of annotations per sequence in ${GTF_GZ}..." | tee -a ${LOG}
  date '+%Y.%m.%d:%H.%M.%S' | tee -a ${LOG}
  zcat $GTF_GZ \
    | grep -v '^#' \
    | awk '{print$1}' \
    | sort \
    | uniq -c \
    | sort -k2,2V \
    | awk '{printf( "%s\t%s\n", $1, $2 );}' | tee -a ${LOG}
  echo | tee -a ${LOG}

  echo "CHECKPOINT" | tee -a ${LOG}
  echo "Count number of 'transcripts' per sequence in ${GTF_GZ}..." | tee -a ${LOG}
  zcat $GTF_GZ \
    | grep -v '^#' \
    | awk 'BEGIN{FS="\t"}{if($3=="transcript"){print$1}}' \
    | sort \
    | uniq -c \
    | sort -k2,2V  \
    | awk '{printf( "%s\t%s\n", $1, $2 );}' | tee -a ${LOG}
  echo | tee -a ${LOG}

  echo "CHECKPOINT" | tee -a ${LOG}
  echo "Count gene_biotypes in ${GTF_GZ}..." | tee -a ${LOG}
  zcat $GTF_GZ \
    | grep -v '^#' \
    | awk 'BEGIN{FS="\t"}{if($3=="transcript"){printf( "%s; %s\n",$1,$9);}}' \
    | awk 'BEGIN{FS=";"}{print$1,$8}' \
    | awk '{print$1,$3}' \
    | sed 's/"//g' \
    | awk '{dict[$2]+=1;}END{for( key in dict ){ printf( "%d\t%s\n", dict[key], key ); }}' \
    | sort -k 2,2 | tee -a ${LOG}
  echo | tee -a ${LOG}

  echo 'Done.' | tee -a ${LOG}
  echo | tee -a ${LOG}
}

