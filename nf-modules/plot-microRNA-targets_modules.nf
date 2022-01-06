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


=============================
Pipeline Processes In Brief:

Pre-processing:
_pre1_split_chromosomes
_pre2_make_consensus_sequence

Core-processing:
_001A_extract_mirna_FASTA_ref
_002A_extract_utr_FASTA_ref
_001B_extract_mirna_FASTA_mut
_002B_extract_utr_FASTA_mut

Pos-processing:
_01A_merge_mirref_fastas
_02A_merge_utrref_fastas
_01B_merge_mirmut_fastas
_02B_merge_utrmut_fastas

Analysis:


///////////////////////////////////////////////////////////////

  Define pipeline Name
  This will be used as a name to include in the results and intermediates directory names
*/

pipeline_name = "nf-analize-miRNome"

/*This directories will be automatically created by the pipeline to store files during the run
*/
results_dir = "${params.output_dir}/${pipeline_name}-results/"
intermediates_dir = "${params.output_dir}/${pipeline_name}-intermediate/"

/*================================================================/*

/* MODULE START */
/* miRNome_changes */
process miRNome_changes {

	publishDir "${results_dir}/miRNome_changes/",mode:"copy"

	input:
	file ref_targets
	file mut_targets
	file mk_files

	output:
	path '*.changes', emit: changes_file
	file "*.png"

	"""
	bash runmk.sh
	"""

}


/* _pos2_convert_target_file */
process pos2_convert_target_file {

	publishDir "${results_dir}/pos2_convert_target_file/",mode:"copy"

	input:
	file changes
	file mk_files

	output:
	file "*.changes.tsv"
	"""
	bash runmk.sh
	"""

}

/* 001_butterfly-plot-target-changes */
process pos3_butterfly_plot_target_changes {
	errorStrategy 'ignore'

	publishDir "${results_dir}/pos3_butterfly_plot_target_changes/",mode:"copy"

	input:
	file changes_tsv
	file mk_files

	output:
	file "*.png"

	"""
	bash runmk.sh
	"""

}

/* plot-target-changes */

process pos4_plot_target_changes_count {
	errorStrategy 'ignore'

	publishDir "${results_dir}/pos4_plot_target_changes_count/",mode:"copy"

	input:
	file changes_tsv
	file mk_files

	output:
	file "*.png"

	"""
	bash runmk.sh
	"""

}
