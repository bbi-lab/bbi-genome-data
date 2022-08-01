#!/bin/bash

GENOME_SOURCE="gencode"


GROUP="mouse_gencode"
ORGANISM="mouse_gencode"

SOURCE_DNA_URL="ftp://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_mouse/release_M29"
FASTA_GZ="GRCm39.primary_assembly.genome.fa.gz"
WGET_FASTA_GZ=1

ENSEMBL_GTF_URL="ftp://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_mouse/release_M29"
GTF_GZ="gencode.vM29.primary_assembly.annotation.gtf.gz"
WGET_GTF_GZ=1

# Edited Gencode GTF file with Ensembl-style five_prime_utr and three_prime_utr features.
# The genome.05.get_gtf_file.sh script calls gencode_edit_utr.py to edit the GTF_GZ
# file.
GTF_EUTR_GZ=`echo ${GTF_GZ} | sed 's/\.gtf\.gz$/\.eutr\.gtf\.gz/'`



SEQUENCES_TO_KEEP_ALIGNER="chr1 chr2 chr3 chr4 chr5 chr6 chr7 chr8 chr9 chr10 chr11 chr12 chr13 chr14 chr15 chr16 chr17 chr18 chr19 chrX chrY chrM"
SEQUENCES_TO_KEEP_ATAC_ANALYSIS="chr1 chr2 chr3 chr4 chr5 chr6 chr7 chr8 chr9 chr10 chr11 chr12 chr13 chr14 chr15 chr16 chr17 chr18 chr19 chrX chrY"
SEQUENCES_WITH_MT_TO_KEEP_ATAC_ANALYSIS="chr1 chr2 chr3 chr4 chr5 chr6 chr7 chr8 chr9 chr10 chr11 chr12 chr13 chr14 chr15 chr16 chr17 chr18 chr19 chrX chrY chrM"

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
 
  echo -e "chrY\t$BEG1\t$END1" >> $PAR_BED
}

