#!/bin/bash

GENOME_SOURCE="gencode"

GROUP="barnyard_10X_homebrew"
ORGANISM="barnyard_10X_homebrew"

ENSEMBL_DNA_URL="/net/bbi/vol1/data/genomes_stage/barnyard_10X/barynard_10X_homebrew/barnyard_10X_homebrew_source"
FASTA_GZ="barnyard_10X.fa.gz"
WGET_FASTA_GZ=0

ENSEMBL_GTF_URL="/net/bbi/vol1/data/genomes_stage/barnyard_10X/barynard_10X_homebrew/barnyard_10X_homebrew_source"
GTF_GZ="barnyard_10X.gtf.gz"
WGET_GTF_GZ=0


# Edited Gencode GTF file with Ensembl-style five_prime_utr and three_prime_utr features.
# The genome.05.get_gtf_file.sh script calls gencode_edit_utr.py to edit the GTF_GZ
# file.
GTF_EUTR_GZ=`echo ${GTF_GZ} | sed 's/\.gtf\.gz$/\.eutr\.gtf\.gz/'`

PAR_BED="par_${ORGANISM}.bed"

SEQUENCES_TO_KEEP_ALIGNER="GRCh38_chr1 GRCh38_chr10 GRCh38_chr11 GRCh38_chr12 GRCh38_chr13 \
                           GRCh38_chr14 GRCh38_chr15 GRCh38_chr16 GRCh38_chr17 GRCh38_chr18 \
                           GRCh38_chr19 GRCh38_chr2 GRCh38_chr20 GRCh38_chr21 GRCh38_chr22 \
                           GRCh38_chr3 GRCh38_chr4 GRCh38_chr5 GRCh38_chr6 GRCh38_chr7 GRCh38_chr8 \
                           GRCh38_chr9 GRCh38_chrM GRCh38_chrX GRCh38_chrY mm10___chr1 mm10___chr10 \
                           mm10___chr11 mm10___chr12 mm10___chr13 mm10___chr14 mm10___chr15 \
                           mm10___chr16 mm10___chr17 mm10___chr18 mm10___chr19 mm10___chr2 \
                           mm10___chr3 mm10___chr4 mm10___chr5 mm10___chr6 mm10___chr7 \
                           mm10___chr8 mm10___chr9 mm10___chrM mm10___chrX mm10___chrY"

SEQUENCES_TO_KEEP_ATAC_ANALYSIS="GRCh38_chr1 GRCh38_chr10 GRCh38_chr11 GRCh38_chr12 GRCh38_chr13 \
                           GRCh38_chr14 GRCh38_chr15 GRCh38_chr16 GRCh38_chr17 GRCh38_chr18 \
                           GRCh38_chr19 GRCh38_chr2 GRCh38_chr20 GRCh38_chr21 GRCh38_chr22 \
                           GRCh38_chr3 GRCh38_chr4 GRCh38_chr5 GRCh38_chr6 GRCh38_chr7 GRCh38_chr8 \
                           GRCh38_chr9 GRCh38_chrM GRCh38_chrX GRCh38_chrY mm10___chr1 mm10___chr10 \
                           mm10___chr11 mm10___chr12 mm10___chr13 mm10___chr14 mm10___chr15 \
                           mm10___chr16 mm10___chr17 mm10___chr18 mm10___chr19 mm10___chr2 \
                           mm10___chr3 mm10___chr4 mm10___chr5 mm10___chr6 mm10___chr7 \
                           mm10___chr8 mm10___chr9 mm10___chrM mm10___chrX mm10___chrY"

SEQUENCES_WITH_MT_TO_KEEP_ATAC_ANALYSIS="GRCh38_chr1 GRCh38_chr10 GRCh38_chr11 GRCh38_chr12 GRCh38_chr13 \
                           GRCh38_chr14 GRCh38_chr15 GRCh38_chr16 GRCh38_chr17 GRCh38_chr18 \
                           GRCh38_chr19 GRCh38_chr2 GRCh38_chr20 GRCh38_chr21 GRCh38_chr22 \
                           GRCh38_chr3 GRCh38_chr4 GRCh38_chr5 GRCh38_chr6 GRCh38_chr7 GRCh38_chr8 \
                           GRCh38_chr9 GRCh38_chrM GRCh38_chrX GRCh38_chrY mm10___chr1 mm10___chr10 \
                           mm10___chr11 mm10___chr12 mm10___chr13 mm10___chr14 mm10___chr15 \
                           mm10___chr16 mm10___chr17 mm10___chr18 mm10___chr19 mm10___chr2 \
                           mm10___chr3 mm10___chr4 mm10___chr5 mm10___chr6 mm10___chr7 \
                           mm10___chr8 mm10___chr9 mm10___chrM mm10___chrX mm10___chrY"
                           
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

