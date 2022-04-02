#!/usr/bin/env python3

""" This scrip predicts miRNA targets using the python miRmap libray.

The script takes two input files:
    1) A FASTA file that list the miRNA sequences and they miRNA ID.
    2) A FASTA file that list the 3' UTRs sequences of desired genes.

Basic ideas:
    1. Grab FASTA files.
    2. Read through FASTA files, getthing one sequence of miRNA and UTR at time.
    3. Identify miRNA sites for each 3´ UTR gene.
    4. Define the type of miRNA site(8mer-1a,7mer-1a,7mer-m8 and 6mer)
    5. Calculate the starting position of site in UTR.
    6- Write ouput as TSV file

Autor:  Eduardo García López"""

## Import python libraries
from Bio import SeqIO
from Bio.Seq import Seq
import mirmap
import sys

## Read args from command line
    ## Uncomment For debugging only
    ## Comment for production mode only
#sys.argv = ("0", "test/data/sample1.mirna.fa", "test/data/sample1.utr.fa", "test/data/sample1.output.tsv")

##get the miRNA FASTA file from args
miRNA_fasta = sys.argv[1]

##get UTR FASTA file from args
UTR_fasta = sys.argv[2]

##get ouput file name from args

Ouput_file = sys.argv[3]

## Define FASTA sequences as lists
list_mirna = list(SeqIO.parse(str(miRNA_fasta), "fasta")) #get miRNA data

list_UTR = list(SeqIO.parse(str(UTR_fasta), "fasta")) #get 3' UTR gene data


## Define variables

i = (len(list_mirna))-1 #Get the lengt of miRNA sequence list
j = (len(list_UTR))-1  #Get the lengt of get 3' UTR gene list

u = 0 #Numer of elements in the 3' UTR gene list

k = 0 #This variable allows us to obtain information on genes with multiple mirna sites

## Write output files
results = open(str(Ouput_file),'w') # Ouput TSV dataframe

## Print output file header
results.write("GeneID\tmiRNA_ID\tUTR_start\tUTR_end\tSite_type\n")

## Print lengt of FASTA files
print ("...")
print ("Total of miRNAs to process: {}".format(i+1))
print ("Total of 3´ UTR genes to process: {}".format(j+1))
print ("...")

## Loop for get one sequence 3' UTR gene at time.
while u <= j:
    m = 0 # Numer of item in the miRNA sequence list
    print ("Processing {}".format(list_UTR[u].id))

    ## Loop for get one sequence miRNA at time.
    while m <= i:
        ## mirmap objets
        seq_target = str(list_UTR[u].seq) # 3' UTR gene sequence
        seq_mirna = str(list_mirna[m].seq) # miRNA sequence

        mim = mirmap.mm(seq_target, seq_mirna) # Group imput sequences

## mirmap model features
#       allowed_lengths (list): List of seed length(s).
#       allowed_gu_wobbles (dict): For each seed length (key), how many GU
#            wobbles are allowed (value).
#       allowed_mismatches (dict): For each seed length (key), how many
#       take_best (bool): If seed matches are overlapping, taking or not
#            the longest.

        mim.find_potential_targets_with_seed(allowed_lengths=[6,7], \
        allowed_gu_wobbles={6:0,7:0}, allowed_mismatches={6:0,7:0}, take_best=True)

        l = len(mim.end_sites) # Variable to get the number of miRNA sites in one 3´UTR gene

        try:
## Write Output files
            for k in range (l):
                ## Calculate the starting position of site in UTR.
                start_sites = int(mim.end_sites[k])-int(mim.seed_lengths[k]) #UTR_start

                end_sites = int(mim.end_sites[k])-1  # Variable for print the ending position of site in UTR.
                ## Define the type of miRNA site(8mer-1a,7mer-1a,7mer-m8 and 6mer)
                end_site_nucleotide = seq_target[(mim.end_sites[k]-1)] # variable to get the nucletide at the UTR_end
                if mim.seed_lengths[k] == 7 and end_site_nucleotide == "A":
                    site_type = "8mer-1a"
                    end_sites = int(mim.end_sites[k])
                elif mim.seed_lengths[k] == 7:
                            site_type = "7mer-m8"
                elif mim.seed_lengths[k] == 6 and end_site_nucleotide == "A":
                            site_type = "7mer-1a"
                            end_sites = int(mim.end_sites[k])
                else:
                    site_type = "6mer"
                ## Write ouput files data
                results.write("{}\t{}\t{}\t{}\t{}\n".format(list_UTR[u].id, list_mirna[m].id,\
                start_sites, end_sites, site_type))

            m +=1
        except:
            print("=== Sequence error ===")
            m += 1
    u +=1

## Close files
results.close()

## Print final ouput
print ("...")
print ("Total miRNAs analyzed :{}".format(i + 1))
print ("...")
print ("Total 3´ UTR gene analyzed :{}".format(j + 1))
print("...")
