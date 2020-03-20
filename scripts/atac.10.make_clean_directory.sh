#!/bin/bash

function make_clean_directory()
{
  FILE_OUT="clean_directory.sh"

  rm -f $FILE_OUT
  echo "#!/bin/bash" >> $FILE_OUT
  echo >> $FILE_OUT
  echo "rm gene_bodies.bed.temp" >> $FILE_OUT
  echo "rm tss.bed.temp" >> $FILE_OUT
  chmod 700 $FILE_OUT
}
