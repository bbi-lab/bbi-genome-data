#!/bin/bash

GENOME_SOURCE="gencode"


GROUP="barnyard_gencode"
ORGANISM="barnyard_gencode"

FASTA_GZ="barnyard_gencode.fa.gz"
WGET_FASTA_GZ=0

GTF_GZ="barnyard_gencode.gtf.gz"
GTF_EUTR_GZ="barnyard_gencode.gtf.gz"
WGET_GTF_GZ=0

ENSEMBL_DNA_URL="NA"
ENSEMBL_GTF_URL="NA"

SEQUENCES_TO_KEEP_ATAC_ANALYSIS="HUMAN_chr1 HUMAN_chr2 HUMAN_chr3 HUMAN_chr4 HUMAN_chr5 HUMAN_chr6 HUMAN_chr7 HUMAN_chr8 HUMAN_chr9 HUMAN_chr10 HUMAN_chr11 HUMAN_chr12 HUMAN_chr13 HUMAN_chr14 HUMAN_chr15 HUMAN_chr16 HUMAN_chr17 HUMAN_chr18 HUMAN_chr19 HUMAN_chr20 HUMAN_chr21 HUMAN_chr22 HUMAN_chrX HUMAN_chrY MOUSE_chr1 MOUSE_chr2 MOUSE_chr3 MOUSE_chr4 MOUSE_chr5 MOUSE_chr6 MOUSE_chr7 MOUSE_chr8 MOUSE_chr9 MOUSE_chr10 MOUSE_chr11 MOUSE_chr12 MOUSE_chr13 MOUSE_chr14 MOUSE_chr15 MOUSE_chr16 MOUSE_chr17 MOUSE_chr18 MOUSE_chr19 MOUSE_chrX MOUSE_chrY"
SEQUENCES_WITH_MT_TO_KEEP_ATAC_ANALYSIS="HUMAN_chr1 HUMAN_chr2 HUMAN_chr3 HUMAN_chr4 HUMAN_chr5 HUMAN_chr6 HUMAN_chr7 HUMAN_chr8 HUMAN_chr9 HUMAN_chr10 HUMAN_chr11 HUMAN_chr12 HUMAN_chr13 HUMAN_chr14 HUMAN_chr15 HUMAN_chr16 HUMAN_chr17 HUMAN_chr18 HUMAN_chr19 HUMAN_chr20 HUMAN_chr21 HUMAN_chr22 HUMAN_chrX HUMAN_chrY HUMAN_chrM MOUSE_chr1 MOUSE_chr2 MOUSE_chr3 MOUSE_chr4 MOUSE_chr5 MOUSE_chr6 MOUSE_chr7 MOUSE_chr8 MOUSE_chr9 MOUSE_chr10 MOUSE_chr11 MOUSE_chr12 MOUSE_chr13 MOUSE_chr14 MOUSE_chr15 MOUSE_chr16 MOUSE_chr17 MOUSE_chr18 MOUSE_chr19 MOUSE_chrX MOUSE_chrY MOUSE_chrM"


# Gene biotypes to select for the RNA-seq pipeline. 
# Notes: 
#   o  this is a regex alternation that includes the enclosing parentheses. 
#
RE_GENE_BIOTYPES='(protein_coding|lincRNA|lncRNA|miRNA|macro_lncRNA|antisense|3prime_overlapping_ncRNA|bidirectional_promoter_lncRNA|misc_RNA|Mt_rRNA|Mt_tRNA|non_coding|processed_transcript|ribozyme|rRNA|scaRNA|scRNA|sense_intronic|sense_overlapping|snoRNA|snRNA|sRNA|vaultRNA)'  

# Gene biotypes to select for the ATAC-seq pipeline. 
# Notes: 
#   o  this is a regex alternation that excludes the enclosing parentheses. 
#
SELECT_GENE_BIOTYPES="protein|lncRNA|TR_V|TR_D|TR_J|TR_C|IG_V|IG_D|IG_J|IG_C|IG_LV" 

#
# Pseudo-autosomal region masking.
#
# Notes:
#   o  set PAR_DEFINED=1 if the PAR is defined; otherwise set it to 0.
#
PAR_DEFINED=0

