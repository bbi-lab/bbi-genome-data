#!/bin/bash


function setup_source_files()
{
  echo "Make copies of and soft links to required files from ${GENOME_DIR}..." | tee -a ${LOG}
  date '+%Y.%m.%d:%H.%M.%S' | tee -a ${LOG}

  if [ ! -f "${GENOME_DIR}/${CHROMOSOME_SIZES_FILE}" ]
  then
    echo "ERROR: cannot find file ${GENOME_DIR}/${CHROMOSOME_SIZES_FILE}. Exiting..." | tee -a ${LOG}
    exit -1
  fi

  if [ ! -f "${GENOME_DIR}/${FASTA_FINISHED}" ]
  then
    echo "ERROR: cannot find file ${GENOME_DIR}/${FASTA_FINISHED}. Exiting..." | tee -a ${LOG}
    exit -1
  fi

  if [ ! -f "${GENOME_DIR}/${GTF_GZ}" ]
  then
    echo "ERROR: cannot find file ${GENOME_DIR}/${GTF_GZ}. Exiting..." | tee -a ${LOG}
    exit -1
  fi

  cp ${GENOME_DIR}/${CHROMOSOME_SIZES_FILE} .
  ln -s ${GENOME_DIR}/${FASTA_FINISHED} .
  ln -s ${GENOME_DIR}/${GTF_GZ} .

  echo | tee -a ${LOG}
  echo 'Done.' | tee -a ${LOG}
  echo | tee -a ${LOG}
}


function make_whitelist_regions_file()
{
  echo "Make whitelist regions bed file ${WHITELIST_REGIONS_BED}..."  | tee -a ${LOG}
  date '+%Y.%m.%d:%H.%M.%S' | tee -a ${LOG}
  cat $CHROMOSOME_SIZES_FILE \
  | awk 'BEGIN{OFS="\t"}{ print $1,"1",$2;}' > $WHITELIST_REGIONS_BED

  echo "CHECKPOINT" | tee -a ${LOG}
  echo "Contents of file ${WHITELIST_REGIONS_BED}..." | tee -a ${LOG}
  cat $WHITELIST_REGIONS_BED | tee -a ${LOG}
  echo | tee -a ${LOG}

  echo | tee -a ${LOG}
  echo 'Done.' | tee -a ${LOG}
  echo | tee -a ${LOG}
}


function make_tss_file()
{
  echo "Make TSS bed file ${TSS_BED}.gz..." | tee -a ${LOG}
  date '+%Y.%m.%d:%H.%M.%S' | tee -a ${LOG}

  echo -n "bedtools version: " | tee -a ${LOG}
  ${BEDTOOLS} --version | tee -a ${LOG}
  echo -n "$TAG bedtools version: " | tee -a ${LOG}
  ${BEDTOOLS} --version | tee -a ${LOG}
  echo | tee -a ${LOG}

  #
  # Here we do the work.
  #
  Rscript $R_GENERATE_TSS_FILE $GTF_GZ ${TSS_BED}.temp
  echo | tee -a ${LOG}

  echo "Count gene_biotype entries in ${TSS_BED}.temp by type..." | tee -a ${LOG}
  awk '{print$9}' ${TSS_BED}.temp \
    | sort \
    | uniq -c \
    | sort -k 2,2 \
    | awk '{printf( "%s\t%s\n", $1, $2 );}' > $TSS_FOUND_BIOTYPES_FILE
  cat $TSS_FOUND_BIOTYPES_FILE | tee -a ${LOG}
  echo | tee -a ${LOG}

  echo "Expected gene_biotype entries in ${TSS_BED}.temp..."  | tee -a ${LOG}
  echo $SELECT_GENE_BIOTYPES \
    | tr '|' '\n' \
    | sort -k 1,1 > $TSS_SELECT_BIOTYPES_FILE
  cat $TSS_SELECT_BIOTYPES_FILE  | tee -a ${LOG}
  echo | tee -a ${LOG}

  echo "CHECKPOINT" | tee -a ${LOG}
  echo "Expected gene_biotypes not found in ${TSS_BED}.temp (may be either partial matches or the file uses different types)..." | tee -a ${LOG}
  join -1 1 -2 2 -v 1 $TSS_SELECT_BIOTYPES_FILE $TSS_FOUND_BIOTYPES_FILE | tee -a ${LOG}
  echo | tee -a ${LOG}


  #
  # Here we do the work.
  #
  echo "Filter TSS bed file ${TSS_BED}.temp entries..." | tee -a ${LOG}
  cat ${TSS_BED}.temp \
  | grep -i -E "${SELECT_GENE_BIOTYPES}" \
  | awk 'BEGIN{OFS="\t"}{print $1,$2,$3,$4,1,$6}' \
  | sort -k1,1V -k2,2n -k3,3n \
  | ${BEDTOOLS} intersect -a stdin -b $WHITELIST_REGIONS_BED \
  | uniq \
  | gzip > ${TSS_BED}.gz
  echo | tee -a ${LOG}
  echo 'Done.' | tee -a ${LOG}
  echo | tee -a ${LOG}

  echo "Make TSS gene map file ${TSS_GENE_MAP}..."
  cat tss.bed.temp \
  | grep -i -E "${SELECT_GENE_BIOTYPES}" \
  | awk '{print$4,$7,$9}' \
  | sort -k1,1V -k2,2V -k3,3 \
  | uniq \
  | less \
  | awk 'BEGIN{FS=" "}{if($1 in short){short[$1]=short[$1]":"$2;biotype[$1]=biotype[$1]":"$3;}else{short[$1]=$2;biotype[$1]=$3}}END{for(gene in short) printf("%s %s %s\n",gene,short[gene],biotype[gene]);}' \
  | sort -k1,1V > ${TSS_GENE_MAP}
  echo | tee -a ${LOG}
  echo 'Done.' | tee -a ${LOG}
  echo | tee -a ${LOG}


  echo "CHECKPOINT" | tee -a ${LOG}
  echo "Count entries ${TSS_BED}.gz..." | tee -a ${LOG}
  zcat ${TSS_BED}.gz \
    | wc -l | tee -a ${LOG}
  echo | tee -a ${LOG}

  echo "CHECKPOINT" | tee -a ${LOG}
  echo "Count entries by sequence name in ${TSS_BED}.gz..." | tee -a ${LOG}
  zcat ${TSS_BED}.gz \
    | awk '{print$1}' \
    | sort \
    | uniq -c \
    | sort -k 2,2V \
    | awk '{printf( "%s\t%s\n", $1, $2 );}' | tee -a ${LOG}
  echo | tee -a ${LOG}

  echo | tee -a ${LOG}
  echo 'Done.' | tee -a ${LOG}
  echo | tee -a ${LOG}
}


function make_gene_bodies_file()
{
  echo "Make gene bodies bed file ${GENE_BODIES_PLUS_UPSTREAM_BED}.gz..." | tee -a ${LOG}
  date '+%Y.%m.%d:%H.%M.%S' | tee -a ${LOG}

  echo -n "bedtools version: " | tee -a ${LOG}
  ${BEDTOOLS} --version | tee -a ${LOG}
  echo -n "$TAG bedtools version: " | tee -a ${LOG}
  ${BEDTOOLS} --version | tee -a ${LOG}
  echo | tee -a ${LOG}

  #
  # Here we do the work.
  #
  Rscript $R_GENERATE_GENE_BODY_FILE $GTF_GZ ${GENE_BODIES_BED}.temp
  echo | tee -a ${LOG}


  echo "Count gene_biotype entries in ${GENE_BODIES_BED}.temp by type..." | tee -a ${LOG}
  awk '{print$8}' ${GENE_BODIES_BED}.temp \
    | sort \
    | uniq -c \
    | sort -k2,2 \
    | awk '{printf( "%s\t%s\n", $1, $2 );}' > $GENE_BODIES_FOUND_BIOTYPES_FILE
  cat $GENE_BODIES_FOUND_BIOTYPES_FILE | tee -a ${LOG}
  echo | tee -a ${LOG}

  echo "Expected gene_biotype entries in ${GENE_BODIES_BED}.temp..."  | tee -a ${LOG}
  echo $SELECT_GENE_BIOTYPES \
    | tr '|' '\n' \
    | sort -k 1,1 > $GENE_BODIES_SELECT_BIOTYPES_FILE
  cat $GENE_BODIES_SELECT_BIOTYPES_FILE  | tee -a ${LOG}
  echo | tee -a ${LOG}

  echo "CHECKPOINT" | tee -a ${LOG}
  echo "Expected gene_biotypes not found in ${GENE_BODIES_BED}.temp (may be either partial matches or the file uses different types)..." | tee -a ${LOG}
  join -1 1 -2 2 -v 1 $GENE_BODIES_SELECT_BIOTYPES_FILE $GENE_BODIES_FOUND_BIOTYPES_FILE | tee -a ${LOG}
  echo | tee -a ${LOG}

  echo -n "bedtools version: " | tee -a ${LOG}
  ${BEDTOOLS} --version | tee -a ${LOG}
  echo | tee -a ${LOG}


  #
  # Here we do the work.
  #
  echo "Filter gene bodies bed file ${GENE_BODIES_BED}.temp entries..." | tee -a ${LOG}
  cat ${GENE_BODIES_BED}.temp \
    | grep -i -E "${SELECT_GENE_BIOTYPES}" \
    | awk 'BEGIN{OFS="\t"}{print $1,$2,$3,$4,1,$6}' \
    | sort -k1,1V -k2,2n -k3,3n \
    | ${BEDTOOLS} intersect -a stdin -b $WHITELIST_REGIONS_BED \
    | uniq \
    | gzip > ${GENE_BODIES_BED}.gz
  
  ${BEDTOOLS} slop -i ${GENE_BODIES_BED}.gz -s -l 2000 -r 0 -g $CHROMOSOME_SIZES_FILE \
    | sort -k1,1V -k2,2n -k3,3n \
    | gzip > ${GENE_BODIES_PLUS_UPSTREAM_BED}.gz
  echo | tee -a ${LOG}
  echo 'Done.' | tee -a ${LOG}
  echo | tee -a ${LOG}

  echo "Make gene bodies gene map file ${GENE_BODIES_GENE_MAP}..."
  cat ${GENE_BODIES_BED}.temp \
    | grep -i -E "${SELECT_GENE_BIOTYPES}" \
    | awk '{print$4,$7,$9}' \
    | sort -k1,1V -k2,2V -k3,3 \
    | uniq \
    | less \
    | awk 'BEGIN{FS=" "}{if($1 in short){short[$1]=short[$1]":"$2;biotype[$1]=biotype[$1]":"$3;}else{short[$1]=$2;biotype[$1]=$3}}END{for(gene in short) printf("%s %s %s\n",gene,short[gene],biotype[gene]);}' \
    | sort -k1,1V > ${GENE_BODIES_GENE_MAP}
  echo | tee -a ${LOG}
  echo 'Done.' | tee -a ${LOG}
  echo | tee -a ${LOG}


  echo "CHECKPOINT" | tee -a ${LOG}
  echo "Count entries in ${GENE_BODIES_BED}.gz..." | tee -a ${LOG}
  zcat ${GENE_BODIES_BED}.gz \
    | wc -l | tee -a ${LOG}
  echo | tee -a ${LOG} | tee -a ${LOG}

  echo "CHECKPOINT" | tee -a ${LOG}
  echo "Count entries by sequence name in ${GENE_BODIES_BED}.gz..." | tee -a ${LOG}
  zcat ${GENE_BODIES_BED}.gz \
    | awk '{print$1}' \
    | sort \
    | uniq -c \
    | sort -k 2,2V \
    | awk '{printf( "%s\t%s\n", $1, $2 );}' | tee -a ${LOG}
  echo | tee -a ${LOG} | tee -a ${LOG}

  echo | tee -a ${LOG}
  echo 'Done.' | tee -a ${LOG}
  echo | tee -a ${LOG}
}

