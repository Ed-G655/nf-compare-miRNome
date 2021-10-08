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

/* Load  miRNA reference targets file into channel*/
Channel
	.fromPath( "${params.targets_ref}" )
	// .view()
	.set{ targets_ref_input }

/* Load miRNA mutate targets file into channel */
Channel
	.fromPath( "${params.targets_mut}" )
	// .view()
	.set{ targets_mut_input }

/* _pre1_compare_mirnatargets */
/* Read mkfile module files */
Channel
	.fromPath("${workflow.projectDir}/mk-modules/mk-compare-mirnatargets/*")
	.toList()
	.set{ mkfiles_pre1 }

process _pre1_compare_mirnatargets {

	publishDir "${results_dir}/_pre1_compare_mirnatargets/",mode:"copy"

	input:
	file ref_targets from targets_ref_input
	file mut_targets from targets_mut_input
	file mk_files from mkfiles_pre1

	output:
	file "*.changes" into results_pre1_compare_mirnatargets
	file "*.png" into results_pre1_compare_mirnatargets_png
	"""
	bash runmk.sh
	"""

}


/* _pre2_convert-target-file */
/* Read mkfile module files */
Channel
	.fromPath("${workflow.projectDir}/mk-modules/mk-convert-target-file/*")
	.toList()
	.set{ mkfiles_pre2 }

process _pre2_convert_target_file {

	publishDir "${results_dir}/_pre2_convert_target_file/",mode:"copy"

	input:
	file changes from results_pre1_compare_mirnatargets
	file mk_files from mkfiles_pre2

	output:
	file "*.changes.tsv" into results_A_pre2_convert_target_file, results_B_pre2_convert_target_file

	"""
	bash runmk.sh
	"""

}

/* 001_butterfly-plot-target-changes */
/* Read mkfile module files */
Channel
	.fromPath("${workflow.projectDir}/mk-modules/mk-butterfly-plot-target-changes/*")
	.toList()
	.set{mkfiles_core1}


process _001_butterfly_plot_target_changes {

	publishDir "${results_dir}/001_butterfly_plot_target_changes/",mode:"copy"

	input:
	file changes_tsv from results_A_pre2_convert_target_file
	file mk_files from mkfiles_core1

	output:
	file "*.png" into results_001_butterfly_plot_target_changes

	"""
	bash runmk.sh
	"""

}

/* 001_butterfly-plot-target-changes */
/* Read mkfile module files */
Channel
	.fromPath("${workflow.projectDir}/mk-modules/mk-plot-target-changes-count/*")
	.toList()
	.set{mkfiles_core2}


process _002_plot_target_changes_count {

	publishDir "${results_dir}/_002_plot-target-changes-count/",mode:"copy"

	input:
	file changes_tsv from results_B_pre2_convert_target_file
	file mk_files from mkfiles_core2

	output:
	file "*.png" into results_002_plot_target_changes_count

	"""
	bash runmk.sh
	"""

}
