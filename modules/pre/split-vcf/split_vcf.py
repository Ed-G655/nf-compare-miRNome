#!/usr/bin/env python3

## Import python libraries
import sys
import subprocess


## Read args from command line
    ## Uncomment For debugging only
    ## Comment for production mode only
#sys.argv = ("0", "sample.vcf.gz")

##get  VCF
VCF = sys.argv[1]

VCF_file = str(VCF)


#Define command to  index vcf file
index_VCF = "bcftools index {}\n".format(VCF_file)
print ("The command used was: " + index_VCF)
#Pass command to shell
subprocess.call(index_VCF, shell=True)
#Dedine command to write chroms_list
chroms_list =  "tabix --list-chroms {} > chroms.txt".format(VCF_file)
print ("The command used was: " + chroms_list)
#Pass command to shell
subprocess.call(chroms_list, shell=True)

#Read list of chroms
chromosomes = open("chroms.txt", "r").readlines()
#content_list = my_file.readlines()
for chrom in chromosomes:
     print ("Extracting {} into {}.vcf.gz".format(chrom.replace('\n', ''), chrom.replace('\n', '')))
     #Dedine command to split vcf file per chrom
     SPLIT_VCF =  "bcftools view {} {} | bgzip -c > {}.vcf.gz".format(VCF_file, chrom.replace('\n', ''), chrom.replace('\n', ''))
     print ("The command used was: " + SPLIT_VCF)
     #Pass command to shell
     subprocess.call(SPLIT_VCF, shell=True)
