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

process SPLIT_VCF {
	tag "$VCF"

	publishDir "${intermediates_dir}/split-vcf/",mode:"symlink"

	input:
	file VCF
	file split_vcf_script

	output:
	file "*.vcf.gz"

	shell:
	"""

  bcftools index !{VCF}
	tabix --list-chroms !{VCF} > chroms.txt
	python3 split_vcf.py !{VCF}

	"""
	stub:
	"""
				touch 21.vcf.gz
				touch 22.vcf.gz
	"""
}
