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

/* PRE1_CONVERT_GFF_TO_BED */

process EXTRACT_MIRNA_SEED {
	tag "$BED"

	publishDir "${results_dir}/extract-miRNA-seed/",mode:"copy"

	input:
	file BED
	file R_script_1

	output:
	file "*.seed.bed"

	shell:
	"""
	Rscript --vanilla ${R_script_1} ${BED} ${BED.baseName}.seed.bed
	"""
	stub:
	"""
	      touch ${BED.baseName}.seed.bed
	"""
}
