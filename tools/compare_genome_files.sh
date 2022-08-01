#!/bin/bash


function compare_files {
  local a_file="${1}/${3}"
  local b_file="${2}/${3}"
  sfx=`echo "$f_name" | awk 'BEGIN{FS="."}{print$NF}'`
  if [ "$sfx" == "gz" ]; then
    CAT="zcat"
  elif [ "$sfx" == "bz2" ]; then
    CAT="bzcat"
  else
    CAT="cat"
  fi
  fname=`basename ${a_file}`
  echo "Files $fname"
  if [ -f "${a_file}" ]; then
    A_MD5SUM=`${CAT} ${a_file} | md5sum | awk '{print$1}'`
    echo "$A_MD5SUM    $a_file"
  else
    echo "Missing file ${a_file}"
  fi
  if [ -f "${b_file}" ]; then
    B_MD5SUM=`${CAT} ${b_file} | md5sum | awk '{print$1}'`
    echo "$B_MD5SUM    $b_file"
  else
    echo "Missing file ${b_file}"
  fi
  echo ""
}


function compare_file_set {
  local a_root="$1"
  local b_root="$2"
  local f_list="$3"
  for f_name in $f_list; do
    compare_files "$a_root" "$b_root" "$f_name"
  done
}


# Human gsrc file.
r_root="/net/bbi/vol1/data/genomes_stage/human/human_gsrc"
t_root="/net/bbi/vol1/data/bge/genomes/genomes_stage.test.20220714a/human/human_gsrc"
f_species="Homo_sapiens.GRCh38.99.gtf.gz Homo_sapiens.GRCh38.dna.toplevel.fa.filtered Homo_sapiens.GRCh38.dna.toplevel.fa.finished Homo_sapiens.GRCh38.dna.toplevel.fa.headers"
f_list="${f_species} CHECKSUMS.dna CHECKSUMS.gtf chromosome_sizes.txt chromosome_sizes_atac.txt chromosome_sizes_fasta_finished.txt chromosome_with_mt_sizes_atac.txt sequences_to_keep.txt"

# compare_file_set $r_root $t_root "$f_list"


# Human rna-seq file.
r_root="/net/bbi/vol1/data/genomes_stage/human/human_rna"
t_root="/net/bbi/vol1/data/bge/genomes/genomes_stage.test.20220714a/human/human_rna"
f_species="Homo_sapiens.GRCh38.99.gtf.gz"
f_list="${f_species} latest.exons.bed latest.gene.annotations latest.genes.bed latest.rRNA.gene.regions.union.bed"

# compare_file_set $r_root $t_root "$f_list"


# Human atac-seq file.
r_root="/net/bbi/vol1/data/genomes_stage/human/human_atac"
t_root="/net/bbi/vol1/data/bge/genomes/genomes_stage.test.20220714a/human/human_atac"
f_species="Homo_sapiens.GRCh38.99.gtf.gz Homo_sapiens.GRCh38.dna.toplevel.fa.finished"
f_list="${f_species} chromosome_sizes_atac.txt chromosome_sizes_fasta_finished.txt chromosome_with_mt_sizes_atac.txt gene_bodies.bed.gz gene_bodies_gene_map.txt gene_bodies.plus_2kb_upstream.bed.gz tss.bed.gz tss_gene_map.txt whitelist_regions.bed whitelist_with_mt_regions.bed"

# compare_file_set $r_root $t_root "$f_list"


# Human_gencode gsrc file.
r_root="/net/bbi/vol1/data/genomes_stage/human_gencode/human_gencode_gsrc"
t_root="/net/bbi/vol1/data/bge/genomes/genomes_stage.test.20220714a/human_gencode/human_gencode_gsrc"
f_species="gencode.v40.primary_assembly.annotation.eutr.gtf.gz gencode.v40.primary_assembly.annotation.gtf.gz GRCh38.primary_assembly.genome.fa.filtered GRCh38.primary_assembly.genome.fa.finished GRCh38.primary_assembly.genome.fa.headers par_human_gencode.bed"
f_list="${f_species} chromosome_sizes_atac.txt chromosome_sizes_fasta_finished.txt chromosome_with_mt_sizes_atac.txt MD5SUMS.dna MD5SUMS.gtf sequences_to_keep.txt"

# compare_file_set $r_root $t_root "$f_list"


# Human_gencode rna-seq file.
r_root="/net/bbi/vol1/data/genomes_stage/human_gencode/human_gencode_rna"
t_root="/net/bbi/vol1/data/bge/genomes/genomes_stage.test.20220714a/human_gencode/human_gencode_rna"
f_species="gencode.v40.primary_assembly.annotation.eutr.gtf.gz"
f_list="${f_species} latest.exons.bed latest.gene.annotations latest.genes.bed latest.rRNA.gene.regions.union.bed"

# compare_file_set $r_root $t_root "$f_list"


# Human_gencode atac-seq file.
r_root="/net/bbi/vol1/data/genomes_stage/human_gencode/human_gencode_atac"
t_root="/net/bbi/vol1/data/bge/genomes/genomes_stage.test.20220714a/human_gencode/human_gencode_atac"
f_species="GRCh38.primary_assembly.genome.fa.finished GRCh38.primary_assembly.genome.fa.finished.flat"
f_list="${f_species} chromosome_sizes_atac.txt chromosome_sizes_fasta_finished.txt chromosome_with_mt_sizes_atac.txt effective_genome_size.txt gencode.v40.primary_assembly.annotation.eutr.gtf.gz gene_bodies.bed.gz gene_bodies.found_biotypes.lst gene_bodies_gene_map.txt gene_bodies.plus_2kb_upstream.bed.gz gene_bodies.select_biotypes.lst gene_bodies.selected_biotype.counts.lst tss.bed.gz tss.found_biotypes.lst tss_gene_map.txt tss.select_biotypes.lst tss.selected_biotype.counts.lst whitelist_regions.bed whitelist_with_mt_regions.bed"

# compare_file_set $r_root $t_root "$f_list"




# Mouse gsrc file.
r_root="/net/bbi/vol1/data/genomes_stage/mouse/mouse_gsrc"
t_root="/net/bbi/vol1/data/bge/genomes/genomes_stage.test.20220714a/mouse/mouse_gsrc"
f_species="Mus_musculus.GRCm38.99.gtf.gz Mus_musculus.GRCm38.dna.toplevel.fa Mus_musculus.GRCm38.dna.toplevel.fa.filtered Mus_musculus.GRCm38.dna.toplevel.fa.finished Mus_musculus.GRCm38.dna.toplevel.fa.gz Mus_musculus.GRCm38.dna.toplevel.fa.headers par_mouse.bed"
f_list="${f_species} CHECKSUMS.dna CHECKSUMS.gtf chromosome_sizes.txt chromosome_sizes_atac.txt chromosome_sizes_fasta_finished.txt chromosome_with_mt_sizes_atac.txt sequences_to_keep.txt"

compare_file_set $r_root $t_root "$f_list"


# Mouse rna-seq file.
r_root="/net/bbi/vol1/data/genomes_stage/mouse/mouse_rna"
t_root="/net/bbi/vol1/data/bge/genomes/genomes_stage.test.20220714a/mouse/mouse_rna"
f_species="Mus_musculus.GRCm38.99.gtf.gz"
f_list="${f_species} latest.exons.bed latest.gene.annotations latest.genes.bed latest.rRNA.gene.regions.union.bed"

compare_file_set $r_root $t_root "$f_list"


# Mouse atac-seq file.
r_root="/net/bbi/vol1/data/genomes_stage/mouse/mouse_atac"
t_root="/net/bbi/vol1/data/bge/genomes/genomes_stage.test.20220714a/mouse/mouse_atac"
f_species="Mus_musculus.GRCm38.99.gtf.gz Mus_musculus.GRCm38.dna.toplevel.fa.finished Mus_musculus.GRCm38.dna.toplevel.fa.finished.flat"
f_list="${f_species} chromosome_sizes_atac.txt chromosome_sizes_fasta_finished.txt chromosome_with_mt_sizes_atac.txt gene_bodies.bed.gz gene_bodies_gene_map.txt gene_bodies.plus_2kb_upstream.bed.gz tss.bed.gz tss_gene_map.txt whitelist_regions.bed whitelist_with_mt_regions.bed"

compare_file_set $r_root $t_root "$f_list"


# Mouse_gencode gsrc file.
r_root="/net/bbi/vol1/data/genomes_stage/mouse_gencode/mouse_gencode_gsrc"
t_root="/net/bbi/vol1/data/bge/genomes/genomes_stage.test.20220714a/mouse_gencode/mouse_gencode_gsrc"
f_species="gencode.vM29.primary_assembly.annotation.eutr.gtf.gz gencode.vM29.primary_assembly.annotation.gtf.gz GRCm39.primary_assembly.genome.fa GRCm39.primary_assembly.genome.fa.filtered GRCm39.primary_assembly.genome.fa.finished GRCm39.primary_assembly.genome.fa.gz GRCm39.primary_assembly.genome.fa.headers par_mouse_gencode.bed"
f_list="${f_species} chromosome_sizes_atac.txt chromosome_sizes_fasta_finished.txt chromosome_with_mt_sizes_atac.txt MD5SUMS.dna MD5SUMS.gtf sequences_to_keep.txt"

compare_file_set $r_root $t_root "$f_list"


# Mouse_gencode rna-seq file.
r_root="/net/bbi/vol1/data/genomes_stage/mouse_gencode/mouse_gencode_rna"
t_root="/net/bbi/vol1/data/bge/genomes/genomes_stage.test.20220714a/mouse_gencode/mouse_gencode_rna"
f_species="gencode.vM29.primary_assembly.annotation.eutr.gtf.gz"
f_list="${f_species} latest.exons.bed latest.gene.annotations latest.genes.bed latest.rRNA.gene.regions.union.bed"

compare_file_set $r_root $t_root "$f_list"


# Mouse_gencode atac-seq file.
r_root="/net/bbi/vol1/data/genomes_stage/mouse_gencode/mouse_gencode_atac"
t_root="/net/bbi/vol1/data/bge/genomes/genomes_stage.test.20220714a/mouse_gencode/mouse_gencode_atac"
f_species="gencode.vM29.primary_assembly.annotation.eutr.gtf.gz GRCm39.primary_assembly.genome.fa.finished"
f_list="${f_species} chromosome_sizes_atac.txt chromosome_sizes_fasta_finished.txt chromosome_with_mt_sizes_atac.txt effective_genome_size.txt gene_bodies.bed.gz gene_bodies.found_biotypes.lst gene_bodies_gene_map.txt gene_bodies.plus_2kb_upstream.bed.gz gene_bodies.select_biotypes.lst gene_bodies.selected_biotype.counts.lst tss.bed.gz tss.found_biotypes.lst tss_gene_map.txt tss.select_biotypes.lst tss.selected_biotype.counts.lst whitelist_regions.bed whitelist_with_mt_regions.bed"

compare_file_set $r_root $t_root "$f_list"


