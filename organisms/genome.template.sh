#!/bin/bash

#
# GENOME_SOURCE is either 'ensembl' for genome files from Ensembl
# or 'gencode' for genomes files from Gencode. The Gencode GTF
# files have a UTR feature instead of the Ensembl five_prime_utr
# and three_prime_utr features. Our scripts extend the 3' UTR
# sequences so the scripts convert the Gencode UTR features to
# the Ensembl five_prime_utr and three_prime_utr features using
# the program scripts/gencode_edit_utr.py. After the conversion,
# please check manually the conversion using
# scripts/compare_genecode_to_ensembl_utrs.py
# There are comments in scripts/compare_genecode_to_ensembl_utrs.py.
#
GENOME_SOURCE="ensembl"

#
# GROUP and ORGANISM define primarily the directories in which the
# output files are written. The file paths have the form
#   $STAGE_DIR/$GROUP/$ORGANISM_(gsrc|rna|star|atac)
# In addition, the ORGANISM variable is used to name the index
# files required by the aligners and certain *.bed files.
# We adopted the convention of giving usually the GROUP the same
# name as the ORGANISM; for example,
#   genomes_stage/human/human_rna
# In the case of custom genomes, GROUP is set to 'custom_genomes',
# and the ORGANISM is set to a distinctive name that includes the
# organism, for example, 'noah.macaque'.
#
GROUP="human"
ORGANISM="human"

#
# Set the URL for the Ensembl/Gencode directory that contains the
# compressed genome fasta file and the related CHECKSUM/MD5SUMS and
# README/_README.TXT files. And set the name of the required
# compressed genome fasta file.  The file can be downloaded by http
# or ftp using wget, or copied from a local directory.
# Set WGET_FASTA_GZ=1 to download by http or ftp or
# set WGET_FASTA_GZ=0 to copy from a local directory.
# In both cases, the file must be gzip compressed.
# Note: SOURCE_DNA_URL replaces ENSEMBLE_DNA_URL.
#
SOURCE_DNA_URL="ftp.ensembl.org:/pub/release-99/fasta/homo_sapiens/dna"
FASTA_GZ="Homo_sapiens.GRCh38.dna.toplevel.fa.gz"
WGET_FASTA_GZ=1

#
# Set the URL for the Ensembl/Gencode directory that contains the
# compressed genome GTF file and the related CHECKSUM/MD5SUMS and
# README/_README.TXT files. And set the name of the required
# compressed GTF file. The file can be downloaded by http or ftp
# using, or copied from a local directory.
# In both cases, the file must be gzip compressed.
# Set WGET_GTF_GZ=1 to download by http or ftp or
# set WGET_GTF_GZ=0 to copy from a local directory.
# Note: SOURCE_GTF_URL replaces ENSEMBLE_GTF_URL.
#
SOURCE_GTF_URL="ftp.ensembl.org:/pub/release-99/gtf/homo_sapiens"
GTF_GZ="Homo_sapiens.GRCh38.99.gtf.gz"
WGET_GTF_GZ=1

# Edited Gencode GTF file with Ensembl-style five_prime_utr and three_prime_utr features. 
# The genome.05.get_gtf_file.sh script calls gencode_edit_utr.py to edit the GTF_GZ 
# file. This is used in for Gencode genome files.
# GTF_EUTR_GZ=`echo ${GTF_GZ} | sed 's/\.gtf\.gz$/\.eutr\.gtf\.gz/'` 

#
# Note: at the time of this writing, the 'SEQUENCES_TO_KEEP_ALIGNER'
#       variable is unused because the function
#       'sequences_to_keep_ref()' is called in the script
#       'genome.01.run.sh'. Find additional details below.
# The genome sequences selected for alignments can be chosen by
# checking the fasta headers for the 'REF' designation (do this
# using the 'sequences_to_keep_ref()' function in genome.01.run.sh)
# or by using an explicit list of required sequence names (do this
# using the 'sequences_to_keep_named()' function in
# genome.01.run.sh). In the latter case, list the required
# sequence names in the variable SEQUENCES_TO_KEEP_ALIGNER below.
#
# SEQUENCES_TO_KEEP_ALIGNER="1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 X Y MT"
SEQUENCES_TO_KEEP_ALIGNER=""

#
# The genome sequences selected for the ATAC-seq analysis, which
# typically excludes the mitochondrial chromosome and unplaced and
# unlocalized scaffolds. The required sequence names must be
# listed explicitly in the variable SEQUENCES_TO_KEEP_ATAC_ANALYSIS
# below.
# SEQUENCES_TO_KEEP_ATAC_ANALYSIS="1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 X Y"
SEQUENCES_TO_KEEP_ATAC_ANALYSIS=""

#
# The genome sequences including mitochrondial selected for the ATAC-seq
# analysis, which typically excludes the unplaced and unlocalized scaffolds.
# The required sequence names must be listed explicitly in the variable.
# SEQUENCES_WITH_MT_TO_KEEP_ATAC_ANALYSIS below.
# SEQUENCES_WITH_MT_TO_KEEP_ATAC_ANALYSIS="1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 X Y MT"
SEQUENCES_WITH_MT_TO_KEEP_ATAC_ANALYSIS=""

# The transcript/gene biotypes to select from the GTF file for
# the RNA-seq analysis. The string is a regular expression
# alternation, with the alternation parentheses. The string
# consists of names, or partial names, separated by vertical bars
# without spaces. Check the script code for details.
# Note: a default is used if this variable is not set.
#
RE_GENE_BIOTYPES='(protein_coding|lincRNA|lncRNA|miRNA|macro_lncRNA|antisense|3prime_overlapping_ncRNA|bidirectional_promoter_lncRNA|misc_RNA|Mt_rRNA|Mt_tRNA|non_coding|processed_transcript|ribozyme|rRNA|scaRNA|scRNA|sense_intronic|sense_overlapping|snoRNA|snRNA|sRNA|vaultRNA)'  


#
# The transcript gene_biotypes to select from the GTF file for
# the ATAC-seq analysis. The string is a regular expression
# alternation, without the alternation parentheses, so the string
# consists of names, or partial names, separated by vertical bars
# without spaces. Check the script code for details.
#
SELECT_GENE_BIOTYPES="protein|lncRNA|TR_V|TR_D|TR_J|TR_C|IG_V|IG_D|IG_J|IG_C|IG_LV"


#
# Pseudo-autosomal region masking.
#
# Notes:
#   o  set PAR_DEFINED=1 if the PARs are defined; otherwise set it to 0.
#
PAR_DEFINED=1
PAR_BED="par_${ORGANISM}.bed"

#
# Make bed file of human pseudo autosomal regions.
#
# Notes:
#   o  it appears that the PARs on the Y chromosome are masked, typically
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

