#!/usr/bin/env python3

#
# Program: gencode_edit_utr.py
#
# Description:
# Read a Gencode GTF file and change the 'UTR' features to either
# 'five_prime_utr' or 'three_prime_utr', where possible. Then
# write the modified GTF.
#
# This program includes a load of checks.
#
# The scripts/compare_genecode_to_ensembl_utrs.py program can be
# used to help verify the resulting file.

#
# Version: 20220706a
#


import sys
import re
import argparse


diagnostic_out = sys.stdout


def check_transcript_consistency(transcript_id, transcript_dict):
  """
  Check the features stored for transcript_id in transcript_dict for
  consistency.
  """
  chromosome = transcript_dict[transcript_id]['transcript'][0][0]
  strand     = transcript_dict[transcript_id]['transcript'][0][1]

  errorFlag = 0

  # Expect one transcript feature.
  if(len(transcript_dict[transcript_id]['transcript']) != 1):
    print('Error: transcript %s has %d \"transcript\" feature rows.' % (transcript_id, len(transcript_dict[transcript_id]['transcript'])), file=diagnostic_out)
    errorFlag = -1

  # Expect consistent start_codon chromosome and strand.
  if(transcript_dict[transcript_id].get('start_codon') != None):
    if(transcript_dict[transcript_id]['start_codon'][0][0] != chromosome):
      print('Error: transcript %s start_codon feature has inconsistent chromosome.' % (transcript_id), file=diagnostic_out)
      errorFlag = -1
    if(transcript_dict[transcript_id]['start_codon'][0][1] != strand):
      print('Error: transcript %s start_codon feature has inconsistent strand.' % (transcript_id), file=diagnostic_out)
      errorFlag = -1

  # Expect consistent stop_codon chromosome and strand.
  if(transcript_dict[transcript_id].get('stop_codon') != None):
    if(transcript_dict[transcript_id]['stop_codon'][0][0] != chromosome):
      print('Error: transcript %s stop_codon feature has inconsistent chromosome.' % (transcript_id), file=diagnostic_out)
      errorFlag = -1
    if(transcript_dict[transcript_id]['stop_codon'][0][1] != strand):
      print('Error: transcript %s stop_codon feature has inconsistent strand.' % (transcript_id), file=diagnostic_out)
      errorFlag = -1

  # Expect consistent UTR chromosome and strand.
  for iutr in range(len(transcript_dict[transcript_id]['UTR'])):
    if(transcript_dict[transcript_id]['UTR'][iutr][0] != chromosome):
      print('Error: transcript %s UTR feature has inconsistent chromosome.' % (transcript_id), file=diagnostic_out)
      errorFlag = -1
    if(transcript_dict[transcript_id]['UTR'][iutr][1] != strand):
      print('Error: transcript %s UTR feature has inconsistent strand.' % (transcript_id), file=diagnostic_out)
      errorFlag = -1
  return(errorFlag)


#
# Assumptions:
#   o  all start_codon features are 5' of all stop_codons
#      (non-overlapping) in the transcript frame
#   o  UTRs do not overlap any CDS features in the case
#      that there is no start_codon and no stop_codon
def check_feature_assumptions(transcript_dict):
  """
  We make assumptions for the purpose of distinguishing between
  5' and 3' UTRs. Check these assumptions as best we can.
  """
  tot_error_1 = 0
  tot_error_2 = 0
  for transcript_id in transcript_dict:

    if('UTR' in transcript_dict[transcript_id]):
      if(not 'transcript' in transcript_dict[transcript_id]):
        print('Warning: transcript_id %s has no transcript feature.' % (transcript_id), file=diagnostic_out)
        continue

      strand = transcript_dict[transcript_id]['transcript'][0][1]

      if('start_codon' in transcript_dict[transcript_id] and 'stop_codon' in transcript_dict[transcript_id]):
        # Test 1
        errorFlag1 = False

        start_codon_min = None
        start_codon_max = None
        for start_codon in transcript_dict[transcript_id]['start_codon']:
          if(start_codon_min == None or start_codon[2] < start_codon_min):
            start_codon_min = start_codon[2]
          if(start_codon_max == None or start_codon[3] > start_codon_max):
            start_codon_max = start_codon[3]

        stop_codon_min = None
        stop_codon_max = None
        for stop_codon in transcript_dict[transcript_id]['stop_codon']:
          if(stop_codon_min == None or stop_codon[2] < stop_codon_min):
            stop_codon_min = stop_codon[2]
          if(stop_codon_max == None or stop_codon[3] > stop_codon_max):
            stop_codon_max = stop_codon[3]

        if(strand == '+'):
          if(stop_codon_min <= start_codon_max):
            errorFlag1 = True
        elif(strand == '-'):
          if(start_codon_min <= stop_codon_max):
            errorFlag1 = True
        else:
          print('Error: unexpected strand value for transcript %s' % (transcript_id), file=diagnostic_out)

        if(errorFlag1):
          tot_error_1 += 1

      elif((not 'start_codon' in transcript_dict[transcript_id]) and (not 'stop_codon' in transcript_dict[transcript_id])):
        if('CDS' in transcript_dict[transcript_id]):
          cds_min = None
          cds_max = None
          for cds in transcript_dict[transcript_id]['CDS']:
            if(cds_min == None or cds[2] < cds_min):
              cds_min = cds[2]
            if(cds_max == None or cds[3] > cds_max):
              cds_max = cds[3]
          # Does UTR overlap the CDS region?
          errorFlag2 = False
          for utr in transcript_dict[transcript_id]['UTR']:
            # !(utr[3] < cds_min or utr[2] > cds_max)
            if(utr[3] >= cds_min and utr[2] <= cds_max):
              errorFlag2 = True
              break
          if(errorFlag2):
            tot_error_2 += 1

  print('Info: check_feature_assumptions 1: number failed transcripts: %d' % (tot_error_1), file=diagnostic_out)
  print('Info: check_feature_assumptions 2: number failed transcripts: %d' % (tot_error_2), file=diagnostic_out)

  return(0)


def test_for_5prime_utr(transcript_id, utr, start_codon, strand):
  """
  Identify 5' UTRs as UTRs that are 5' of the given start codon.
  """
  start_codon_start = start_codon[2]
  start_codon_end   = start_codon[3]
  utr_type = None
  if(strand == '+'):
    # 5' UTR aaa is start codon
    #    DNA     xxxxxxxaaaxxxxxxx
    #    CDS            ==========
    #    5' UTR  -------
    if(utr[3] < start_codon_start):
      utr_type = 'five_prime_utr'
  elif(strand == '-'):
    # 5' UTR aaa is start codon
    #    DNA     xxxxxxxaaaxxxxxxx
    #    CDS     ==========
    #    5' UTR            -------
    if(utr[2] > start_codon_end):
      utr_type = 'five_prime_utr'
  else:
    print('Error: unrecognized strand %s.' % (strand), file=diagnostic_out)

  if(utr_type != None and utr[8] != None):
    if(utr[8] != utr_type):
      print('Error: transcript %s: inconsistent utr_type designations %s and %s.' % (transcript_id, utr_type, utr[8]), file=diagnostic_out)
      utr_type = None
  elif(utr_type == None):
    utr_type = utr[8]
  elif(utr_type != None and utr[8] == None):
    utr_type = utr_type
  else:
    print('Error: inconsistent condition.', file=diagnostic_out)
  return(utr_type)


def alt_test_for_5prime_utr(transcript_id, utr, stop_codon, strand):
  """
  In desperation, indentify 5' UTRs as 5' of a transcript stop codon.
  """
  if(utr[8] != None):
    return(utr[8])
  stop_codon_start = stop_codon[2]
  stop_codon_end   = stop_codon[3]
  utr_type = None
  if(strand == '+'):
    # 5' UTR aaa is stop codon
    #    DNA             xxxxxxxaaaxxxxxxx
    #    CDS             =======
    #    5' UTR  ----...
    if(utr[3] < stop_codon_start):
      utr_type = 'five_prime_utr'
  elif(strand == '-'):
    # 5' UTR aaa is stop codon
    #    DNA     xxxxxxxaaaxxxxxxx
    #    CDS               =======
    #    5' UTR            ...-------
    if(utr[2] > stop_codon_end):
      utr_type = 'five_prime_utr'
  else:
    print('Error: unrecognized strand %s.' % (strand), file=diagnostic_out)
  return(utr_type)


def test_for_3prime_utr(transcript_id, utr, stop_codon, strand):
  """
  Identify 3' UTRs as UTRs that are at or 3' of the given start codon.
  """
  stop_codon_start = stop_codon[2]
  stop_codon_end   = stop_codon[3]
  utr_type = None
  if(strand == '+'):
    # 3' UTR zzz is stop codon
    #    DNA     xxxxxxxzzzxxxxxxx
    #    CDS     =======
    #    3' UTR         ----------
    if(utr[2] >= stop_codon_start):
      utr_type = 'three_prime_utr'
  elif(strand == '-'):
    # 3' UTR zzz is stop codon
    #    DNA     xxxxxxxzzzxxxxxxx
    #    CDS               =======
    #    3' UTR  ----------
    if(utr[3] <= stop_codon_end):
      utr_type = 'three_prime_utr'
  else:
    print('Error: unrecognized strand %s.' % (strand), file=diagnostic_out)

  if(utr_type != None and utr[8] != None):
    if(utr[8] != utr_type):
      print('Error: transcript %s: inconsistent utr_type designations %s and %s.' % (transcript_id, utr_type, utr[8]), file=diagnostic_out)
      utr_type = None
  elif(utr_type == None):
    utr_type = utr[8]
  elif(utr_type != None and utr[8] == None):
    utr_type = utr_type
  else:
    print('Error: inconsistent condition.', file=diagnostic_out)
  return(utr_type)


def alt_test_for_3prime_utr(transcript_id, utr, start_codon, strand):
  """
  In desperation, indentify 3' UTRs as 3' of a transcript start codon.
  """
  if(utr[8] != None):
    return(utr[8])
  start_codon_start = start_codon[2]
  start_codon_end   = start_codon[3]
  utr_type = None
  if(strand == '+'):
    # 5' UTR aaa is start codon
    #    DNA      xxxxxxxaaaxxxxxxx
    #    CDS             =======
    #    3' UTR                 ...----
    if(utr[2] > start_codon_end):
      utr_type = 'three_prime_utr'
  elif(strand == '-'):
    # 5' UTR aaa is start codon
    #    DNA              xxxxxxxaaaxxxxxxx
    #    CDS                 =======
    #    3' UTR  -------...
    if(utr[3] < start_codon_start):
      utr_type = 'three_prime_utr'
  else:
    print('Error: unrecognized strand %s.' % (strand), file=diagnostic_out)
  return(utr_type)


def cds_test_for_utr(transcript_id, utr, cds_list, strand):
  """
  Identify 5' UTRs as 5' of the first transcript CDS base and
  3' UTRs as 3' of the last transcript CDS base. I use this
  test when the start_codon/stop_codon test fails (usually when
  the transcript has no start/stop codon).
  """
  if(utr[8] != None):
    return(utr[8])

  cds_start = None
  cds_end = None
  for cds in cds_list:
    if(cds_start == None or cds[2] < cds_start):
      cds_start = cds[2]
    if(cds_end == None or cds[3] > cds_end):
      cds_end = cds[3]

  if(cds_start == None or cds_end == None):
    return(None)

  utr_type = None
  if(strand == '+'):
    if(utr[3] < cds_start):
      utr_type = 'five_prime_utr'
    elif(utr[2] > cds_end):
      utr_type = 'three_prime_utr'
  elif(strand == '-'):
    if(utr[2] > cds_end):
      utr_type = 'five_prime_utr'
    elif(utr[3] < cds_start):
      utr_type = 'three_prime_utr'
  return(utr_type)


def count_unmodified_utr(transcript_dict):
  """
  Statistics.
  """
  num_utr = 0
  num_unmodified = 0
  for transcript_id in transcript_dict:
    if('UTR' in transcript_dict[transcript_id].keys()):
      for iutr in range(len(transcript_dict[transcript_id]['UTR'])):
        num_utr += 1
        if(transcript_dict[transcript_id]['UTR'][iutr][8] == None):
          num_unmodified += 1
          print('transcript %s: unmodified utr at %d %d' % (transcript_id, transcript_dict[transcript_id]['UTR'][iutr][2], transcript_dict[transcript_id]['UTR'][iutr][3]), file=diagnostic_out)
  return((num_utr, num_unmodified))


def count_unmodified_utr_by_start_stop_codon(transcript_dict):
  """
  Statistics.
  """
  num_unmodified = 0
  num_utr_no_start = 0
  num_utr_no_stop = 0
  num_utr_no_start_no_stop = 0
  for transcript_id in transcript_dict:
    if('UTR' in transcript_dict[transcript_id].keys()):
      flagUnmodified = False
      for utr in transcript_dict[transcript_id]['UTR']:
        if(utr[8] == None):
          flagUnmodified = True
          break
      if(flagUnmodified):
        num_unmodified += 1
        if((not 'start_codon' in transcript_dict[transcript_id].keys()) and (not 'stop_codon' in transcript_dict[transcript_id].keys())):
          num_utr_no_start_no_stop += 1
        elif(not 'start_codon' in transcript_dict[transcript_id].keys()):
          num_utr_no_start += 1
        elif(not 'stop_codon' in transcript_dict[transcript_id].keys()):
          num_utr_no_stop += 1
  print('%d transcripts with at least one unmodified UTR' % (num_unmodified), file=diagnostic_out)
  print('%d transcripts with at least one unmodified UTR and no start_codon and no stop_codon' % (num_utr_no_start_no_stop), file=diagnostic_out)
  print('%d transcripts with at least one unmodified UTR and no start_codon and yes stop_codon' % (num_utr_no_start), file=diagnostic_out)
  print('%d transcripts with at least one unmodified UTR and yes start_codon and no stop_codon' % (num_utr_no_stop), file=diagnostic_out)
  return(0)



if __name__ == '__main__':

  parser = argparse.ArgumentParser(description='Script replace Gencode GTF file \'UTR\' feature names with either \'five_prime_utr\' or \'three_prime_utr\', where possible.')
  parser.add_argument('-i', '--input_gtf', required=True, help='Path to input Gencode GTF file.')
  parser.add_argument('-o', '--output_gtf', required=True, help='Path to output GTF file.')
  args = parser.parse_args()

  #
  # These are the features that we use to distinguish between
  # 5' and 3' UTRs.
  #
  target_feature_list = ['transcript', 'CDS', 'UTR', 'start_codon', 'stop_codon']

  #
  # A list of selected GTF file rows split by the field separator '\t'.
  # That is, row_split_list[<row index>][<field index>].
  #
  row_split_list = list()

  #
  # Gencode vs Ensembl difference
  #   o  genecode appears to have 3' UTRs that consist of the stop codon only
  #   o  genecode 3' UTRs include the stop codon whereas Ensembl 3' UTRs do not

  # transcript_dict structure
  #
  # key = transcript_id
  # value = dict {'transcript' = [], 'CDS' = [], 'start_codon' = [], 'stop_codon' = [], 'UTR' = []}
  # each value in the lists above consist of a list of, minimally,
  #   chromosome
  #   strand
  #   start
  #   end
  #   gene_type
  #
  # and for UTRs have additionally
  #   alternative_5_UTR
  #   alternative_3_UTR
  #   irow
  #   end_id = ('five_prime_utr'|'three_prime_utr'|None)
  #
  transcript_dict = dict()

  #
  # Read lines (split) into a list, parse the attributes,
  # and store transcript information in a dictionary.
  #
  print('Read file...', file=diagnostic_out)
  nrow = 0
  with open(args.input_gtf, 'r') as fp:
    header_line_list = list()
    for line in fp:
      if(not re.match('^#', line)):
        row_split = line.rstrip().split('\t')
        row_split_list.append(row_split)
        nrow += 1
      else:
        header_line_list.append(line.rstrip())
        continue

      chromosome = row_split[0]
      feature = row_split[2]
      start = int(row_split[3])
      end = int(row_split[4])
      strand = row_split[6]

      if(feature in target_feature_list):
        att_list = row_split[8].split(';')

        transcript_id = None
        gene_type = None
        alternative_5_UTR = False
        alternative_3_UTR = False

        for att in att_list:
          att_pair = att.strip().split(' ')
          if(att_pair[0] == 'tag' and att_pair[1] == '\"alternative_5_UTR\"'):
            alternative_5_UTR = True
          if(att_pair[0] == 'tag' and att_pair[1] == '\"alternative_3_UTR\"'):
            alternative_3_UTR = True
          if(att_pair[0] == 'gene_type'):
            gene_type = att_pair[1]
          if(att_pair[0] == 'transcript_id'):
            transcript_id = att_pair[1]

        if(transcript_id != None):
          if(transcript_dict.get(transcript_id) == None):
            transcript_dict[transcript_id] = dict()
          if(transcript_dict[transcript_id].get(feature) == None):
            transcript_dict[transcript_id][feature] = list()
          if(feature == 'UTR'):
            # transcript_dict[transcript_id][feature][ifeature][ielement] elements
            #  ielement   description
            #  0          chromosome
            #  1          strand
            #  2          start
            #  3          end
            #  4          gene_type
            #  5          alternative_5_UTR   (UTR only)
            #  6          alternative_3_UTR   (UTR only)
            #  7          irow                (UTR only)
            #  8          (5|3) prime utr     (UTR only)
            transcript_dict[transcript_id][feature].append([chromosome, strand, start, end, gene_type, alternative_5_UTR, alternative_3_UTR, nrow-1, None])
          else:
            transcript_dict[transcript_id][feature].append([chromosome, strand, start, end, gene_type])
        else:
          print('Warning: no transcript_id for %s at %s %s %s %s' % (feature, chromosome, strand, start, end), file=diagnostic_out)


  #
  # Check feature assumptions used to modify UTR features.
  #
  check_feature_assumptions(transcript_dict)

  #
  # Convert UTR features to either five_prime_utr or three_prime_utr features.
  #
  print('Convert UTR features...', file=diagnostic_out)
  unmodified_pass_1 = 0
  unmodified_pass_2 = 0
  unmodified_pass_3 = 0
  for transcript_id in transcript_dict.keys():
    if('UTR' in transcript_dict[transcript_id]):
      # Check transcript-collected part consistency.

      if(check_transcript_consistency(transcript_id, transcript_dict) == -1):
        continue

      chromosome = transcript_dict[transcript_id]['transcript'][0][0]
      strand     = transcript_dict[transcript_id]['transcript'][0][1]

      #
      # Convert 5' UTRs using start codons.
      if('start_codon' in transcript_dict[transcript_id]):
        for codon in transcript_dict[transcript_id]['start_codon']:
          for iutr in range(len(transcript_dict[transcript_id]['UTR'])):
            utr = transcript_dict[transcript_id]['UTR'][iutr]
            transcript_dict[transcript_id]['UTR'][iutr][8] = test_for_5prime_utr(transcript_id, utr, codon, strand)

      # Convert 3' UTRs using stop codons.
      if('stop_codon' in transcript_dict[transcript_id]):
        for codon in transcript_dict[transcript_id]['stop_codon']:
          for iutr in range(len(transcript_dict[transcript_id]['UTR'])):
            utr = transcript_dict[transcript_id]['UTR'][iutr]
            transcript_dict[transcript_id]['UTR'][iutr][8] = test_for_3prime_utr(transcript_id, utr, codon, strand)

      flagUnmodified = False
      for utr in transcript_dict[transcript_id]['UTR']:
        if(utr[8] == None):
          flagUnmodified = True
          break

      if(flagUnmodified):
        unmodified_pass_1 += 1

      #
      # Try to identify the UTR type using CDS ends.
      #
      for iutr in range(len(transcript_dict[transcript_id]['UTR'])):
        utr = transcript_dict[transcript_id]['UTR'][iutr]
        if(utr[8] == None and 'CDS' in transcript_dict[transcript_id]):
          cds_list = transcript_dict[transcript_id]['CDS']
          transcript_dict[transcript_id]['UTR'][iutr][8] = cds_test_for_utr(transcript_id, utr, cds_list, strand)

      flagUnmodified = False
      for utr in transcript_dict[transcript_id]['UTR']:
        if(utr[8] == None):
          flagUnmodified = True
          break

      if(flagUnmodified):
        unmodified_pass_2 += 1

      # Try to modify unmodified UTRs using less confident strategies.
      for iutr in range(len(transcript_dict[transcript_id]['UTR'])):
        utr = transcript_dict[transcript_id]['UTR'][iutr]
        if(utr[8] == None):
          if('stop_codon' in transcript_dict[transcript_id]):
            for codon in transcript_dict[transcript_id]['stop_codon']:
              transcript_dict[transcript_id]['UTR'][iutr][8] =  alt_test_for_5prime_utr(transcript_id, utr, codon, strand)

        utr = transcript_dict[transcript_id]['UTR'][iutr]
        if(utr[8] == None):
          if('start_codon' in transcript_dict[transcript_id]):
            for codon in transcript_dict[transcript_id]['start_codon']:
              transcript_dict[transcript_id]['UTR'][iutr][8] =  alt_test_for_3prime_utr(transcript_id, utr, codon, strand)

      flagUnmodified = False
      for utr in transcript_dict[transcript_id]['UTR']:
        if(utr[8] == None):
          flagUnmodified = True
          break

      if(flagUnmodified):
        unmodified_pass_3 += 1


  print('%d transcripts have an unmodified UTR after pass 1.' % (unmodified_pass_1), file=diagnostic_out)
  print('%d transcripts have an unmodified UTR after pass 2.' % (unmodified_pass_2), file=diagnostic_out)
  print('%d transcripts have an unmodified UTR after pass 3.' % (unmodified_pass_3), file=diagnostic_out)

  #
  # Report unmodified UTR annotations.
  #
  (num_utr, num_unmodified_utr) = count_unmodified_utr(transcript_dict)
  print('Info: %d UTRs of %d are unmodified.' % (num_unmodified_utr, num_utr), file=diagnostic_out)

  count_unmodified_utr_by_start_stop_codon(transcript_dict)

  #
  # Edit UTR rows.
  #
  print('Edit UTR rows...', file=diagnostic_out)
  for transcript_id in transcript_dict.keys():
    if('UTR' in transcript_dict[transcript_id]):
      for iutr in range(len(transcript_dict[transcript_id]['UTR'])):
        irow = transcript_dict[transcript_id]['UTR'][iutr][7]
        row_split_list[irow][2] = transcript_dict[transcript_id]['UTR'][iutr][8]

  #
  # Write the header and edited rows.
  #
  ofp = open(args.output_gtf, 'w')
  print('Write edited file...', file=diagnostic_out)
  for header_line in header_line_list:
    print('%s' % (header_line), file=ofp)
  for row_split in row_split_list:
    print('%s' % ('\t'.join(row_split)), file=ofp)
  ofp.close()


