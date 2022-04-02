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

process EXTRACT_MIRNA_FASTA {
	tag "$BED, $FASTA.baseName"

	publishDir "${intermediates_dir}/extract-fasta/",mode:"copy"

	input:
	file BED
	each FASTA

	output:
	path "*.mirna"

	shell:
	"""

	echo "[DEBUG] Extracting ${FASTA} into ${FASTA.baseName}.mirna"
	bedtools getfasta -fi ${FASTA} -bed ${BED} -name -s -fo ${FASTA.baseName}.tmp
	echo "[DEBUG] Change DNA to RNA"
	less -s ${FASTA.baseName}.tmp | perl -pe 'tr/T/U/ unless(/>/)' > ${FASTA.baseName}.mirna

	"""
	stub:
	"""
	      touch ${FASTA.baseName}.mirna
	"""
}
