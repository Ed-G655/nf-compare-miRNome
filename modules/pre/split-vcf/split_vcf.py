#!/usr/bin/env python3

## Import python libraries
import sys
import subprocess
import multiprocessing as mp


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

def split_vcf(vcf):
    for chrom in chromosomes:
        """ This function split a compressed VCF file by chromosomes using bcftools """
        print ("Extracting {} into {}.vcf.gz".format(chrom.replace('\n', ''), chrom.replace('\n', '')))
        #Dedine command to split vcf file per chrom
        SPLIT_VCF =  "bcftools view {} {} | bgzip -c > {}.vcf.gz".format(vcf, chrom.replace('\n', ''), chrom.replace('\n', ''))
        print ("The command used was: " + SPLIT_VCF)
        #Pass command to shell
        subprocess.call(SPLIT_VCF, shell=True)


pool = mp.Pool(mp.cpu_count())

pool.map(split_vcf, [VCF_file for chrom in chromosomes])

pool.close()
