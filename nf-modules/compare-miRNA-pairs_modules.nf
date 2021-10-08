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
_pre1_1_split_chromosomes
_pre1_2_make_consensus_sequence

_1_1A_extract_mirna_FASTA_ref
_1_2A_extract_utr_FASTA_ref
_1_1B_extract_mirna_FASTA_mut
_1_2B_extract_utr_FASTA_mut

_1_1A_merge_mirref_fastas
_1_2A_merge_utrref_fastas
_1_1B_merge_mirmut_fastas
_1_2B_merge_utrmut_fastas

_2_A_pre1_run_miRmap
_2_A_pre2_make_mirmap_ids
_2_B_pre1_convert_mirna_data_to_targetscan
_2_B_pre2_convert_utr_data_to_targetscan
_2_B_pre3_run_targetscan
_2_B_pre_4_make_targetscan_ids

Core-processing:
_2_1_compare_targets_venndiagram


Pos-processing:

Analysis:
///////////////////////////////////////////////////////////////

  Define pipeline Name
  This will be used as a name to include in the results and intermediates directory names
*/

pipeline_name = "compare-miRNA-pairs_modules"

/*This directories will be automatically created by the pipeline to store files during the run
*/
results_dir = "${params.output_dir}/${pipeline_name}-results/"
intermediates_dir = "${params.output_dir}/${pipeline_name}-intermediate/"

/*================================================================/*

/* MODULE START */

/*Compare miRNAs //////////////////////////////////////////////////////////////

/* Run_miRmap */

process Run_miRmap {

	publishDir "${results_dir}/Run_miRmap/",mode:"copy"

	input:
	file mirnas
	file utrs
	file mk_files

	output:
	file "*.mirmapout"

	"""
	bash runmk.sh
	"""

}

/* Process _Core2_make_mirmap_ids */
process Make_mirmap_ids {

  publishDir"${intermediates_dir}/Make_mirmap_ids/", mode:"symlink"

  input:
	file mirmapout
	file mk_files
  output:
  file "*.mirmapid"
	"""
	bash runmk.sh
	"""
}

/* Convert_mirna_data_to_targetscan  */
process Convert_mirna_data_to_targetscan {

	publishDir "${intermediates_dir}/Convert_mirna_data_to_targetscan/",mode:"symlink"

	input:
	file mirnas
	file mk_files

	output:
	file "*.mirna.txt"
	"""
	bash runmk.sh
	"""
}

/*  Process _Convert_utr_data_to_targetscan */
process Convert_utr_data_to_targetscan {
  publishDir "${intermediates_dir}/_pre2_convert_utr_data_to_targetscan/", mode: "symlink"

  input:
	file utrs
  file mk_files

  output:
  file "*.utr.txt"
  """
  bash runmk.sh
  """
}

/* Process Run_targetscan */
process Run_targetscan {

  publishDir"${results_dir}/Run_targetscan/", mode:"copy"

  input:
  file mirna_txt
  file utr_txt
  file mk_files

  output:
  file "*.tsout"

	"""
	bash runmk.sh
	"""
}
/* Process Make_targetscan_ids */
process Make_targetscan_ids {

  publishDir"${intermediates_dir}/make_targetscan_ids/", mode:"symlink"

  input:
	file tsout
	file mk_files

  output:
  file "*.tsid"

	"""
	bash runmk.sh
	"""
}

/* Process Compare_targets */
process Compare_targets {

  publishDir"${results_dir}/compare_targets/", mode:"copy"

  input:
	file mirmapid
	file tsid 
	file mk_files

  output:
  file "*targets*"

	"""
	bash runmk.sh
	"""
}
