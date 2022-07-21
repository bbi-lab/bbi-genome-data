#!/usr/bin/env python3

#
# Program: compare_genecode_to_ensembl_utrs.py
#
# Description:
# This program compares 5' and 3' UTRs from Ensembl and 'fixed'
# Gencode GTF files. The Gencode GTF is fixed by running the
# gencode_edit_utr.py program on the original Gencode GTF. The
# gencode_edit_utr.py program changes the Gencode 'UTR'
# features to either 'five_prime_utr' or 'three_prime_utr', as
# found in the Ensembl GTF files.
#
# compare_genecode_to_ensembl_utrs.py is used to confirm that
# the gencode_edit_utr.py produces a result consistent with the
# UTR features in the Ensembl GTF file.
#
# It is critical that comparable versions of the Ensembl and
# Gencode GTF files be used.
#

#
# Version: 20220706a
#


import sys
import re
import argparse


target_feature_list = ['five_prime_utr', 'three_prime_utr', 'stop_codon']


def gtf_iterator(filename):
  """
  gtf_iterator is a generator function that reads a GTF
  file and returns information about the features specified
  in target_feature_list.
  """
  nrow = 0
  with open(filename, 'r') as fp:
    header_line_list = list()
    for line in fp:
      if(not re.match('^#', line)):
        row_split = line.rstrip().split('\t')
        nrow += 1
      else:
        continue
  
      chromosome = row_split[0]
      feature = row_split[2]
      start = int(row_split[3])
      end = int(row_split[4])
      strand = row_split[6]
 
      # Remove Gencode chr prefix on chromosome names. 
      chromosome = chromosome.replace('chr', '')
  
      if(feature in target_feature_list):
        att_list = row_split[8].split(';')
  
        transcript_id = None
        gene_type = None
        alternative_5_UTR = False
        alternative_3_UTR = False
  
        for att in att_list:
          att_pair = att.strip().split(' ')
          if(att_pair[0] == 'transcript_id'):
            transcript_id = att_pair[1]
            transcript_id = transcript_id.replace('"', '')
            transcript_id = re.sub('[.][0-9]+$', '', transcript_id)
  
        if(transcript_id == None):
          continue

        yield((transcript_id, chromosome, strand, start, end, feature))


def read_gtf(filename):
  """
  read_gtf reads the selected features into a dictionary keyed
  by the transcript_id given in the attributes field. The dictionary
  has the structure
    transcript_dict[transcript_id][feature][i]
  where transcript_id and feature are dictionary keys and 'i' is
  a list index for [chromosome, strand, start, end].
  """
  transcript_dict = dict()
  num_line = 0
  for (transcript_id, chromosome, strand, start, end, feature) in gtf_iterator(filename):
    num_line += 1
    if(transcript_dict.get(transcript_id) == None):
      transcript_dict[transcript_id] = dict()
    if(transcript_dict[transcript_id].get(feature) == None):
      transcript_dict[transcript_id][feature] = list()
    transcript_dict[transcript_id][feature].append([chromosome, strand, start, end])
  return(transcript_dict)


if __name__ == '__main__':

  parser = argparse.ArgumentParser(description='Compare a fixed Gencode GTF file to an Ensembl GTF file.')
  parser.add_argument('-g', '--gencode_gtf', required=True, help='Path to input fixed Gencode GTF file.')
  parser.add_argument('-e', '--ensembl_gtf', required=True, help='Path to input Ensembl GTF file.')
  args = parser.parse_args()

  gencode_gtf = args.gencode_gtf
  ensembl_gtf = args.ensembl_gtf

  print('Reading Ensembl GTF file...', file=sys.stderr)
  ensembl_dict = read_gtf(ensembl_gtf)
  print('Reading Gencode GTF file...', file=sys.stderr)
  gencode_dict = read_gtf(gencode_gtf)


  print('Comparing GTF files...', file=sys.stderr)

  # For each transcript in ensembl_dict, compare to the 3' UTRs 
  # in the gencode_dict.
  #   Notes:
  #     o  there are more UTRs in the gencode GTF than the
  #        ensembl GTF
  #     o  it looks like all of the 3' UTRs in ensembl are
  #        in gencode too
  #     o  the gencode 3' UTRs include the stop codon, at
  #        least generally
  #     o  the ensembl 3' UTRs exclude the stop codon, at
  #        least generally
  #     o  the ensembl and gencode 3' UTRS are the same
  #        when the transcript has no stop_codon, at least
  #        generally
  #     o  there is a small number of cases where the ensembl
  #        and gencode 5' ends of the 3' UTRs differ by 1
  #        or 2 bases.
  #     o  I'm collecting more counts than I report at this
  #        time.
  transcript_counter_dict = {'ensembl_not_gencode': 0, 'ensembl_and_gencode': 0}
  five_prime_utr_counter_dict = {'ensembl': 0, 'gencode': 0, 'ensembl_not_gencode': 0, 'gencode_not_ensembl': 0, 'ensembl_and_gencode': 0, 'not_ensembl_not_gencode': 0, 'match': 0}
  three_prime_utr_counter_dict = {'ensembl': 0, 'gencode': 0, 'ensembl_not_gencode': 0, 'gencode_not_ensembl': 0, 'ensembl_and_gencode': 0, 'not_ensembl_not_gencode': 0, 'match': 0}

  print('%d ensembl transcript_ids' % (len(ensembl_dict)))
  print('%d gencode transcript_ids' % (len(gencode_dict)))
  print()

  for transcript_id in ensembl_dict:
    if(gencode_dict.get(transcript_id) == None):
      transcript_counter_dict['ensembl_not_gencode'] += 1
      continue
    transcript_counter_dict['ensembl_and_gencode'] += 1

    if(ensembl_dict[transcript_id].get('five_prime_utr') != None and gencode_dict[transcript_id].get('five_prime_utr') != None):
      five_prime_utr_counter_dict['ensembl'] += len(ensembl_dict[transcript_id]['five_prime_utr'])
      five_prime_utr_counter_dict['gencode'] += len(gencode_dict[transcript_id]['five_prime_utr'])
      five_prime_utr_counter_dict['ensembl_and_gencode'] += len(ensembl_dict[transcript_id]['five_prime_utr']) + len(gencode_dict[transcript_id]['five_prime_utr'])
      for utr_id_ensembl in ensembl_dict[transcript_id]['five_prime_utr']:
        for utr_id_gencode in gencode_dict[transcript_id]['five_prime_utr']:
          # [chromosome, strand, start, end]
          if(utr_id_gencode[0] == utr_id_ensembl[0] and utr_id_gencode[1] == utr_id_ensembl[1] and utr_id_gencode[2] == utr_id_ensembl[2] and utr_id_gencode[3] == utr_id_ensembl[3]):
            five_prime_utr_counter_dict['match'] += 1
            break
    elif(ensembl_dict[transcript_id].get('five_prime_utr') != None):
      five_prime_utr_counter_dict['ensembl'] += 1
      five_prime_utr_counter_dict['ensembl_not_gencode'] += 1
    elif(gencode_dict[transcript_id].get('five_prime_utr') != None):
      five_prime_utr_counter_dict['gencode'] += 1
      five_prime_utr_counter_dict['gencode_not_ensembl'] += 1
    else:
      five_prime_utr_counter_dict['not_ensembl_not_gencode'] += 1

    if(ensembl_dict[transcript_id].get('three_prime_utr') != None and gencode_dict[transcript_id].get('three_prime_utr') != None):
      three_prime_utr_counter_dict['ensembl'] += len(ensembl_dict[transcript_id]['three_prime_utr'])
      three_prime_utr_counter_dict['gencode'] += len(gencode_dict[transcript_id]['three_prime_utr'])
      three_prime_utr_counter_dict['ensembl_and_gencode'] += len(ensembl_dict[transcript_id]['three_prime_utr']) + len(gencode_dict[transcript_id]['three_prime_utr'])
      for utr_id_ensembl in ensembl_dict[transcript_id]['three_prime_utr']:
        for utr_id_gencode in gencode_dict[transcript_id]['three_prime_utr']:
          matchFlag = False
          # [chromosome, strand, start, end]
          if(utr_id_gencode[0] == utr_id_ensembl[0] and utr_id_gencode[1] == utr_id_ensembl[1]):
            if(utr_id_ensembl[1] == '+'):
              if(utr_id_gencode[3] == utr_id_ensembl[3] and (utr_id_gencode[2] == utr_id_ensembl[2] or \
                                                             utr_id_gencode[2]+1 == utr_id_ensembl[2] or \
                                                             utr_id_gencode[2]+2 == utr_id_ensembl[2] or \
                                                             utr_id_gencode[2]+3 == utr_id_ensembl[2])):
                three_prime_utr_counter_dict['match'] += 1
                matchFlag = True
                break
            elif(utr_id_ensembl[1] == '-'):
              if(utr_id_gencode[2] == utr_id_ensembl[2] and (utr_id_gencode[3] == utr_id_ensembl[3] or \
                                                             utr_id_gencode[3]-1 == utr_id_ensembl[3] or \
                                                             utr_id_gencode[3]-2 == utr_id_ensembl[3] or \
                                                             utr_id_gencode[3]-3 == utr_id_ensembl[3])):
                three_prime_utr_counter_dict['match'] += 1
                matchFlag = True
                break
            else:
              print('Unrecognized strand', file=sys.stderr)
  # diagnostics
  #      if(not matchFlag):
  #        print('Missing: %s %s %s %d %d %s' % (transcript_id, utr_id_ensembl[0], utr_id_ensembl[1], utr_id_ensembl[2], utr_id_ensembl[3], 'three_prime_utr')) 
  #        for utr_id_gencode in gencode_dict[transcript_id]['three_prime_utr']:
  #          print('gen: %s %s %d %d %s' % (utr_id_gencode[0], utr_id_gencode[1], utr_id_gencode[2], utr_id_gencode[3], 'three_prime_utr'))
    elif(ensembl_dict[transcript_id].get('three_prime_utr') != None):
      three_prime_utr_counter_dict['ensembl'] += 1
      three_prime_utr_counter_dict['ensembl_not_gencode'] += 1
    elif(gencode_dict[transcript_id].get('three_prime_utr') != None):
      three_prime_utr_counter_dict['gencode'] += 1
      three_prime_utr_counter_dict['gencode_not_ensembl'] += 1
    else:
      three_prime_utr_counter_dict['not_ensembl_not_gencode'] += 1

  print('transcripts: %d' % (transcript_counter_dict['ensembl_and_gencode']))
  print()
  print('ensembl 5\' UTRs: %d' % (five_prime_utr_counter_dict['ensembl']))
  print('matched 5\' UTRs: %d' % (five_prime_utr_counter_dict['match']))
  print()
  print('ensembl 3\' UTRs: %d' % (three_prime_utr_counter_dict['ensembl']))
  print('matched 3\' UTRs: %d' % (three_prime_utr_counter_dict['match']))
  print()


