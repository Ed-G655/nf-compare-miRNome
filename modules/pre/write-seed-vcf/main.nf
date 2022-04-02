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
pipeline_name = "nf-compare-miRNome.nf"

/*This directories will be automatically created by the pipeline to store files during the run
*/
results_dir = "${params.output_dir}/${pipeline_name}-results/"
intermediates_dir = "${params.output_dir}/${pipeline_name}-intermediate/"

/*================================================================/*

/* MODULE START */

process WRITE_SEED_VCF {
	tag "$BED, $VCF"

	publishDir "${intermediates_dir}/WRITE_SEED_VCF/",mode:"symlink"

	input:
	file BED
	file VCF

	output:
	file "*.vcf.gz"

	shell:
	"""
	bedtools intersect -a ${VCF} -b ${BED} -wa -header \
    | bgzip -c > ${BED.baseName}.vcf.gz
	"""
	stub:
	"""
	      touch ${BED.baseName}.vcf.gz
	"""
}
