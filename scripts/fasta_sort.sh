#!/bin/bash


FASTA="$1"

if [ "$FASTA" == "" ]
then
  echo "Usage: fasta_sort.sh <unsorted fasta filename>"
  echo "This script expects a <FASTA>.finished file so it can run sequence checks."
  exit -1
fi


set -o pipefail  # trace ERR through pipes
set -o errtrace  # trace ERR through 'time command' and other functions
set -o nounset   # set -u : exit the script if you try to use an uninitialised variable
set -o errexit   # set -e : exit the script if any statement returns a non-true return value


source genome.02.definitions.sh

#
# based on URL: https://www.biostars.org/p/90737/
# Notes:
#   o  this can be excruciatingly slow
#


#
# Get sequence names and start and end lines.
#
echo "Get sequence names and start and end lines in file ${FASTA} into all.chr.txt..."
cat $FASTA \
| awk 'BEGIN{RS=">"; FS="\n"; curl=1;} NR>1{print $1 " " curl " " curl+NF-2; curl=curl+NF-1}' \
| sort > all.chr.txt.unedit

echo "Sort all.chr.txt..."

#
# Remove chr prefix and sort.
#
cat all.chr.txt.unedit \
| sed 's/^chr//' \
| sort -k1,1 > all.chr.txt

#
# Get numbered sequence lines.
#
cat all.chr.txt \
| awk '{if($1~/^[0-9]+$/){print$0}}' \
| sort -k1,1V > num.chr.txt

#
# Get X Y sequence lines.
#
cat all.chr.txt \
| awk '{if($1~/^[XY]$/){print$0}}' \
| sort > xy.chr.txt

#
# Get MT sequence lines.
#
cat all.chr.txt \
| awk '{if($1~/^M$)/){print$0}}' > mt.chr.txt

#
# Make a file of numbered, XY, and MT sequence lines.
#
cat num.chr.txt xy.chr.txt mt.chr.txt \
| sort -k1,1 > chromosomes.chr.txt

#
# Make a file of other sequence lines.
#
join -1 1 -2 1 -v 2 chromosomes.chr.txt all.chr.txt \
| sort -k1,1V > other.chr.txt

#
# Make a file of final, ordered sequence lines.
#
cat num.chr.txt xy.chr.txt mt.chr.txt other.chr.txt > chromosome_names_sorted.txt

#
# Extract sequences in order into the fasta file of ordered sequences.
#
echo "Extract sequences sorted order into ${FASTA}.sorted..."
cat chromosome_names_sorted.txt \
| awk '{printf("%s %s %s\n",$1,$(NF-1),$(NF));}' \
| while IFS=' ' read -ra TAB; do beg=${TAB[1]}; end=${TAB[2]}; sed -n $beg','$end'p' $FASTA; done > ${FASTA}.sorted

#
# Check sequence md5 checksums.
#
$MD5_SEQ ${FASTA}.sorted > ${FASTA}.sorted.md5_seq
sort -k1,1V ${FASTA}.sorted.md5_seq > ${FASTA}.sorted.md5_seq.sort
echo "Report different md5 checksums from the finished and sorted finished fasta files (there may be none)..."
join -1 1 -2 1 ${FASTA}.md5_seq.sort ${FASTA}.sorted.md5_seq.sort \
  | sort -k1,1V \
  | awk '{printf( "%s\t%s\t%s\t%s\t%s\n", $1, $3, $5, $2, $4);}' \
  | awk 'BEGIN{eflag=0;}{if($2!=$3){printf("  ** chromosome %s differs (lengths %s %s)\n",$1,$4,$5);eflag=1;}}END{if(eflag==0){printf("No differences.\n");}}'


