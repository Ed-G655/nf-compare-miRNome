#!/usr/bin/env nextflow
/*================================================================

								---- MODULE PIPELINE ---------

/*================================================================
The Aguilar Lab presents...

- A pipeline to classify SNPs in microRNA regions and provide an overview of
diseases associated with microRNAs that present SNPs

==================================================================
Version: 0.2
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


process CLASSIFY_SNPs_BY_REGION {
	tag "$MIRNAS, $MIRNAS_SEED"

	publishDir "${results_dir}/classify-SNPs-by-region/",mode:"copy"

	input:
	file MIRNAS
	file MIRNAS_SEED
	file R_script_2

	output:
	path "*.tsv", emit: mirna_snps
	file "*.png"

	shell:
	"""
	Rscript --vanilla ${R_script_2} ${MIRNAS} ${MIRNAS_SEED} ${MIRNAS.baseName}_out
	"""
	stub:
	"""
	      touch ${MIRNAS.baseName}_out.tsv
				touch ${MIRNAS.baseName}.png
	"""
}
