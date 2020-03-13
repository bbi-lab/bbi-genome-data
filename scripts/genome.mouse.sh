#!/bin/bash

ORGANISM="mouse"

ENSEMBL_DNA_URL="ftp.ensembl.org:/pub/release-99/fasta/mus_musculus/dna"
FASTA_GZ="Mus_musculus.GRCm38.dna.toplevel.fa.gz"

ENSEMBL_GTF_URL="ftp.ensembl.org:/pub/release-99/gtf/mus_musculus"
GTF_GZ="Mus_musculus.GRCm38.99.gtf.gz"

PAR_BED="par_${ORGANISM}.bed"

SEQUENCES_TO_KEEP_ALIGNER="1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 X Y MT"
SEQUENCES_TO_KEEP_ANALYSIS="1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 X Y"
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

