#!/usr/bin/env nextflow
/*================================================================

								---- MODULE PIPELINE ---------

/*================================================================
The Aguilar Lab presents...

- A pipeline to extract and create miRNA and 3'UTR consensus sequences for analysis
   with targetscan and miRmap.

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


process CAT_TARGETSCAN_ALT {
	tag "$TSOUT"

	publishDir "${results_dir}/run-targetscan/",mode:"copy"

	input:
	file TSOUT

	output:
	file "all_alt_targets.tsv"

	shell:
  """
	tail -n +2 ${TSOUT} | cut -f cut -f 1,2,6,7,9 > ${TSOUT}.tmp \
 	cat *.tmp  > All.tsout

	"""

	stub:
	"""
	     touch all_alt_targets.tsv
	"""
}
