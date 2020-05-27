#!/bin/bash

GROUP="human"
ORGANISM="human"

ENSEMBL_DNA_URL="ftp.ensembl.org:/pub/release-99/fasta/homo_sapiens/dna"
FASTA_GZ="Homo_sapiens.GRCh38.dna.toplevel.fa.gz"
WGET_FASTA_GZ=1

ENSEMBL_GTF_URL="ftp.ensembl.org:/pub/release-99/gtf/homo_sapiens"
GTF_GZ="Homo_sapiens.GRCh38.99.gtf.gz"
WGET_GTF_GZ=1


SEQUENCES_TO_KEEP_ALIGNER="1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 X Y MT"
SEQUENCES_TO_KEEP_ANALYSIS="1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 X Y"
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
# Make bed file of human pseudo autosomal regions.
#
# Notes:
#   o  bed file coordinates
#        o begin coordinate is 0-based
#        o end coordinated is 1-based
#   o  resources:
#        o https://www.ncbi.nlm.nih.gov/grc/human
#        o https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/001/405/GCF_000001405.39_GRCh38.p13/GCF_000001405.39_GRCh38.p13_assembly_regions.txt
#
# organism        genome_release    Y_par_start    Y_par_end   (1-based coordinates)
# --------        --------------    -----------    ---------
# human           GRCh38.p13        10,001         2,781,479
# human           GRCh38.p13        56,887,903     57,217,415
#
function make_par_bed()
{
  local BEG1=10000
  local END1=2781479
  local BEG2=56887902
  local END2=57217415

  rm -f $PAR_BED

  echo -e "Y\t$BEG1\t$END1" >> $PAR_BED
  echo -e "Y\t$BEG2\t$END2" >> $PAR_BED
}
