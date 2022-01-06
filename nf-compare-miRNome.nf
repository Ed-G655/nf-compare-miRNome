#!/usr/bin/env nextflow

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
_pre3_extract_mirna_FASTA_ref
_pre4_extract_utr_FASTA_ref
_pre5_extract_utr_FASTA_ref
_pre6_extract_mirna_FASTA_mut
_pre7_extract_utr_FASTA_mut
_pre9_merge_utrref_fastas
_pre11_merge_utrmut_fastas

Core-processing:
CORE_1_REF_tun_mirmap
CORE_1_MUT_tun_mirmap
CORE_2A_Make_mirmap_ids
CORE_2B_Make_mirmap_ids
CORE_3A_Convert_mirna_data_to_targetscan
CORE_3B_Convert_mirna_data_to_targetscan
CORE_4A_Convert_utr_data_to_targetscan
CORE_4B_Convert_utr_data_to_targetscan
CORE_5A_Run_targetscan_REF
CORE_5B_Run_targetscan_MUT
Core_6A_Make_targetscan_IDs_REF
Core_6B_Make_targetscan_IDs_MUT
Core 7_Compare_targets_REF
Core 8_Compare_targets_MUT

Pos-processing:
Pos_1_miRNome_changes
Pos_2_convert_target_file
Pos_3_butterfly-plot-target-changes
Pos_4_plot_target_changes_count

Analysis:

================================================================*/

/* Define the help message as a function to call when needed *//////////////////////////////
def helpMessage() {
	log.info"""
  ==========================================
	The miRNome compare pipeline
  v${version}
  ==========================================

	Usage:

	nextflow run ${pipeline_name}.nf --mirnabed <path to input 1> --utrbed <path to input 2>
  --vcf <path to input 3> --fasta <path to input 4>   [--output_dir path to results ]

	  --mirnabed	<- miRNA bed file;

	  --utrbed	<- UTR bed file;

    --vcf <- VCF file;

    --fasta_dir <- Directory whith the FASTA files;

	  --output_dir     <- directory where results, intermediate and log files will be stored;
	      default: same dir where --query_fasta resides

	  -resume	   <- Use cached results if the executed project has been run before;
	      default: not activated
	      This native NF option checks if anything has changed from a previous pipeline execution.
	      Then, it resumes the run from the last successful stage.
	      i.e. If for some reason your previous run got interrupted,
	      running the -resume option will take it from the last successful pipeline stage
	      instead of starting over
	      Read more here: https://www.nextflow.io/docs/latest/getstarted.html#getstart-resume
	  --help           <- Shows Pipeline Information
	  --version        <- Show version
	""".stripIndent()
}

/*//////////////////////////////
  Define pipeline version
  If you bump the number, remember to bump it in the header description at the begining of this script too
*/
version = "0.1"

/*//////////////////////////////
  Define pipeline Name
  This will be used as a name to include in the results and intermediates directory names
*/
pipeline_name = "nf-compare-miRNome.nf"

/*
  Initiate default values for parameters
  to avoid "WARN: Access to undefined parameter" messages
*/
params.mirnabed = false  //if no inputh path is provided, value is false to provoke the error during the parameter validation block
params.utrbed = false  //if no inputh path is provided, value is false to provoke the error during the parameter validation block
params.vcf = false  //if no inputh path is provided, value is false to provoke the error during the parameter validation block
params.fasta_dir = false  //if no inputh path is provided, value is false to provoke the error during the parameter validation block
params.help = false //default is false to not trigger help message automatically at every run
params.version = false //default is false to not trigger version message automatically at every run

/*//////////////////////////////
  If the user inputs the --help flag
  print the help message and exit pipeline
*/
if (params.help){
	helpMessage()
	exit 0
}

/*//////////////////////////////
  If the user inputs the --version flag
  print the pipeline version
*/
if (params.version){
	println "${pipeline_name} v${version}"
	exit 0
}

/*//////////////////////////////
  Define the Nextflow version under which this pipeline was developed or successfuly tested
  Updated by iaguilar at MAY 2021
*/
nextflow_required_version = '20.01.0'
/*
  Try Catch to verify compatible Nextflow version
  If user Nextflow version is lower than the required version pipeline will continue
  but a message is printed to tell the user maybe it's a good idea to update her/his Nextflow
*/
try {
	if( ! nextflow.version.matches(">= $nextflow_required_version") ){
		throw GroovyException('Your Nextflow version is older than Pipeline required version')
	}
} catch (all) {
	log.error "-----\n" +
			"  This pipeline requires Nextflow version: $nextflow_required_version \n" +
      "  But you are running version: $workflow.nextflow.version \n" +
			"  The pipeline will continue but some things may not work as intended\n" +
			"  You may want to run `nextflow self-update` to update Nextflow\n" +
			"============================================================"
}

/*//////////////////////////////
  INPUT PARAMETER VALIDATION BLOCK
*/

/* Check if the input directory is provided
    if it was not provided, it keeps the 'false' value assigned in the parameter initiation block above
    and this test fails
*/
if ( !params.mirnabed | !params.utrbed | !params.vcf | !params.fasta_dir ) {
  log.error " Please provide the --mirnabed AND --utrbed AND --vcf --fasta \n\n" +
  " For more information, execute: nextflow run extract-sequences.nf --help"
  exit 1
}

/*
Output directory definition
Default value to create directory is the parent dir of --input_dir
*/
params.output_dir = file(params.mirnabed).getParent() //!! maybe creates bug, should check

/*
  Results and Intermediate directory definition
  They are always relative to the base Output Directory
  and they always include the pipeline name in the variable pipeline_name defined by this Script

  This directories will be automatically created by the pipeline to store files during the run
*/
results_dir = "${params.output_dir}/${pipeline_name}-results/"
intermediates_dir = "${params.output_dir}/${pipeline_name}-intermediate/"

/*
Useful functions definition
*/

/*//////////////////////////////
  LOG RUN INFORMATION
*/
log.info"""
==========================================
The nf-miRNome-compare pipeline
v${version}
==========================================
"""
log.info "--Nextflow metadata--"
/* define function to store nextflow metadata summary info */
def nfsummary = [:]
/* log parameter values beign used into summary */
/* For the following runtime metadata origins, see https://www.nextflow.io/docs/latest/metadata.html */
nfsummary['Resumed run?'] = workflow.resume
nfsummary['Run Name']			= workflow.runName
nfsummary['Current user']		= workflow.userName
/* string transform the time and date of run start; remove : chars and replace spaces by underscores */
nfsummary['Start time']			= workflow.start.toString().replace(":", "").replace(" ", "_")
nfsummary['Script dir']		 = workflow.projectDir
nfsummary['Working dir']		 = workflow.workDir
nfsummary['Current dir']		= workflow.launchDir
nfsummary['Launch command'] = workflow.commandLine
log.info nfsummary.collect { k,v -> "${k.padRight(15)}: $v" }.join("\n")
log.info "\n\n--Pipeline Parameters--"
/* define function to store nextflow metadata summary info */
def pipelinesummary = [:]
/* log parameter values beign used into summary */
pipelinesummary['Input miRNA bed']			= params.mirnabed
pipelinesummary['Input 3UTR bed']			= params.utrbed
pipelinesummary['Input VCF']			= params.vcf
pipelinesummary['Input FASTA Dir']			= params.fasta_dir
pipelinesummary['Results Dir']		= results_dir
pipelinesummary['Intermediate Dir']		= intermediates_dir
/* print stored summary info */
log.info pipelinesummary.collect { k,v -> "${k.padRight(15)}: $v" }.join("\n")
log.info "==========================================\nPipeline Start"

/*//////////////////////////////
  PIPELINE START
*/

/* enable DSL2*/
nextflow.enable.dsl=2

/*
	READ GENERAL INPUTS
*/

/* _pre1_split_chromosomes */
/* Load VCF file into channel */
Channel
	.fromPath( "${params.vcf}" )
	.set{ vcf_input }

/* Process _pre2_make_consensus_sequence
/* Load FASTA files into channel */
Channel
	.fromPath( "${params.fasta_dir}*.fa" )
	.toList()
	.set{ fasta_input }

/* Process _001A_extract_mirna_FASTA_ref */
/* Load mirna bed file into channel */
Channel
.fromPath( "${params.mirnabed}" )
.set{ mirnabed_input}

/*_002A_extract_utr_FASTA_ref
/* Load utr bed file into channel */
Channel
.fromPath( "${params.utrbed}" )
.set{ utrbed_input}


/*
	READ mk-files
*/

/* _pre1_split_chromosomes */
/* Read mkfile module files */
Channel
	.fromPath("${workflow.projectDir}/mkmodules/1_extract_FASTAs/mk-split-chromosomes/*")
	.toList()
	.set{ mk_files }

/* Process _pre2_make_consensus_sequence
/* Read mkfile module files */
Channel
	.fromPath("${workflow.projectDir}/mkmodules/1_extract_FASTAs/make-consensus-sequence/*")
	.toList()
	.set { mkfiles_pre2 }

/* Process _001A_extract_mirna_FASTA_ref */
/* Read mkfile module files */
Channel
	.fromPath("${workflow.projectDir}/mkmodules/1_extract_FASTAs/mk-extract-mirna-FASTA-reference/*")
	.toList()
	.set{ mkfiles_001A }

/*_001B_extract_mirna_FASTA_mut
/* Read mkfile module files */
Channel
	.fromPath("${workflow.projectDir}/mkmodules/1_extract_FASTAs/mk-extract-mirna-FASTA-consensus/*")
	.toList()
	.set{ mkfiles_001B }

/*_002A_extract_utr_FASTA_ref
/* Read mkfile module files */
Channel
	.fromPath("${workflow.projectDir}/mkmodules/1_extract_FASTAs/mk-extract-utr-FASTA-reference/*")
	.toList()
	.set{ mkfiles_002A }

/*_002B_extract_utr_FASTA_mut
/* Read mkfile module files */
Channel
	.fromPath("${workflow.projectDir}/mkmodules/1_extract_FASTAs/mk-extract-utr-FASTA-consensus/*")
	.toList()
	.set{ mkfiles_002B }

	/*//////// Compare miRNAs inputs ////////////*

/*	Run_miRmap	*/
/* Read mkfile module files */
Channel
	.fromPath("${workflow.projectDir}/mkmodules/2_compare-miRNA-pairs/mk-run-miRmap/*")
	.toList()
	.set{ mkfiles_core_1 }

/* Process _Core2_make_mirmap_ids */
/* Read mkfile module files */
Channel
		.fromPath("${workflow.projectDir}/mkmodules/2_compare-miRNA-pairs/mk-make-mirmap-ids/*")
		.toList()
		.set { mkfiles_core_2 }

/* Convert_mirna_data_to_targetscan
/* Read mkfile module files */
Channel
		.fromPath("${workflow.projectDir}/mkmodules/2_compare-miRNA-pairs/mk-convert-mirna-data-to-targetscan/*")
		.toList()
		.set{ mkfiles_core_3 }

/*  Process _Convert_utr_data_to_targetscan */
/* Read mkfile module files */
Channel
		 .fromPath("${workflow.projectDir}/mkmodules/2_compare-miRNA-pairs/mk-convert-utr-data-to-targetscan/*")
		 .toList()
		 .set{ mkfiles_core_4 }

/* Process Run_targetscan */
/* Read mkfile module files */
Channel
		  .fromPath("${workflow.projectDir}/mkmodules/2_compare-miRNA-pairs/mk-run-targetscan/*")
		 	.toList()
		 	.set { mkfiles_core_5 }

/* Process _B_pre_4_make_targetscan_ids */
/* Read mkfile module files */
Channel
			.fromPath("${workflow.projectDir}/mkmodules/2_compare-miRNA-pairs/mk-make-targetscan-ids/*")
			.toList()
			.set { mkfiles_core_6}

/* Process _Ccompare_mirna_targets */
/* Read mkfile module files */
Channel
			.fromPath("${workflow.projectDir}/mkmodules/2_compare-miRNA-pairs/mk-compare-ref-targets-venndiagram/*")
			.toList()
			.set { mkfiles_core_7 }

/* Process _Ccompare_mirna_targets */
/* Read mkfile module files */
Channel
	.fromPath("${workflow.projectDir}/mkmodules/2_compare-miRNA-pairs/mk-compare-mut-targets-venndiagram/*")
	.toList()
	.set { mkfiles_core_8 }

/* Pos_compare_mirnatargets */
/* Read mkfile module files */
Channel
	.fromPath("${workflow.projectDir}/mkmodules/3_analyze-miRNome/mk-compare-mirnatargets/*")
	.toList()
	.set{ mkfiles_pos1 }
/* _pos2_convert_target_file */
	/* Read mkfile module files */
Channel
	.fromPath("${workflow.projectDir}/mkmodules/3_analyze-miRNome/mk-convert-target-file/*")
	.toList()
	.set{ mkfiles_pos2}
	/* 001_butterfly-plot-target-changes */
	/* Read mkfile module files */
	Channel
		.fromPath("${workflow.projectDir}/mkmodules/3_analyze-miRNome/mk-butterfly-plot-target-changes/*")
		.toList()
		.set{mkfiles_pos3}

/* plot-target-changes */
/* Read mkfile module files */
Channel
	.fromPath("${workflow.projectDir}/mkmodules/3_analyze-miRNome/mk-plot-target-changes-count/*")
	.toList()
	.set{mkfiles_pos4}


/*	 * Import modules */
include {  _pre1_split_chromosomes;
					_pre2_make_consensus_sequence;
					_001A_extract_mirna_FASTA_ref;
					_001B_extract_mirna_FASTA_mut;
					_002A_extract_utr_FASTA_ref;
					_002B_extract_utr_FASTA_mut;
					_02A_merge_utrref_fastas;
					_02B_merge_utrmut_fastas
					} from './nf-modules/extract-sequences_modules.nf'


include { Run_miRmap;
	 				Run_miRmap as Run_miRmap_AGAIN;
					Make_mirmap_ids;
					Make_mirmap_ids as Make_mirmap_ids_AGAIN;
					Convert_mirna_data_to_targetscan;
					Convert_mirna_data_to_targetscan as Convert_mirna_data_to_targetscan_AGAIN;
					Convert_utr_data_to_targetscan;
					Convert_utr_data_to_targetscan as Convert_utr_data_to_targetscan_AGAIN;
					Run_targetscan;
					Run_targetscan as Run_targetscan_AGAIN;
					Make_targetscan_ids;
					Make_targetscan_ids as Make_targetscan_ids_AGAIN;
					Compare_ref_targets;
					Compare_mut_targets } from './nf-modules/compare-miRNA-pairs_modules.nf'


include { miRNome_changes;
	pos2_convert_target_file;
	pos3_butterfly_plot_target_changes;
	pos4_plot_target_changes_count } from './nf-modules/plot-microRNA-targets_modules.nf'

/*  main pipeline logic */
workflow  {
						// PRE 1: Split VCF file
						_pre1_split_chromosomes(
																		vcf_input,
																		mk_files)
						// PŔE 2: Make consensus FASTA sequence
						_pre2_make_consensus_sequence(
																					_pre1_split_chromosomes.out,
																					fasta_input,
																					mkfiles_pre2)
						// COre 1A: Extract miRNA FASTA reference sequences
						_001A_extract_mirna_FASTA_ref(
																					fasta_input,
																					mirnabed_input,
																					mkfiles_001A)
						// Core 1B: Extract miRNA FASTA mutate sequences
						_001B_extract_mirna_FASTA_mut(
																					_pre2_make_consensus_sequence.out,
																					mirnabed_input,
																					mkfiles_001B)
						// Core 2A: Extract UTR FASTA reference sequences
						_002A_extract_utr_FASTA_ref(
																				fasta_input,
																				utrbed_input,
																				mkfiles_002A)
						// Core 2B: Extract UTR FASTA mutate sequences
						_002B_extract_utr_FASTA_mut(
																				_pre2_make_consensus_sequence.out,
																				utrbed_input,
																				mkfiles_002B)
						// Pos 2A: Merge UTR reference FASTAs
						_02A_merge_utrref_fastas(_002A_extract_utr_FASTA_ref.out)
						// POs 2B: Merge UTR mutate FASTAs
						_02B_merge_utrmut_fastas(_002B_extract_utr_FASTA_mut.out)
						// CORE_REF: Run mirmap with reference sequences
						Run_miRmap(	_001A_extract_mirna_FASTA_ref.out,
												_02A_merge_utrref_fastas.out,
												mkfiles_core_1)
						// CORE_MUT: Run mirmap with mutate sequences
						Run_miRmap_AGAIN(	_001B_extract_mirna_FASTA_mut.out,
															_02B_merge_utrmut_fastas.out,
															mkfiles_core_1)
						// CORE_2A: Make mirmap ids REF sequences
						Make_mirmap_ids(Run_miRmap.out,
														mkfiles_core_2)
						// CORE_2B: Make mirmap ids MUT sequences
						Make_mirmap_ids_AGAIN(Run_miRmap_AGAIN.out,
																	mkfiles_core_2)
						// CORE_3A: Convert_mirna_data_to_targetscan
						Convert_mirna_data_to_targetscan(	_001A_extract_mirna_FASTA_ref.out,
																							mkfiles_core_3)
						// CORE_3A: Convert_mirna_data_to_targetscan
						Convert_mirna_data_to_targetscan_AGAIN(	_001B_extract_mirna_FASTA_mut.out,
																										mkfiles_core_3)
						// CORE_4A: Convert_utr_data_to_targetscan REF
						Convert_utr_data_to_targetscan(_02A_merge_utrref_fastas.out,
																						mkfiles_core_4)
						// CORE_4b: Convert_utr_data_to_targetscan mut
						Convert_utr_data_to_targetscan_AGAIN(	_02B_merge_utrmut_fastas.out,
																									mkfiles_core_4)
						// CORE_5A: Run_targetscan REF
						Run_targetscan(	Convert_mirna_data_to_targetscan.out,
														Convert_utr_data_to_targetscan.out,
														mkfiles_core_5)
						// CORE_5B: Run_targetscan mut
						Run_targetscan_AGAIN(	Convert_mirna_data_to_targetscan_AGAIN.out,
														Convert_utr_data_to_targetscan_AGAIN.out,
														mkfiles_core_5)
						// Core 6A: Make targetscan IDs  REF
						Make_targetscan_ids(	Run_targetscan.out,
																	mkfiles_core_6)
						// Core 6B: Make targetscan IDs  MUT
						Make_targetscan_ids_AGAIN(	Run_targetscan_AGAIN.out,
																				mkfiles_core_6)
						// Core 7: Compare_targets REF
						REF_targets = Compare_ref_targets(	Make_mirmap_ids.out,
															Make_targetscan_ids.out,
															mkfiles_core_7)
						// Core 7: Compare_targets REF
						MUT_targets = Compare_mut_targets(	Make_mirmap_ids_AGAIN.out,
															Make_targetscan_ids_AGAIN.out,
															mkfiles_core_8)
						// Pos 1: miRNome_changes
						miRNome_changes(REF_targets, MUT_targets, mkfiles_pos1)
						// Pos 2: Convert
						pos2_convert_target_file(miRNome_changes.out.changes_file, mkfiles_pos2)
						// Pos 3:001_butterfly-plot-target-changes
						pos3_butterfly_plot_target_changes(pos2_convert_target_file.out,mkfiles_pos3)
						// Pos 4:pos4_plot_target_changes_count
						pos4_plot_target_changes_count(pos2_convert_target_file.out,mkfiles_pos4)

}
