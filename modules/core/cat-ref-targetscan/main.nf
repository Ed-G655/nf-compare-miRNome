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


process CAT_TARGETSCAN_REF {
	tag "$TSOUT"

	publishDir "${results_dir}/run-targetscan/",mode:"copy"

	input:
	file TSOUT

	output:
	file "all_ref_targets.tsv"

	shell:
  """
	tail -n +2 ${TSOUT} > ${TSOUT}.tmp && mv ${TSOUT}.tmp ${TSOUT} \
 | echo "a_Gene_ID\tmiRNA_family_ID\tspecies_ID\tMSA_start\tMSA_end\tUTR_start\tUTR_end\tGroup_num\tSite_type\tmiRNA in this species\tGroup_type\tSpecies_in_this_group\tSpecies_in_this_group_with_this_site_type\tORF_overlap" > header.txt \
 && cat header.txt *.tsout > all_ref_targets.tsv

	"""
	stub:
	"""
	     touch all_ref_targets.tsv
	"""
}
