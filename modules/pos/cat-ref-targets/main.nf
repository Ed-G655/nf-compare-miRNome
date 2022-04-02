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

/* PRE1_CONVERT_GFF_TO_BED */

process CAT_REF_TARGETS {
	tag "$TSOUT.baseName"

	publishDir "${intermediates_dir}/cat-targets/",mode:"symlink"

	input:
	file TSOUT
	file MIRMAP
	file BED
  file Rscript

	output:
	path "targets.ref.tsv", emit: tsv
	file "targets.ref.png"

	shell:
	"""
  Rscript --vanilla cat_targets.r ${BED} targets.ref

	"""
	stub:
	"""
	      touch  targets.ref.tsv
				touch  targets.ref.png
	"""
}
