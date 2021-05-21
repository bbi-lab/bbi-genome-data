#!/bin/bash


function setup_source_files()
{
  echo "Make copies of and soft links to required files from ${GENOME_DIR}..." | proc_stdout
  date '+%Y.%m.%d:%H.%M.%S' | proc_stdout

  if [ ! -f "${GENOME_DIR}/${CHROMOSOME_SIZES_ATAC_FILE}" ]
  then
    echo "ERROR: cannot find file ${GENOME_DIR}/${CHROMOSOME_SIZES_ATAC_FILE}. Exiting..." | proc_stdout
    exit -1
  fi

  if [ ! -f "${GENOME_DIR}/${CHROMOSOME_WITH_MT_SIZES_ATAC_FILE}" ]
  then
    echo "ERROR: cannot find file ${GENOME_DIR}/${CHROMOSOME_WITH_MT_SIZES_ATAC_FILE}. Exiting..." | proc_stdout
    exit -1
  fi

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

  cp ${GENOME_DIR}/${CHROMOSOME_SIZES_ATAC_FILE} .
  cp ${GENOME_DIR}/${CHROMOSOME_WITH_MT_SIZES_ATAC_FILE} .

  if [ -L "./${FASTA_FINISHED}" ]
  then
    rm "./${FASTA_FINISHED}"
  fi
  ln -s ${GENOME_DIR}/${FASTA_FINISHED} .

  if [ -L "./${GTF_GZ}" ]
  then
    rm "./${GTF_GZ}"
  fi
  ln -s ${GENOME_DIR}/${GTF_GZ} .

  echo | proc_stdout
  echo 'Done.' | proc_stdout
  echo | proc_stdout
}


function make_whitelist_regions_file()
{
  echo "Make whitelist regions bed file ${WHITELIST_REGIONS_BED}..."  | proc_stdout
  date '+%Y.%m.%d:%H.%M.%S' | proc_stdout
  cat $CHROMOSOME_SIZES_ATAC_FILE \
  | awk 'BEGIN{OFS="\t"}{ print $1,"1",$2;}' > $WHITELIST_REGIONS_BED

  echo "CHECKPOINT" | proc_stdout
  echo "Contents of file ${WHITELIST_REGIONS_BED}..." | proc_stdout
  cat $WHITELIST_REGIONS_BED | proc_stdout
  echo | proc_stdout

  echo "Make whitelist with Mt regions bed file ${WHITELIST_WITH_MT_REGIONS_BED}..."  | proc_stdout
  date '+%Y.%m.%d:%H.%M.%S' | proc_stdout
  cat $CHROMOSOME_WITH_MT_SIZES_ATAC_FILE \
  | awk 'BEGIN{OFS="\t"}{ print $1,"1",$2;}' > $WHITELIST_WITH_MT_REGIONS_BED

  echo "CHECKPOINT" | proc_stdout
  echo "Contents of file ${WHITELIST_WITH_MT_REGIONS_BED}..." | proc_stdout
  cat $WHITELIST_WITH_MT_REGIONS_BED | proc_stdout
  echo | proc_stdout

  echo | proc_stdout
  echo 'Done.' | proc_stdout
  echo | proc_stdout
}


function make_tss_file()
{
  echo "Make TSS bed file ${TSS_BED}.gz..." | proc_stdout
  date '+%Y.%m.%d:%H.%M.%S' | proc_stdout

  echo "bedtools version: " | proc_stdout ${RECORD}
  ${BEDTOOLS} --version | proc_stdout ${RECORD}
  echo | proc_stdout

  #
  # Here we make the file ${TSS_BED}.temp.
  #
  Rscript $R_GENERATE_TSS_FILE $GTF_GZ ${TSS_BED}.temp
  echo | proc_stdout

  echo "Count gene_biotype entries in ${TSS_BED}.temp by type..." | proc_stdout
  awk '{print$9}' ${TSS_BED}.temp \
    | sort \
    | uniq -c \
    | sort -k 2,2 \
    | awk '{printf( "%s\t%s\n", $1, $2 );}' > $TSS_FOUND_BIOTYPES_FILE
  cat $TSS_FOUND_BIOTYPES_FILE | proc_stdout
  echo | proc_stdout


  echo "Expected gene_biotype entries in ${TSS_BED}.temp..."  | proc_stdout
  echo $SELECT_GENE_BIOTYPES \
    | tr '|' '\n' \
    | sort -k 1,1 > $TSS_SELECT_BIOTYPES_FILE
  cat $TSS_SELECT_BIOTYPES_FILE  | proc_stdout
  echo | proc_stdout

  echo "CHECKPOINT" | proc_stdout
  echo "Expected gene_biotypes not found in ${TSS_BED}.temp (may be either partial matches or the file uses different types)..." | proc_stdout
  join -1 1 -2 2 -v 1 $TSS_SELECT_BIOTYPES_FILE $TSS_FOUND_BIOTYPES_FILE | proc_stdout
  echo | proc_stdout


  #
  # Here we make the final ${TSS_BED}.gz.
  #
  echo "Filter TSS bed file ${TSS_BED}.temp entries..." | proc_stdout
  cat ${TSS_BED}.temp \
  | grep -i -E "${SELECT_GENE_BIOTYPES}" \
  | awk 'BEGIN{OFS="\t"}{print $1,$2,$3,$4,1,$6}' \
  | sort -k1,1V -k2,2n -k3,3n \
  | ${BEDTOOLS} intersect -a stdin -b $WHITELIST_REGIONS_BED \
  | uniq \
  | gzip > ${TSS_BED}.gz
  echo | proc_stdout
  echo 'Done.' | proc_stdout
  echo | proc_stdout

  echo "Make TSS gene map file ${TSS_GENE_MAP}..."
  cat tss.bed.temp \
  | grep -i -E "${SELECT_GENE_BIOTYPES}" \
  | awk '{printf("%s\t%s\t%s\n",$4,$7,$9);}' \
  | sort -k1,1V -k2,2V -k3,3 \
  | uniq \
  | awk 'BEGIN{FS="\t"}{if($1 in short){short[$1]=short[$1]":"$2;biotype[$1]=biotype[$1]":"$3;}else{short[$1]=$2;biotype[$1]=$3}}END{for(gene in short) printf("%s\t%s\t%s\n",gene,short[gene],biotype[gene]);}' \
  | sort -k1,1V > ${TSS_GENE_MAP}
  echo | proc_stdout
  echo 'Done.' | proc_stdout
  echo | proc_stdout


  echo "CHECKPOINT" | proc_stdout
  echo "Count entries ${TSS_BED}.gz..." | proc_stdout
  zcat ${TSS_BED}.gz \
    | wc -l | proc_stdout
  echo | proc_stdout

  echo "CHECKPOINT" | proc_stdout
  echo "Count entries by sequence name in ${TSS_BED}.gz..." | proc_stdout
  zcat ${TSS_BED}.gz \
    | awk '{print$1}' \
    | sort \
    | uniq -c \
    | sort -k 2,2V \
    | awk '{printf( "%s\t%s\n", $1, $2 );}' | proc_stdout
  echo | proc_stdout

  echo | proc_stdout
  echo 'Done.' | proc_stdout
  echo | proc_stdout
}


function compress_tss_temp_file()
{
  echo "Compress a copy of ${TSS_BED}.temp to make ${TSS_BED}.temp.bz2..." | proc_stdout
  date '+%Y.%m.%d:%H.%M.%S' | proc_stdout
  bzip2 -k ${TSS_BED}.temp
  echo "Finished file compression" | proc_stdout
  date '+%Y.%m.%d:%H.%M.%S' | proc_stdout
  echo | proc_stdout

  echo 'Done.' | proc_stdout
  echo | proc_stdout
}


function make_gene_bodies_file()
{
  echo "Make gene bodies bed file ${GENE_BODIES_PLUS_UPSTREAM_BED}.gz..." | proc_stdout
  date '+%Y.%m.%d:%H.%M.%S' | proc_stdout

  echo "bedtools version: " | proc_stdout
  ${BEDTOOLS} --version | proc_stdout ${RECORD}
  echo | proc_stdout

  #
  # Here we make the ${GENE_BODIES_BED}.temp file.
  #
  Rscript $R_GENERATE_GENE_BODY_FILE $GTF_GZ ${GENE_BODIES_BED}.temp
  echo | proc_stdout


  echo "Count gene_biotype entries in ${GENE_BODIES_BED}.temp by type..." | proc_stdout
  awk '{print$8}' ${GENE_BODIES_BED}.temp \
    | sort \
    | uniq -c \
    | sort -k2,2 \
    | awk '{printf( "%s\t%s\n", $1, $2 );}' > $GENE_BODIES_FOUND_BIOTYPES_FILE
  cat $GENE_BODIES_FOUND_BIOTYPES_FILE | proc_stdout
  echo | proc_stdout


  echo "Expected gene_biotype entries in ${GENE_BODIES_BED}.temp..."  | proc_stdout
  echo $SELECT_GENE_BIOTYPES \
    | tr '|' '\n' \
    | sort -k 1,1 > $GENE_BODIES_SELECT_BIOTYPES_FILE
  cat $GENE_BODIES_SELECT_BIOTYPES_FILE  | proc_stdout
  echo | proc_stdout

  echo "CHECKPOINT" | proc_stdout
  echo "Expected gene_biotypes not found in ${GENE_BODIES_BED}.temp (may be either partial matches or the file uses different types)..." | proc_stdout
  join -1 1 -2 2 -v 1 $GENE_BODIES_SELECT_BIOTYPES_FILE $GENE_BODIES_FOUND_BIOTYPES_FILE | proc_stdout
  echo | proc_stdout

  echo "bedtools version: " | proc_stdout
  ${BEDTOOLS} --version | proc_stdout
  echo | proc_stdout


  #
  # Here we make the ${GENE_BODIES_BED}.gz and ${GENE_BODIES_PLUS_UPSTREAM_BED}.gz files.
  #
  echo "Filter gene bodies bed file ${GENE_BODIES_BED}.temp entries..." | proc_stdout
  cat ${GENE_BODIES_BED}.temp \
    | grep -i -E "${SELECT_GENE_BIOTYPES}" \
    | awk 'BEGIN{OFS="\t"}{print $1,$2,$3,$4,1,$6}' \
    | sort -k1,1V -k2,2n -k3,3n \
    | ${BEDTOOLS} intersect -a stdin -b $WHITELIST_REGIONS_BED \
    | uniq \
    | gzip > ${GENE_BODIES_BED}.gz
  
  ${BEDTOOLS} slop -i ${GENE_BODIES_BED}.gz -s -l 2000 -r 0 -g $CHROMOSOME_SIZES_ATAC_FILE \
    | sort -k1,1V -k2,2n -k3,3n \
    | gzip > ${GENE_BODIES_PLUS_UPSTREAM_BED}.gz
  echo | proc_stdout
  echo 'Done.' | proc_stdout
  echo | proc_stdout

  echo "Make gene bodies gene map file ${GENE_BODIES_GENE_MAP}..."
  cat ${GENE_BODIES_BED}.temp \
    | awk '{printf( "%s\t%s\t%s\n",$4,$7,$8);}' \
    | sort -k1,1V -k2,2V -k3,3 \
    | uniq \
    | awk 'BEGIN{FS="\t"}{if($1 in short){short[$1]=short[$1]":"$2;biotype[$1]=biotype[$1]":"$3;}else{short[$1]=$2;biotype[$1]=$3}}END{for(gene in short) printf("%s\t%s\t%s\n",gene,short[gene],biotype[gene]);}' \
    | sort -k1,1V > ${GENE_BODIES_GENE_MAP}
  echo | proc_stdout
  echo 'Done.' | proc_stdout
  echo | proc_stdout


  echo "CHECKPOINT" | proc_stdout
  echo "Count entries in ${GENE_BODIES_BED}.gz..." | proc_stdout
  zcat ${GENE_BODIES_BED}.gz \
    | wc -l | proc_stdout
  echo | proc_stdout | tee -a ${LOG}

  echo "CHECKPOINT" | proc_stdout
  echo "Count entries by sequence name in ${GENE_BODIES_BED}.gz..." | proc_stdout
  zcat ${GENE_BODIES_BED}.gz \
    | awk '{print$1}' \
    | sort \
    | uniq -c \
    | sort -k 2,2V \
    | awk '{printf( "%s\t%s\n", $1, $2 );}' | proc_stdout
  echo | proc_stdout | tee -a ${LOG}

  echo | proc_stdout
  echo 'Done.' | proc_stdout
  echo | proc_stdout
}


function compress_gene_bodies_temp_file()
{
  echo "Compress a copy of ${GENE_BODIES_BED}.temp to make ${GENE_BODIES_BED}.temp.bz2..." | proc_stdout
  date '+%Y.%m.%d:%H.%M.%S' | proc_stdout
  bzip2 -k ${GENE_BODIES_BED}.temp
  echo "Finished file compression" | proc_stdout
  date '+%Y.%m.%d:%H.%M.%S' | proc_stdout
  echo | proc_stdout

  echo 'Done.' | proc_stdout
  echo | proc_stdout
}

