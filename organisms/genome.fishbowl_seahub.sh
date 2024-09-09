#!/bin/bash

GROUP="fishbowl_seahub"
ORGANISM="fishbowl_seahub"

ENSEMBL_DNA_URL="/net/bbi/vol1/data/genomes_stage/fishbowl_seahub/source_fishbowl_seahub"
FASTA_GZ="fishbowl_seahub.fa.gz"
WGET_FASTA_GZ=0

ENSEMBL_GTF_URL="/net/bbi/vol1/data/genomes_stage/fishbowl_seahub/source_fishbowl_seahub"
GTF_GZ="fishbowl_seahub.gtf.gz"
WGET_GTF_GZ=0

PAR_BED="par_${ORGANISM}.bed"

SEQUENCES_TO_KEEP_ALIGNER=""
SEQUENCES_TO_KEEP_ATAC_ANALYSIS="MOUSE_1 MOUSE_2 MOUSE_3 MOUSE_4 MOUSE_5 MOUSE_6 MOUSE_7 MOUSE_8 MOUSE_9 MOUSE_10 MOUSE_11 MOUSE_12 MOUSE_13 MOUSE_14 MOUSE_15 MOUSE_16 MOUSE_17 MOUSE_18 MOUSE_19 MOUSE_X MOUSE_Y \
                                 ZEBRAFISH_1 ZEBRAFISH_2 ZEBRAFISH_3 ZEBRAFISH_4 ZEBRAFISH_5 ZEBRAFISH_6 ZEBRAFISH_7 ZEBRAFISH_8 ZEBRAFISH_9 ZEBRAFISH_10 ZEBRAFISH_11 ZEBRAFISH_12 ZEBRAFISH_13 ZEBRAFISH_14 ZEBRAFISH_15 ZEBRAFISH_16 ZEBRAFISH_17 ZEBRAFISH_18 ZEBRAFISH_19 ZEBRAFISH_20 ZEBRAFISH_21 ZEBRAFISH_22 ZEBRAFISH_23 ZEBRAFISH_24 ZEBRAFISH_25"
SEQUENCES_WITH_MT_TO_KEEP_ATAC_ANALYSIS="MOUSE_1 MOUSE_2 MOUSE_3 MOUSE_4 MOUSE_5 MOUSE_6 MOUSE_7 MOUSE_8 MOUSE_9 MOUSE_10 MOUSE_11 MOUSE_12 MOUSE_13 MOUSE_14 MOUSE_15 MOUSE_16 MOUSE_17 MOUSE_18 MOUSE_19 MOUSE_X MOUSE_Y MOUSE_MT \
                                      ZEBRAFISH_1 ZEBRAFISH_2 ZEBRAFISH_3 ZEBRAFISH_4 ZEBRAFISH_5 ZEBRAFISH_6 ZEBRAFISH_7 ZEBRAFISH_8 ZEBRAFISH_9 ZEBRAFISH_10 ZEBRAFISH_11 ZEBRAFISH_12 ZEBRAFISH_13 ZEBRAFISH_14 ZEBRAFISH_15 ZEBRAFISH_16 ZEBRAFISH_17 ZEBRAFISH_18 ZEBRAFISH_19 ZEBRAFISH_20 ZEBRAFISH_21 ZEBRAFISH_22 ZEBRAFISH_23 ZEBRAFISH_24 ZEBRAFISH_25 ZEBRAFISH_MT"
SELECT_GENE_BIOTYPES="protein|lncRNA|TR_V|TR_D|TR_J|TR_C|IG_V|IG_D|IG_J|IG_C|IG_LV"


#
# Pseudo-autosomal region masking.
#
# Notes:
#   o  set PAR_DEFINED=1 if the PAR is defined; otherwise set it to 0.
#
PAR_DEFINED=1
PAR_BED="par_${ORGANISM}.bed"
 
#
# Make bed file of mouse pseudo autosomal regions.
#
# Notes: 
#   o  bed file coordinates
#        o begin coordinate is 0-based
#        o end coordinated is 1-based
#   o  resources:
#        o  https://www.ncbi.nlm.nih.gov/grc/mouse
#        o  https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/001/635/GCF_000001635.26_GRCm38.p6/GCF_000001635.26_GRCm38.p6_assembly_regions.txt
#
# organism        genome_release    Y_par_start    Y_par_end   (1-based coordinates)
# --------        --------------    -----------    ---------
# mouse           GRCm38.p6         90,745,845     91,644,698
#
function make_par_bed()
{
  local BEG1=90745844
  local END1=91644698
 
  rm -f $PAR_BED
 
  echo -e "Y\t$BEG1\t$END1" >> $PAR_BED
}

