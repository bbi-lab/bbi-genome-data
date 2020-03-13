# bbi-genome-data

## Overview
 
*bbi-genome-data* consists of bash scripts and programs for preparing genome-related files for the *bbi-scirna*\* and *bbi-sciatac-*\* processing pipelines.

## Install
 
 ```
  cd <bb-genome-data>/src/seq_util
  make fasta_getseqs
  make libsquid md5 md5_seq
  ```
 
 
## Setup
 
  *  edit the file *scripts/all.02.definitions.sh*: set the variable STAGE_DIR
  *  edit the file *scripts/genome.02.definitions.sh*: set the variables MD5_SEQ, FASTA_GETSEQS, and, if necessary, edit module loads, SAMTOOLS, and BEDTOOLS.
  *  edit the file *scripts/atac.02.definitions.sh*: set the variables BOWTIE2_BUILD, R_GENERATE_TSS_FILE, R_GENERATE_GENE_BODY_FILE, and, if necessary, edit module loads and BEDTOOLS.
 
 
## Define genome-specific variables
 
  *  copy the file *scripts/genome.template.sh* to *scripts/genome.<organism>.sh* and edit it as required for the organism. The variables are described in *scripts/genome.template.sh*.
  
## Run the scripts
  *  run the scripts in the *scripts* directory
  *  run `genome.01.run.sh <organism>` to download and prepare the genome fasta and gtf files for *&lt;organism&gt;*.
  *  run `atac.01.run.sh <organism>` to prepare files for the sci-ATAC-seq processing pipeline.
  *  run `genome.01.run_barnyard.sh` to prepare files for the human-mouse barnyard processing.
  *  run `atac.01.run.sh barnyard` to prepare human-mouse barnyard files for the sci-ATAC-seq processing pipeline.
 
## Check files
 
  *  review the files *log.out* in *<organism>_gsrc* and *<organism>_atac*. Key information is marked with the string CHECKPOINT.
  *  information for distribution with analyses is labeled with the line prefix *TAG_<date:time>*.
 
## Notes:
 
  *  if necessary, make manual edits to the 'finished' fasta file from the genome.*scripts/01.run.sh* script as required, and compress it with `bzip2 -k`.  For example, the Macaca mulatta genome requires the addition of the mitochondrion genome in Ensembl release 99. You may want to add a 'TAG'ged line to the log.out file describing the modification.
  *  the barnyard genome files are built from the human and mouse files in human_gsrc and mouse_gsrc, respectively, so run *scripts/genome.01.run.sh* for human and mouse (and preserve the fasta files in them) and then run *scripts/genome.01.run_barnyard.sh*.
  *  there are functions for cleaning unwanted files from the *<organism>_gsrc* and *<organism>_atac* directories but the functions do nothing as distributed. Edit them in order to delete unwanted files.
*  for information on selecting and processing genome sequences, you might look at <http://lh3.github.io/2017/11/13/which-human-reference-genome-to-use/> and <https://www.biostars.org/p/342482/>.
  *  pseudo-autosomal regions (PARs). Finding PAR coordinates for organisms seems difficult. Perhaps, they are defined for only a few organisms. I found human and mouse PAR coordinates at <https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/001/405/GCF_000001405.39_GRCh38.p13/GCF_000001405.39_GRCh38.p13_assembly_regions.txt> and <https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/001/635/GCF_000001635.26_GRCm38.p6/GCF_000001635.26_GRCm38.p6_assembly_regions.txt>, respectively. The PARs appear to be masked in the Y chromosome.
  
  *  I feel ambivalent about these scripts. I want to automate the processes of downloading, preparing, and checking the files. However, checking the resulting output files requires some care and I am concerned that the automation coupled with the large amount of diagnostic information in the *log.out* files may overwhelm the user and complacency. I am not confident that I struck an effective balance with the scripts.


