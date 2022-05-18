#!/usr/bin/env nextflow
/*================================================================

								---- MODULE PIPELINE ---------

/*================================================================
The Aguilar Lab presents...

- A pipeline to extract and create miRNA and 3'UTR consensus sequences for analysis
   with targetscan and miRmap.

==================================================================
Version: 0.1
Project repository:
==================================================================
Authors:

- Bioinformatics Design
 Jose Eduardo Garcia-Lopez (jeduardogl655@gmail.com)



- Bioinformatics Development
 Jose Eduardo Garcia-Lopez (jeduardogl655@gmail.com)


- Nextflow Port
 Jose Eduardo Garcia-Lopez (jeduardogl655@gmail.com)

///////////////////////////////////////////////////////////////

  Define pipeline Name
  This will be used as a name to include in the results and intermediates directory names
*/
pipeline_name = "nf-compare-miRNome"

/*This directories will be automatically created by the pipeline to store files during the run
*/
results_dir = "${params.output_dir}/${pipeline_name}-results/"
intermediates_dir = "${params.output_dir}/${pipeline_name}-intermediate/"

/*================================================================/*

/* MODULE START */

process EXTRACT_BIALLELIC_SNPs {
	tag "$VCF"

	publishDir "${intermediates_dir}/extract-biallelic-snps/",mode:"copy"

	input:
	file VCF

	output:
	file "*.tmp"

	shell:
	"""
  bcftools norm -m+ ${VCF} \
    | bcftools view -m2 -M2 -v snps \
    |	bgzip -c > ${VCF}.tmp
  """

  stub:
	"""
	      touch ${VCF}.tmp
	"""
}
