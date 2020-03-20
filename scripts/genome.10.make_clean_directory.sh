#!/bin/bash

function make_clean_directory()
{
  FILE_OUT="clean_directory.sh"

  rm -f $FILE_OUT
  echo "#!/bin/bash" >> $FILE_OUT
  echo >> $FILE_OUT
  echo "rm ${FASTA_GZ}" >> $FILE_OUT
  echo "rm ${FASTA}" >> $FILE_OUT
  echo "rm ${FASTA_FILTERED}" >> $FILE_OUT
  echo "rm ${FASTA_FINISHED}" >> $FILE_OUT
  echo "rm ${GTF_GZ}" >> $FILE_OUT
  chmod 700 $FILE_OUT
}
