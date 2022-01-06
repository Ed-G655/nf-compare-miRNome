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

pipeline_name = "nf-extract-sequences"

/*This directories will be automatically created by the pipeline to store files during the run
*/
results_dir = "${params.output_dir}/${pipeline_name}-results/"
intermediates_dir = "${params.output_dir}/${pipeline_name}-intermediate/"

/*================================================================/*

/* MODULE START */
/* _pre1_split_chromosomes */

process _pre1_split_chromosomes {
	tag "Split ${params.vcf}"
	publishDir "${intermediates_dir}/_pre1_split_chromosomes/", mode:"symlink"

	input:
	file vcf
	file mk_files

	output:
	file "*.vcf.gz"

	"""
	bash runmk.sh
	"""
}

/* Process _pre2_make_consensus_sequence */

process _pre2_make_consensus_sequence {

  publishDir"${intermediates_dir}/_pre2_make_consensus_sequence/", mode:"symlink"

  input:
	file chunk_vcf
	file fasta
	file mk_files

  output:
  file "*.fa.consensus"
	"""
	bash runmk.sh
	"""
}

/*_001A_extract_mirna_FASTA_ref */

process _001A_extract_mirna_FASTA_ref {

	publishDir "${intermediates_dir}/_001A_extract_mirna_FASTA_ref/",mode:"symlink"

	input:
	file mirnabed
	file fasta
	file mk_files
	output:
	file "*.mirna.fa"

	"""
	bash runmk.sh
	"""
}


/*_001B_extract_mirna_FASTA_mut */

process _001B_extract_mirna_FASTA_mut {

	publishDir "${intermediates_dir}/_001B_extract_mirna_FASTA_mut/",mode:"symlink"

	input:
	file mirnabed
	file fasta_consensus
	file mk_files
	output:
	file "*.mirna.fa"

	"""
	bash runmk.sh
	"""
}

/*_002A_extract_utr_FASTA_ref  */

process _002A_extract_utr_FASTA_ref {

	publishDir "${intermediates_dir}/_002A_extract_utr_FASTA_ref/",mode:"symlink"

	input:
	file utrbed
	file fasta
	file mk_files
	output:
	file "*.utrref"

	"""
	bash runmk.sh
	"""
}


/*_002B_extract_utr_FASTA_mut */

process _002B_extract_utr_FASTA_mut {

	publishDir "${intermediates_dir}/_002B_extract_utr_FASTA_mut/",mode:"symlink"

	input:
	file utrbed
	file fasta
	file mk_files
	output:
	file "*.utrmut"

	"""
	bash runmk.sh
	"""
}

/*_02A_merge_utrref_fastas */

process _02A_merge_utrref_fastas {

	publishDir "${results_dir}/utrref_fastas/",mode:"copy"

	input:
	file utr_FASTAs
	output:
	file "*.utr.fa"
	"""
 cat *.utrref | grep . > all_ref.utr.fa
	"""
}

 /*_02B_merge_utrmut_fastas */

process _02B_merge_utrmut_fastas {

	publishDir "${results_dir}/utrmut_fastas/",mode:"copy"

	input:
	file utr_FASTAs

	output:
	file "*.utr.fa"

	"""
 cat *.utrmut | grep . > all_mut.utr.fa
	"""
}
