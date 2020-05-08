#!/bin/bash

GROUP="barnyard"
ORGANISM="barnyard"

FASTA_GZ="barnyard.fa.gz"
WGET_FASTA_GZ=0

GTF_GZ="barnyard.gtf.gz"
WGET_GTF_GZ=0

SEQUENCES_TO_KEEP_ANALYSIS="HUMAN_1 HUMAN_2 HUMAN_3 HUMAN_4 HUMAN_5 HUMAN_6 HUMAN_7 HUMAN_8 HUMAN_9 HUMAN_10 HUMAN_11 HUMAN_12 HUMAN_13 HUMAN_14 HUMAN_15 HUMAN_16 HUMAN_17 HUMAN_18 HUMAN_19 HUMAN_20 HUMAN_21 HUMAN_22 HUMAN_X HUMAN_Y MOUSE_1 MOUSE_2 MOUSE_3 MOUSE_4 MOUSE_5 MOUSE_6 MOUSE_7 MOUSE_8 MOUSE_9 MOUSE_10 MOUSE_11 MOUSE_12 MOUSE_13 MOUSE_14 MOUSE_15 MOUSE_16 MOUSE_17 MOUSE_18 MOUSE_19 MOUSE_X MOUSE_Y"
SELECT_GENE_BIOTYPES="protein|lncRNA|TR_V|TR_D|TR_J|TR_C|IG_V|IG_D|IG_J|IG_C|IG_LV"

#
# Pseudo-autosomal region masking.
#
# Notes:
#   o  set PAR_DEFINED=1 if the PAR is defined; otherwise set it to 0.
#
PAR_DEFINED=0

