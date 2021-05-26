#!/bin/bash


GROUP="macaque"
ORGANISM="macaque"

ENSEMBL_DNA_URL="ftp.ensembl.org:/pub/release-101/fasta/macaca_mulatta/dna"
FASTA_GZ="Macaca_mulatta.Mmul_10.dna.toplevel.fa.gz"
WGET_FASTA_GZ=1

ENSEMBL_GTF_URL="ftp.ensembl.org:/pub/release-101/gtf/macaca_mulatta"
GTF_GZ="Macaca_mulatta.Mmul_10.101.gtf.gz"
WGET_GTF_GZ=1


#PAR_BED=""

SEQUENCES_TO_KEEP_ALIGNER="1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 X Y MT"
SEQUENCES_TO_KEEP_ATAC_ANALYSIS="1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 X Y"
SEQUENCES_WITH_MT_TO_KEEP_ATAC_ANALYSIS="1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 X Y MT"
SELECT_GENE_BIOTYPES="protein|lncRNA|TR_V|TR_D|TR_J|TR_C|IG_V|IG_D|IG_J|IG_C|IG_LV"


#
# Pseudo-autosomal region masking.
#
# Notes:
#   o  set PAR_DEFINED=1 if the PAR is defined; otherwise set it to 0.
#
PAR_DEFINED=0

