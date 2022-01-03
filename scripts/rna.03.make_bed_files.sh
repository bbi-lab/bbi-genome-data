#!/bin/bash

function setup_source_files_bed()
{
  echo "Make soft link from ${GENOME_DIR}/${GTF_GZ} to ./${GTF_GZ}..." | proc_stdout
  date '+%Y.%m.%d:%H.%M.%S' | proc_stdout

  if [ ! -f "${GENOME_DIR}/${GTF_GZ}" ]
  then
    echo "ERROR: cannot find file ${GENOME_DIR}/${GTF_GZ}. Exiting..." | proc_stdout
    exit -1
  fi

  if [ -L "./${GTF_GZ}" ]
  then
    rm "./${GTF_GZ}"
  fi
  ln -s "../${GENOME_SRC}/${GTF_GZ}" .

  echo | proc_stdout
  echo 'Done.' | proc_stdout
  echo | proc_stdout
}


function check_gtf()
{
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
        for( type in count_type ) {
           printf( "%d\t%s\n", count_type[type], type );
        }
        printf( "\n" );
        printf( "Number of entry biotypes\n" );
        for( biotype in count_biotype ) {
           biotype_out = biotype;
           gsub( /"/, "", biotype_out );
           printf( "%d\t%s\n", count_biotype[biotype], biotype_out );
        }
     }' | proc_stdout
}

#
# Jonathan Packer's sci-RNA-seq genome file preparation script.
#


RE_GENE_BIOTYPES='(protein_coding|lincRNA|miRNA|macro_lncRNA|antisense|3prime_overlapping_ncRNA|bidirectional_promoter_lncRNA|misc_RNA|Mt_rRNA|Mt_tRNA|non_coding|processed_transcript|ribozyme|rRNA|scaRNA|scRNA|sense_intronic|sense_overlapping|snoRNA|snRNA|sRNA|vaultRNA)'

#
# Step 1: extracting gene annotations from GTF file
#
function get_gene_annotations()
{
  echo "Step 1: extracting gene annotations from GTF file" | proc_stdout
  date '+%Y.%m.%d:%H.%M.%S' | proc_stdout
  echo "Included gene biotypes: ${RE_GENE_BIOTYPES}" | proc_stdout ${RECORD} gtf_include_biotypes
  zcat $GTF_GZ | grep -v "^#" \
  | awk 'BEGIN {
      FS = "\t";
  } $3 == "gene" {
      gene_id = "";
      gene_name = "";
      gene_biotype = "";
  
      n = split($9, arr, ";");
      for (i = 1; i <= n; i++) {
          split(arr[i], arr2, " ");
          if (arr2[1] == "gene_id") {
              gene_id = arr2[2];
          } else if (arr2[1] == "gene_name") {
              gene_name = arr2[2];
          } else if (arr2[1] == "gene_biotype") {
              gene_biotype = arr2[2];
          }
      }
  
      gsub(/"/, "", gene_id);
      gsub(/"/, "", gene_name);
      gsub(/"/, "", gene_biotype);
  
      if (gene_name == "")
          gene_name = gene_id;
  
      if ( gene_biotype ~ /^'${RE_GENE_BIOTYPES}'$/) {
          printf "%s\t%s\t%s\t%s\t%d\t%s\t%s\n",
              $1, $4, $5, gene_id, 255, $7, gene_name;
      }
    }' \
  | sort -k1,1 -k2,2n -S 4G \
  > tmp.genes.bed
  
  cut -f 4,7 tmp.genes.bed \
  | sort -k1,1 > latest.gene.annotations
}


#
# Step 2: extracting transcript annotations from GTF file
#
function get_transcript_annotations()
{
  echo "Step 2: extracting transcript annotations from GTF file" | proc_stdout
  date '+%Y.%m.%d:%H.%M.%S' | proc_stdout
  zcat $GTF_GZ | grep -v "^#" \
  | gawk 'BEGIN {
      FS = "\t";
  } $3 == "transcript" {
      gene_id = "";
      gene_name = "";
      gene_biotype = "";
      transcript_id = "";
      transcript_name = "";
  
      n = split($9, arr, ";");
      for (i = 1; i <= n; i++) {
          split(arr[i], arr2, " ");
          if (arr2[1] == "gene_id") {
              gene_id = arr2[2];
          } else if (arr2[1] == "gene_name") {
              gene_name = arr2[2];
          } else if (arr2[1] == "gene_biotype") {
              gene_biotype = arr2[2];
          } else if (arr2[1] == "transcript_id") {
              transcript_id = arr2[2];
          }
      }
  
      gsub(/"/, "", gene_id);
      gsub(/"/, "", gene_name);
      gsub(/"/, "", gene_biotype);
      gsub(/"/, "", transcript_id);
  
      if (gene_name == "")
          gene_name = gene_id;
  
      if ( gene_biotype ~ /^'${RE_GENE_BIOTYPES}'$/) {
          printf "%s\t%s\t%s\t%s\t%d\t%s\t%s\t%s\n",
              $1, $4, $5, transcript_id, 255, $7, gene_id, gene_name;
      }
    }' \
  | sort -k1,1 -k2,2n -S 4G \
  > tmp.transcripts.bed
}


#
# Step 3: extending 3' UTRs of gene annotations
#
function extend_3p_utr_gene_annotations()
{
  echo "Step 3: extending 3' UTRs of gene annotations" | proc_stdout
  date '+%Y.%m.%d:%H.%M.%S' | proc_stdout
  for EXTENSION in "500"; do
      awk -v EXTENSION=$EXTENSION 'BEGIN { OFS = "\t"; } {
          if ($6 == "+") {
              $3 = $3 + EXTENSION;
          } else if ($6 == "-") {
              $2 = $2 - EXTENSION;
              if ($2 < 1) $2 = 1;
          }
          print;
      }' tmp.genes.bed \
      | sort -k1,1 -k2,2n -S 4G \
      > tmp1
  
      bedtools intersect -a tmp1 -b tmp.genes.bed -c \
      | awk '$NF == 1 {
          printf "%s\t%d\t%d\t%s\t%s\t%s\t%s\n",
              $1, $2, $3, $4, $5, $6, $7;
      }' \
      > tmp2
  
      bedtools intersect -a tmp1 -b tmp.genes.bed -wo \
      | awk '$4 != $11' \
      | $DATAMASH_PATH -g 1,2,3,4,5,6,7 min 9 max 10 collapse 13 \
      | awk -v EXTENSION=$EXTENSION '{
          n = split($8, overlap_gene_start, ",");
          split($9, overlap_gene_end, ",");
          split($10, overlap_gene_strand, ",");
  
          this_gene_strand = $6;
          orig_start = $2;
          orig_end = $3;
          new_start = orig_start;
          new_end = orig_end;
  
          for (i = 1; i <= n; i++) {
              if (this_gene_strand != overlap_gene_strand[i])
                  continue;
  
              if (this_gene_strand == "+") {
                  if (orig_start >= overlap_gene_start[i] && (orig_end - EXTENSION) <= overlap_gene_end[i]) {
                      # pass
                  } else if ((orig_end - EXTENSION) >= overlap_gene_start[i]) {
                      new_end = orig_end - EXTENSION;
                      break;
                  } else if ((orig_end - EXTENSION) < overlap_gene_start[i] && orig_end >= overlap_gene_start[i]) {
                      tentative_new_end = overlap_gene_start[i] - 1;
                      if (tentative_new_end < new_end)
                          new_end = tentative_new_end;
                  }
              } else if (this_gene_strand == "-") {
                  if ((orig_start + EXTENSION) >= overlap_gene_start[i] && orig_end <= overlap_gene_end[i]) {
                      # pass
                  } else if ((orig_start + EXTENSION) <= overlap_gene_end[i]) {
                      new_start = orig_start + EXTENSION;
                      break;
                  } else if ((orig_start + EXTENSION) > overlap_gene_end[i] && orig_start <= overlap_gene_end[i]) {
                      tentative_new_start = overlap_gene_end[i] + 1;
                      if (tentative_new_start > new_start)
                          new_start = tentative_new_start;
                  }
              }
          }
  
          printf "%s\t%d\t%d\t%s\t%s\t%s\t%s\n",
              $1, new_start, new_end, $4, $5, $6, $7;
      }' \
      > tmp3 

      cat tmp2 tmp3 \
      | sort -k1,1 -k2,2n -S 4G \
      > tmp.genes.3p.UTR.extended.$EXTENSION.bp.bed
  
      rm tmp1 tmp2 tmp3
  done
}


#
# Step 4: extending 3' UTRs of transcript annotations
#
EXTENSION="500"
function extend_3p_utr_transcript_annotations()
{
  echo "Step 4: extending 3' UTRs of transcript annotations" | proc_stdout
  date '+%Y.%m.%d:%H.%M.%S' | proc_stdout
  echo "3' UTRs extended by ${EXTENSION} bps" | proc_stdout ${RECORD} utr_extension
  for EXTENSION in $EXTENSION; do
      awk -v EXTENSION=$EXTENSION 'BEGIN { OFS = "\t"; } {
          if ($6 == "+") {
              $3 = $3 + EXTENSION;
          } else if ($6 == "-") {
              $2 = $2 - EXTENSION;
              if ($2 < 1) $2 = 1;
          }
          print;
      }' tmp.transcripts.bed \
      | sort -k1,1 -k2,2n -S 4G \
      > tmp1
  
      bedtools intersect -a tmp1 -b tmp.genes.bed -c \
      | awk '$NF == 1 {
          printf "%s\t%d\t%d\t%s\t%s\t%s\t%s\t%s\n",
              $1, $2, $3, $4, $5, $6, $7, $8;
      }' \
      > tmp2
  
      bedtools intersect -a tmp1 -b tmp.genes.bed -wo \
      | awk '$7 != $12' \
      | $DATAMASH_PATH -g 1,2,3,4,5,6,7,8 collapse 10 collapse 11 collapse 14 \
      | awk -v EXTENSION=$EXTENSION '{
          n = split($9, overlap_gene_start, ",");
          split($10, overlap_gene_end, ",");
          split($11, overlap_gene_strand, ",");
  
          this_gene_strand = $6;
          orig_start = $2;
          orig_end = $3;
          new_start = orig_start;
          new_end = orig_end;
  
          for (i = 1; i <= n; i++) {
              if (this_gene_strand != overlap_gene_strand[i])
                  continue;
  
              if (this_gene_strand == "+") {
                  if (orig_start >= overlap_gene_start[i] && (orig_end - EXTENSION) <= overlap_gene_end[i]) {
                      # pass
                  } else if ((orig_end - EXTENSION) >= overlap_gene_start[i]) {
                      new_end = orig_end - EXTENSION;
                      break;
                  } else if ((orig_end - EXTENSION) < overlap_gene_start[i] && orig_end >= overlap_gene_start[i]) {
                      tentative_new_end = overlap_gene_start[i] - 1;
                      if (tentative_new_end < new_end)
                          new_end = tentative_new_end;
                  }
              } else if (this_gene_strand == "-") {
                  if ((orig_start + EXTENSION) >= overlap_gene_start[i] && orig_end <= overlap_gene_end[i]) {
                      # pass
                  } else if ((orig_start + EXTENSION) <= overlap_gene_end[i]) {
                      new_start = orig_start + EXTENSION;
                      break;
                  } else if ((orig_start + EXTENSION) > overlap_gene_end[i] && orig_start <= overlap_gene_end[i]) {
                      tentative_new_start = overlap_gene_end[i] + 1;
                      if (tentative_new_start > new_start)
                          new_start = tentative_new_start;
                  }
              }
          }
  
          printf "%s\t%d\t%d\t%s\t%s\t%s\t%s\t%s\n",
              $1, new_start, new_end, $4, $5, $6, $7, $8;
      }' \
      > tmp3
  
      cat tmp2 tmp3 | sort -k1,1 -k2,2n -S 4G \
      > tmp.transcripts.3p.UTR.extended.$EXTENSION.bp.bed
  
      rm tmp1 tmp2 tmp3
  
      bedtools intersect \
          -a tmp.transcripts.3p.UTR.extended.$EXTENSION.bp.bed \
          -b tmp.transcripts.bed -wo \
      | awk '$4 == $12 {
          if ($6 == "+") {
              effective_extension = $3 - $11;
          } else if ($6 == "-") {
              effective_extension = $10 - $2;
          }
          if (effective_extension < 0) {
              effective_extension = 0
          }
          print $4 "\t" effective_extension;
      }' \
      > tmp.transcripts.3p.UTR.extended.$EXTENSION.bp.effective.values.txt
  
      sort -k7,7 tmp.transcripts.3p.UTR.extended.$EXTENSION.bp.bed -S 4G \
      | $DATAMASH_PATH -g 7 first 1 min 2 max 3 first 6 \
      | awk '{ printf "%s\t%s\t%s\t%s\t255\t%s\n", $2, $3, $4, $1, $5; }' \
      | sort -k1,1 -k2,2n -S 4G \
      | bedtools intersect -a - -b tmp.genes.bed -wo \
      | awk '$4 == $10 {
          if ($6 == "+") {
              effective_extension = $3 - $9;
          } else if ($6 == "-") {
              effective_extension = $8 - $2;
          }
  
          print $4 "\t" effective_extension;
      }' \
      > tmp.genes.3p.UTR.extended.$EXTENSION.bp.effective.values.txt
  done
}


#
# Step 5: extracting number of exons per transcript from GTF file
#
function get_number_exons_per_transcript()
{
  echo "Step 5: extracting number of exons per transcript from GTF file" | proc_stdout
  date '+%Y.%m.%d:%H.%M.%S' | proc_stdout
  zcat $GTF_GZ | grep -v "^#" \
  | awk 'BEGIN {
      FS = "\t";
  } $3 == "exon" {
      gene_id = "";
      gene_biotype = "";
      transcript_id = "";
      exon_number = "";
  
      n = split($9, arr, ";");
      for (i = 1; i <= n; i++) {
          split(arr[i], arr2, " ");
          if (arr2[1] == "gene_id") {
              gene_id = arr2[2];
          } else if (arr2[1] == "gene_biotype") {
              gene_biotype = arr2[2];
          } else if (arr2[1] == "transcript_id") {
              transcript_id = arr2[2];
          } else if (arr2[1] == "exon_number") {
              exon_number = arr2[2];
          }
      }
  
      gsub(/"/, "", gene_id);
      gsub(/"/, "", gene_biotype);
      gsub(/"/, "", transcript_id);
      gsub(/"/, "", exon_number);
  
      if ( gene_biotype ~ /^'${RE_GENE_BIOTYPES}'$/) {
          printf "%s\t%s\n",
              transcript_id, exon_number;
      }
  }' \
  | sort -k1,1 -S 4G \
  | $DATAMASH_PATH -g 1 max 2 \
  > tmp.transcript.number.of.exons
}


#
# Step 6: creating new GTF file with extended 3' UTRs
#
function make_extended_utr_gtf()
{
  echo "Step 6: creating new GTF file with extended 3' UTRs" | proc_stdout
  date '+%Y.%m.%d:%H.%M.%S' | proc_stdout
  for EXTENSION in "500"; do
      zcat $GTF_GZ \
      | grep -v "^#" \
      | awk \
          'BEGIN {
             FS = "\t";
             OFS = "\t";
           }
           {
             if (ARGIND == 1 || ARGIND == 2) {
               effective_extension[$1] = $2;
             } else if (ARGIND == 3) {
               transcript_num_exons[$1] = $2;
             } else if ($0 ~ /^#/) {
               print;
             } else {
               gene_id = "";
               gene_biotype = "";
               transcript_id = "";
               exon_number = 0;
   
               n = split($9, arr, ";");
               for (i = 1; i <= n; i++) {
                 split(arr[i], arr2, " ");
                 if (arr2[1] == "gene_id") {
                     gene_id = arr2[2];
                 } else if (arr2[1] == "gene_biotype") {
                     gene_biotype = arr2[2];
                 } else if (arr2[1] == "transcript_id") {
                     transcript_id = arr2[2];
                 } else if (arr2[1] == "exon_number") {
                     exon_number = arr2[2];
                 }
               }
   
               gsub(/"/, "", gene_id);
               gsub(/"/, "", gene_biotype);
               gsub(/"/, "", transcript_id);
               gsub(/"/, "", exon_number);
   
               exon_number = int(exon_number);
   
               # start = $4
               # end = $5
               # strand = $7
   
               if ($3 == "gene") {
                 if (gene_id in effective_extension) {
                   if ($7 == "+")
                       $5 = $5 + effective_extension[gene_id];
                   else if ($7 == "-")
                       $4 = $4 - effective_extension[gene_id];
                 }
               } else if ($3 == "transcript" ||
                      $3 == "three_prime_utr" ||
                      ($3 == "exon" && exon_number == transcript_num_exons[transcript_id])) {
                 if (transcript_id in effective_extension) {
                     if ($7 == "+")
                         $5 = $5 + effective_extension[transcript_id];
                     else if ($7 == "-")
                         $4 = $4 - effective_extension[transcript_id];
                 }
               }
   
               if ( gene_biotype ~ /^'${RE_GENE_BIOTYPES}'$/)
                   print;
             }
           }' \
           tmp.transcripts.3p.UTR.extended.$EXTENSION.bp.effective.values.txt \
           tmp.genes.3p.UTR.extended.$EXTENSION.bp.effective.values.txt \
           tmp.transcript.number.of.exons - \
           > tmp.transcripts.3p.UTR.extended.$EXTENSION.bp.gtf
  done
}


#
# Step 7: making sci-RNA-seq pipeline files from 3' UTR extended GTF file
#
function make_scirna_pipeline_bed_files()
{
  echo "Step 7: making sci-RNA-seq pipeline files from 3' UTR extended GTF file" | proc_stdout
  date '+%Y.%m.%d:%H.%M.%S' | proc_stdout
  cat tmp.transcripts.3p.UTR.extended.$EXTENSION.bp.gtf | grep -v "^#" \
  | awk 'BEGIN {
      FS = "\t";
  } $3 == "gene" {
      gene_id = "";
      gene_biotype = "";
  
      n = split($9, arr, ";");
      for (i = 1; i <= n; i++) {
          split(arr[i], arr2, " ");
          if (arr2[1] == "gene_id") {
              gene_id = arr2[2];
          } else if (arr2[1] == "gene_biotype") {
              gene_biotype = arr2[2];
          }
      }
  
      gsub(/"/, "", gene_id);
      gsub(/"/, "", gene_biotype);
  
      printf "%s\t%s\t%s\t%s\t%d\t%s\n",
          $1, $4, $5, gene_id, 255, $7;
  }' | sort -k1,1 -k2,2n -S 4G \
  > latest.genes.bed
  
  cat tmp.transcripts.3p.UTR.extended.$EXTENSION.bp.gtf | awk 'BEGIN {
      FS = "\t";
  } $3 == "exon" {
      gene_id = "";
      gene_type = "";
      transcript_id = "";
      exon_number = 0;
  
      n = split($9, arr, ";");
      for (i = 1; i <= n; i++) {
          split(arr[i], arr2, " ");
          if (arr2[1] == "gene_id") {
              gene_id = arr2[2];
          } else if (arr2[1] == "gene_biotype") {
              gene_biotype = arr2[2];
          } else if (arr2[1] == "transcript_id") {
              transcript_id = arr2[2];
          } else if (arr2[1] == "exon_number") {
              exon_number = arr2[2];
          }
      }
  
      gsub(/"/, "", gene_id);
      gsub(/"/, "", gene_type);
      gsub(/"/, "", transcript_id);
      gsub(/"/, "", exon_number);
  
      printf "%s\t%s\t%s\t%s\t%d\t%s\t%s\t%s\n",
          $1, $4, $5, transcript_id, 255, $7, gene_id, exon_number;
  }' | sort -k1,1 -k2,2n -k3,3n -S 4G \
  > latest.exons.bed
}


#
# Step 8: extracting rRNA gene annotations from GTF file
#
function get_rrna_gene_annotations()
{
  echo "Step 8: extracting rRNA gene annotations from GTF file" | proc_stdout
  date '+%Y.%m.%d:%H.%M.%S' | proc_stdout
  zcat $GTF_GZ | awk 'BEGIN {
      FS = "\t";
  } $3 == "gene" {
      gene_id = "";
      gene_type = "";
  
      n = split($9, arr, ";");
      for (i = 1; i <= n; i++) {
          split(arr[i], arr2, " ");
          if (arr2[1] == "gene_id") {
              gene_id = arr2[2];
          } else if (arr2[1] == "gene_biotype") {
              gene_biotype = arr2[2];
          }
      }
  
      gsub(/"/, "", gene_id);
      gsub(/"/, "", gene_biotype)
  
      if (gene_biotype == "rRNA") {
          printf "%s\t%s\t%s\n",
              $1, $4, $5;
      }
  }' | sort -k1,1 -k2,2n -k3,3n -S 4G \
  > latest.rRNA.gene.regions.union.bed
}


