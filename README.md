# bbi-genome-data

## Overview

*bbi-genome-data* consists of bash scripts and programs for preparing genome-related files for the *bbi-scirna*\* and *bbi-sciatac-*\* processing pipelines.

## Prerequisites
1. As the genome building pipeline is run interactively, please use a terminal multiplexer such as tmux. tmux sessions are persistent which means that programs in tmux will continue to run even if you get disconnected. You can start a tmux session by using:
```
module load tmux/latest
tmux
```
If you get disconnected, you can return to the head node you were using (grid-head1 or grid-head2) and type:
```
tmux attach -t session-name
```
which will return you to your session. See a handy tmux tutorial [here](https://www.hostinger.com/tutorials/tmux-beginners-guide-and-cheat-sheet/).

2. Always start with a qlogin session before you begin the pipeline. This can be done by
```
qlogin -l mfree=20G
```

## Build programs
Once you have a qlogin session running, clone the repository bbi-genome-data and build
the required programs using:

  ```
  git clone https://github.com/bbi-lab/bbi-genome-data.git
  cd bbi-genome-data/src/sequtil
  make fasta_getseqs
  make libsquid md5 md5_seq
  ```

## Setup

  *  move the programs *fasta_getseqs* and *md5_seq*, which you made in *src/seq_util*, to a convenient directory, if desired
  *  move the files *R/generate_gene_body_file.R* and *R/generate_tss_file.R* to a convenient directory, if desired
  *  move the bash scripts in the *scripts* directory to a convenient directory, if desired
  *  edit the script *genome.02.definitions.sh*, as required
      *  set the variables MD5_SEQ and FASTA_GETSEQS to the paths for the *fasta_getseqs* and *md5_seq* programs
      *  set the variables SAMTOOLS and BEDTOOLS to the paths for the *samtools* and *bedtools* programs
  *  edit the script *atac.02.definitions.sh* as required
      *  set the variable BOWTIE2_BUILD to the path for the *bowtie2-build* program
      *  set the variables R_GENERATE_TSS_FILE and R_GENERATE_GENE_BODY_FILE to the paths for the *generate_tss_file.R* and *generate_gene_body_file.R* scripts
      *  set the variable BEDTOOLS to the path for the *bedtools* program
  *  edit the script *all.02.definitions.sh* to set the variable STAGE_DIR, where the scripts will make their output directories.
  *  install James Kent's *faCount* utility in a convenient directory and edit scripts/atac.02.definitions.sh to set the variable FACOUNT to its
     path. Source code and binaries for *faCount* are available from http://hgdownload.soe.ucsc.edu/admin/exe/ and
     https://github.com/ucscGenomeBrowser/kent/tree/master/src

## Make organism-specific definition files.

  *  organism-specific definition files are stored in the bbi-genome-data/organisms directory
  *  copy the file *organisms/genome.template.sh* to *genome.&lt;organism&gt;.sh* and edit it as required for the organism. The variables are described in *genome.template.sh*.

## Run the scripts
  *  run `genome.01.run.sh <organism>` to download and prepare the genome fasta and gtf files for *&lt;organism&gt;*
  *  run `genome.01.run_barnyard.sh` to prepare files for the human-mouse barnyard processing
  *  run `rna.01.run.sh <organism>` to prepare files for the sci-RNA-seq processing pipeline.
  *  run `rna.01.run.sh barnyard` to prepare human-mouse barnyard files for the sci-RNA-seq processing pipeline.
  *  run `atac.01.run.sh <organism>` to prepare files for the sci-ATAC-seq processing pipeline for *&lt;organism&gt;*
  *  run `atac.01.run.sh barnyard` to prepare human-mouse barnyard files for the sci-ATAC-seq processing pipeline

Note: All of the scripts above are meant to be run from a qlogin session only. Submitting any of these as a job to the cluster (via qsub) will generate an error. For example, run the script `genome.01.run.sh <organism>` as follows:
```
./genome.01.run.sh <organism>
```

## Check log files

  *  review the files *&lt;output_dir&gt;/log.out*. Key information is marked with the string CHECKPOINT.
  *  read the script functions to understand the reports in *&lt;output_dir&gt;/log.out*
  *  the files *&lt;output_dir&gt;/record.out* have particularly important information for record-keeping (which is in log.out too).

## Notes:
  *  script names have the form &lt;pipeline&gt;.&lt;number&gt;.&lt;description&gt;.sh
      *  scripts &lt;pipeline&gt; values
          * *all*  scripts are sourced in scripts for *genome*, *rna*, and *atac*
          * *genome* scripts download and process fasta and gtf files used in both the sci-RNA-seq and sci-ATAC-seq processing pipelines
          * *rna* scripts make files related to the sci-RNA-seq processing pipeline
          * *atac* scripts make files related to the sci-ATAC-seq processing pipeline
      *  script &lt;number&gt; values
          *  *01*  scripts are executable
          *  *02*  scripts have variable and function definitions for either all pipelines or a specific pipeline
          *  *03*+ scripts have functions used in a pipeline. The numbers give the order in which the functions are used in the *01* scripts
          *  *10*  scripts have functions for cleaning up by deleting unnecessary files
  *  consider setting STAGE_DIR to a temporary staging directory where the genome directories and their files are made and checked. Then move them to the directory where they will be used.
  *  the scripts make a directory in which they write their output files
      *  the scripts make their directory in the parent directory specified in the variable STAGE_DIR, which is defined in the script *all.02.definitions.sh*
      *  the script *genome.01.run.sh* makes the directory *&lt;organism&gt;_gsrc*
      *  the script *genome.01.run_barnyard.sh* makes the directory *barnyard_gsrc*
      *  the script *rna.01.run.sh* makes the directories *&lt;organism&gt;* and  *&lt;organism&gt;_star*
      *  the script *atac.01.run.sh* makes the directory *&lt;organism&gt;_atac*
  *  *&lt;output_dir&gt;* refers to *&lt;organism&gt;_gsrc*, *barnyard_gsrc*, and *&lt;organism&gt;_atac*
  *  the scripts write diagnostic information to the terminal and to the file *&lt;output_dir&gt;/log.out*
  *  the script *genome.01.run.sh* writes the fasta files
      *  _*.fa.gz_  is the compressed fasta file downloaded from Ensembl
      *  _*.fa_  is the uncompressed Ensembl fasta file
      *  _*.fa.filtered_  has unmodified sequences selected from the Ensembl fasta file
      *  _*.fa.finished_  is the _*.fa.filtered_  file with pseudo-autosomal regions (PARs) masked and/or manual modifications, if either is applied; otherwise, it is the same as _*.fa.filtered_
      *  _*.fa.finished.bz2_  is the _*.fa.finished_  file with *bzip2* compression
  *  if necessary, make manual edits to the _*.fa.finished_  file and compress it with `bzip2 -k`.  For example, in the Ensembl release 99, the *Macaca mulatta* genome does not include the mitochondrial chromosome so you may want to add it to the _*.fa.finished_  fasta file. You may want to describe manual modifications in a 'TAG' prefixed line added to the log.out file
  *  Ensembl fasta files
      *  we download the _*.dna.toplevel.fa_  fasta file
      *  the toplevel fasta files can have a variety of sequences, which are described at various web sites including
          *  <https://www.ensembl.org/info/genome/genebuild/chromosomes_scaffolds_contigs.html>
          *  <https://www.ensembl.org/Help/Faq?id=216>
          *  the README file in the Ensembl directory with genome fasta files; for example, <ftp://ftp.ensembl.org:/pub/release-99/fasta/homo_sapiens/dna>
  *  there is information on selecting and processing genome sequences at <http://lh3.github.io/2017/11/13/which-human-reference-genome-to-use/> and <https://www.biostars.org/p/342482/>
  *  how to select fasta sequences from the Ensembl fasta file
      *  the functions *sequences_to_keep_ref()* and *sequences_to_keep_named()* make a file called *sequences_to_keep.txt* that has the names of the sequences to copy from the Ensembl fasta to  _*.fa.filtered_
      *  *sequences_to_keep_ref()* chooses sequences with the word REF in the header and writes the sequence names to the file *sequences_to_keep.txt*
      *  *sequences_to_keep_named()* copies the sequence names listed in the variable *SEQUENCES_TO_KEEP_ALIGNER*, which is defined in the *genome.&lt;organism&gt;.sh* file, to the file *sequences_to_keep.txt*
      *  use either *sequences_to_keep_ref()* or *sequences_to_keep_named()* in *genome.01.run.sh* but not both
  *  the barnyard genome files are built from the human and mouse files in the *human_gsrc* and *mouse_gsrc* directories so run *genome.01.run.sh* for human and mouse (and preserve the fasta files in them) and then run *genome.01.run_barnyard.sh*
  *  there are functions for cleaning unwanted files from the *&lt;output_dir&gt;* directories but they do nothing as distributed. Edit them in order to delete unwanted files
  *  pseudo-autosomal regions: finding PAR coordinates for organisms seems difficult. Perhaps, they are defined for only a few organisms. I found human and mouse PAR coordinates at <https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/001/405/GCF_000001405.39_GRCh38.p13/GCF_000001405.39_GRCh38.p13_assembly_regions.txt> and <https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/001/635/GCF_000001635.26_GRCm38.p6/GCF_000001635.26_GRCm38.p6_assembly_regions.txt>, respectively. The PARs appear to be masked in the Y chromosome
  *  ATAC-specific issues
      *  calculate effective genome size: http://koke.asrc.kanazawa-u.ac.jp/HOWTO/kmer-genomesize.html, https://khmer.readthedocs.io/en/v2.1.1/, https://bioinformatics.uconn.edu/genome-size-estimation-tutorial/#, and  https://deeptools.readthedocs.io/en/develop/content/feature/effectiveGenomeSize.html. The effective genome size is used in the ATAC analysis by MACS2.
      *  the chromosome sequences in the genome fasta file must be in a specific order; that is, numerically, XY, and MT. For example, for human, 1, 2, 3, ..., 22, X, Y, MT, ... The script *scripts/fasta_sort.sh* should make a correctly sorted fasta file.
  *  I feel ambivalent about these scripts. I want to automate downloading, preparing, and checking the files. However, checking the resulting output files requires some care and I am concerned that the automation, coupled with the large amount of diagnostic information in the *log.out* files, may overwhelm the user and result in some complacency. Additionally, I strive to eliminate code duplication in the scripts, which results in unfortunate complexity. I am not confident that I found an effective balance in these scripts.
