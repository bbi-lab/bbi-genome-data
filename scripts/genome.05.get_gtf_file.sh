#!/bin/bash


function get_gtf_file()
{
  rm -f $GTF_GZ
  rm -f ${CHECKSUMS}.gtf
  rm -f ${README}.gtf

  if [ "${WGET_GTF_GZ}" == "1" ]
  then

    echo "Download and uncompress GTF file ${GTF_GZ}..." | proc_stdout
    date '+%Y.%m.%d:%H.%M.%S' | proc_stdout ${RECORD} gtf_download_date

    echo "URL is ${ENSEMBL_GTF_URL}" | proc_stdout
    echo "GTF filename is $GTF_GZ" | proc_stdout

    echo "Download GTF file..." | proc_stdout
    echo "Genome GTF file URL: ${ENSEMBL_GTF_URL}/$GTF_GZ" | proc_stdout ${RECORD} gtf_url

    wget --no-verbose ${ENSEMBL_GTF_URL}/$GTF_GZ 2>&1 | proc_stdout
    echo | proc_stdout

    echo "Download ${CHECKSUMS}..." | proc_stdout
    wget --no-verbose ${ENSEMBL_GTF_URL}/${CHECKSUMS} 2>&1 | proc_stdout
    mv ${CHECKSUMS} ${CHECKSUMS}.gtf 2>&1 | proc_stdout
    echo | proc_stdout

    echo "Download ${README}..." | proc_stdout
    wget --no-verbose ${ENSEMBL_GTF_URL}/${README} 2>&1 | proc_stdout
    mv ${README} ${README}.gtf 2>&1 | proc_stdout
    echo | proc_stdout

    echo "CHECKPOINT" | proc_stdout
    echo "Calculated ${GTF_GZ} checksum is " | proc_stdout ${RECORD}
    sum $GTF_GZ | tee ${GTF_GZ}.checksum | proc_stdout ${RECORD}
    echo "Expected $GTF_GZ checksum is " | proc_stdout ${RECORD}
    grep $GTF_GZ CHECKSUMS.gtf | awk '{print$1,$2}' 2>&1 | proc_stdout ${RECORD}
    echo | proc_stdout

  else

    echo "Copy and uncompress GTF file ${GTF_GZ}..." | proc_stdout
    date '+%Y.%m.%d:%H.%M.%S' | proc_stdout ${RECORD} gtf_download_date

    echo "Source directory is ${ENSEMBL_GTF_URL}" | proc_stdout
    echo "GTF filename is $GTF_GZ" | proc_stdout

    echo "Copy GTF file..." | proc_stdout
    echo "Copy GTF file: ${ENSEMBL_GTF_URL}/$GTF_GZ" | proc_stdout ${RECORD} gtf_url

    cp "${ENSEMBL_GTF_URL}/$GTF_GZ" .

  fi

  echo 'Done.' | proc_stdout
  echo | proc_stdout
}


function get_gtf_info()
{
  echo "CHECKPOINT" | proc_stdout
  echo "Count total number of annotations per sequence in ${GTF_GZ}..." | proc_stdout
  date '+%Y.%m.%d:%H.%M.%S' | proc_stdout
  zcat $GTF_GZ \
    | grep -v '^#' \
    | awk '{print$1}' \
    | sort \
    | uniq -c \
    | sort -k2,2V \
    | awk '{printf( "%s\t%s\n", $1, $2 );}' | proc_stdout
  echo | proc_stdout

  echo "CHECKPOINT" | proc_stdout
  echo "Count number of selected feature types and gene biotypes in ${GTF_GZ}..." | proc_stdout ${RECORD}

  zcat ${GTF_GZ} \
  | grep -v '^#' \
  | awk 'BEGIN{ FS="\t"; }
      {
        if( $3 ~ /^(gene|transcript|exon|three_prime_utr)$/ ) {
            count_type[$3] += 1
            n = split( $9, arr1, ";" );
            for( i = 1; i <= n; ++i ) {
              split( arr1[i], arr2, " " );
              if( arr2[1] == "gene_biotype" ) {
                count_biotype[arr2[2]] += 1;
                break;
              }
            }
         }
      }
      END {
        printf( "Number of entry feature types\n" );
        n = asorti( count_type, sid );
        for( i = 1; i <= n; ++i ) {
          printf( "%d\t%s\n", count_type[sid[i]], sid[i] );
        }
        printf( "\n" );
        printf( "Number of entry biotypes\n" );
        n = asorti( count_biotype, sid );
        for( i = 1; i <= n; ++i ) {
           biotype_out = sid[i];
           gsub( /"/, "", biotype_out );
           printf( "%d\t%s\n", count_biotype[sid[i]], biotype_out );
        }
     }' | proc_stdout ${RECORD}
  echo | proc_stdout

  echo 'Done.' | proc_stdout
  echo | proc_stdout
}

