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

pipeline_name = "nf-compare-miRNome.nf"

/*This directories will be automatically created by the pipeline to store files during the run
*/
results_dir = "${params.output_dir}/${pipeline_name}-results/"
intermediates_dir = "${params.output_dir}/${pipeline_name}-intermediate/"

/*================================================================/*

/* MODULE START */

/* PRE1_CONVERT_GFF_TO_BED */

process CONVERT_GFF_TO_BED {
	tag "$GFF"

	publishDir "${intermediates_dir}/PRE1-CONVERT-GFF-TO-BED /",mode:"symlink"

	input:
	file GFF

	output:
	file "*.bed"

	shell:
	"""
	gff2bed < !{GFF} > !{GFF.baseName}.tmp
	less -S !{GFF.baseName}.tmp \
	| tr ";" "\t" \
	| sed -r 's/Name=//g' \
	| awk '{print \$1"\t"\$2"\t"\$3"\t"\$12"\t"\$5"\t"\$6"\t"\$7"\t"\$8}' > !{GFF.baseName}.bed
	rm *.tmp
	"""
	stub:
	"""
	      touch ${GFF.baseName}.bed
	"""
}
