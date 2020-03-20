#!/bin/bash

#
# Variable definitions used for all data files (genome and atac).
#


#
# Staging directory.
#
# STAGE_DIR="/net/bbi/vol1/data/genomes/stage_dir"
STAGE_DIR="/net/bbi/vol1/data/bge/genomes/nobackup/stage_dir"


#
# Output directories.
#   variable       description
#   --------       -----------
#   GENOME_DIR     genome source directory
#   RNA_DIR        sci-RNA-seq files
#   STAR_DIR       STAR aligner index files
#   ATAC_DIR       sci-ATAC-seq files
#
GENOME_DIR="${STAGE_DIR}/${ORGANISM}_gsrc"
RNA_DIR="${STAGE_DIR}/${ORGANISM}"
STAR_DIR="${STAGE_DIR}/${ORGANISM}_star"
ATAC_DIR="${STAGE_DIR}/${ORGANISM}_atac"

#
# Common file names.
#
FASTA=`echo $FASTA_GZ | sed 's/\.gz$//'`
FASTA_FILTERED="${FASTA}.filtered"
FASTA_FINISHED="${FASTA}.finished"
CHROMOSOME_SIZES_FILE="chromosome_sizes.txt"
GTF=`echo $GTF_GZ | sed 's/\.gz$//'`
LOG="log.out"
RECORD="record.out"

#
# Barnyard-specific file names.
#
BARNYARD_FASTA_FINISHED="barnyard.fa.finished"
BARNYARD_GTF_GZ="barnyard.gtf.gz"

#
# Log file tag for pulling key information from the log files.
#
TAG_DATE=`date '+%Y%m%d:%H%M%S'`
TAG="TAG_${TAG_DATE}"


#
# Usage: <command> | proc_stdout
#           or
#        <command> | proc_stdout <filename>
#
# The first example writes to stdout and ${LOG}
# the second example also writes to file <filename>
# with a 'tag', given by ${TAG},  prepended to each
# line.
#
function proc_stdout()
{
  set +u
  readarray text_array
  for aline in "${text_array[@]}"
  do
    echo -n "$aline" | tee -a ${LOG}
  done

  if [ ! -z "$1" ]
  then
    for aline in "${text_array[@]}"
    do
      echo -n "$TAG $aline" >> ${1}
    done
  fi
  set -u
}


#
# Error handler.
# from URL: https://unix.stackexchange.com/questions/39623/trap-err-and-echoing-the-error-line
# Notes:
#   o  requires bash shell.
#   o  use at script start
#       set -o pipefail  # trace ERR through pipes
#       set -o errtrace  # trace ERR through 'time command' and other functions
#       set -o nounset   ## set -u : exit the script if you try to use an uninitialised variable
#       set -o errexit   ## set -e : exit the script if any statement returns a non-true return value
#       trap 'error_trap "LINENO" "BASH_LINENO" "${BASH_COMMAND}" "${?}"' ERR
#
function error_trap()
{
    local -n _lineno="${1:-LINENO}"
    local -n _bash_lineno="${2:-BASH_LINENO}"
    local _last_command="${3:-${BASH_COMMAND}}"
    local _code="${4:-0}"

    ## Workaround for read EOF combo tripping traps
    if ! ((_code)); then
        return "${_code}"
    fi

    local _last_command_height="$(wc -l <<<"${_last_command}")"

    local -a _output_array=()
    _output_array+=(
        '---'
        "lines_history: [${_lineno} ${_bash_lineno[*]}]"
        "function_trace: [${FUNCNAME[*]}]"
        "exit_code: ${_code}"
    )

    if [[ "${#BASH_SOURCE[@]}" -gt '1' ]]; then
        _output_array+=('source_trace:')
        for _item in "${BASH_SOURCE[@]}"; do
            _output_array+=("  - ${_item}")
        done
    else
        _output_array+=("source_trace: [${BASH_SOURCE[*]}]")
    fi

    if [[ "${_last_command_height}" -gt '1' ]]; then
        _output_array+=(
            'last_command: ->'
            "${_last_command}"
        )
    else
        _output_array+=("last_command: ${_last_command}")
    fi

    _output_array+=('---')
    printf '%s\n' "${_output_array[@]}" >&2
    exit ${_code}
}


