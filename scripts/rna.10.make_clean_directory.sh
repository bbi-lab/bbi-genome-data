#!/bin/bash

function make_clean_bed_directory()
{
  FILE_OUT="clean_directory.sh"
  
  rm -f $FILE_OUT
  echo "#!/bin/bash" >> $FILE_OUT
  echo >> $FILE_OUT
#  echo "rm xxxx" >> $FILE_OUT
}


function make_clean_star_directory()
{
  FILE_OUT="clean_directory.sh"
 
  rm -f $FILE_OUT
  echo "#!/bin/bash" >> $FILE_OUT
  echo >> $FILE_OUT
  echo "rm ${GTF}" >> $FILE_OUT
  chmod 700 $FILE_OUT
}

