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

process VCF_CONSENSUS_SEQ {
	tag "$VCF, $FASTA"

	publishDir "${intermediates_dir}/vcf-consensus-seq/",mode:"symlink"

	input:
	tuple val(vcf_chr), file(FASTA), file(VCF)

	output:
	file "*.alt.fa"

  shell:
	"""
  	bcftools index -f -c !{VCF}
		cat !{FASTA} | bcftools consensus !{VCF} > !{FASTA.baseName}.alt.fa
  """

  stub:
	"""
	      touch ${FASTA}.alt.fa
	"""
}
