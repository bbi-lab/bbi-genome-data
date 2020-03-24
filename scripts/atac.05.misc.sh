#!/bin/bash

#
# Using the finished fasta file, subtract N count from total base count.
#
function estimate_effective_genome_size()
{
  echo "Estimate effective genome size..." | proc_stdout
  date '+%Y.%m.%d:%H.%M.%S' | proc_stdout

  ${FACOUNT} ${FASTA_FINISHED} | grep '^total' | awk '{printf("%3.2e\n",$2-$7);}' > ${EFFECTIVE_GENOME_SIZE}

  echo | proc_stdout
  echo 'Done.' | proc_stdout
  echo | proc_stdout
}

