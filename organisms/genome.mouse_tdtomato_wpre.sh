#!/bin/bash

GROUP="mouse_tdtomato_wpre"
ORGANISM="mouse_tdtomato_wpre"

ENSEMBL_DNA_URL="/net/bbi/vol1/data/genomes_stage/mouse_tdtomato_wpre/mouse_tdtomato_wpre_gsrc/source_mouse_tdtomato_wpre"
FASTA_GZ="Mus_musculus_tdtomato_wpre.GRCm38.dna.toplevel.fa.gz"
WGET_FASTA_GZ=0

ENSEMBL_GTF_URL="/net/bbi/vol1/data/genomes_stage/mouse_tdtomato_wpre/mouse_tdtomato_wpre_gsrc/source_mouse_tdtomato_wpre"
GTF_GZ="Mus_musculus_tdtomato_wpre.GRCm38.99.gtf.gz"
WGET_GTF_GZ=0

PAR_BED="par_${ORGANISM}.bed"

SEQUENCES_TO_KEEP_ALIGNER="1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 X Y MT"
SEQUENCES_TO_KEEP_ATAC_ANALYSIS="1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 X Y"
SEQUENCES_WITH_MT_TO_KEEP_ATAC_ANALYSIS="1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 X Y MT"
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

