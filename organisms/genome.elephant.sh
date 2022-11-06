#!/bin/bash

#
# Set organism to a distinct common name. The ORGANISM variable is
# used to name the directories that will contain the output files.
#
GROUP="elephant"
ORGANISM="elephant"

#
# Set the URL for the Ensembl directory that contains the compressed
# genome fasta file and the related CHECKSUM and README files. And
# set the name of the required compressed genome fasta file.
#
ENSEMBL_DNA_URL="ftp://ftp.ensembl.org/pub/release-99/fasta/loxodonta_africana/dna"
FASTA_GZ="Loxodonta_africana.loxAfr3.dna.toplevel.fa.gz"
WGET_FASTA_GZ=1

#
# Set the URL for the Ensembl directory that contains the compressed
# genome GTF file and the related CHECKSUM and README files. And
# set the name of the required compressed GTF file.
#
ENSEMBL_GTF_URL="ftp://ftp.ensembl.org/pub/release-99/gtf/loxodonta_africana"
GTF_GZ="Loxodonta_africana.loxAfr3.99.gtf.gz"
WGET_GTF_GZ=1

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
SEQUENCES_TO_KEEP_ALIGNER=""

#
# The genome sequences selected for the analysis, which typically
# excludes the mitochondrial chromosome and unplaced and
# unlocalized scaffolds. The required sequence names must be
# listed explicitly in the variable SEQUENCES_TO_KEEP_ATAC_ANALYSIS
# below.
SEQUENCES_TO_KEEP_ATAC_ANALYSIS=""

#
# The genome sequences including mitochrondial selected for the analysis,
# which typically excludes the unplaced and unlocalized scaffolds. The
# required sequence names must be listed explicitly in the variable
# SEQUENCES_WITH_MT_TO_KEEP_ATAC_ANALYSIS below.
SEQUENCES_WITH_MT_TO_KEEP_ATAC_ANALYSIS=""

#
# The transcript gene_biotypes to select from the GTF file. The
# string is a regular expression so the string consists of
# names, or partial names, separated by vertical bars without
# spaces.
#
SELECT_GENE_BIOTYPES="protein|lncRNA|TR_V|TR_D|TR_J|TR_C|IG_V|IG_D|IG_J|IG_C|IG_LV"


#
# Pseudo-autosomal region masking.
#
# Notes:
#   o  set PAR_DEFINED=1 if the PARs are defined; otherwise set it to 0.
#
PAR_DEFINED=0
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

