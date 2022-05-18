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

Pre-processing:
PRE1-CONVERT_GFF_TO_BED
PRE2-EXTRACT_MIRNA_SEED
PRE3-Grep maturer microRNAs
PRE4-INTERSECT_BED_VCF
PRE5-EXTRACT_BIALLELIC_SNPs
PRE6-SPLIT_VCF
PRE7-VCF_CONSENSUS_SEQ
PRE8-EXTRACT_FASTA
PRE9-CONVERT_miRNA_TO_TARGETSCAN
PRE10-CONVERT_UTR_TO_TARGETSCAN
PRE11-CONVERT_UTR_TO_TARGETSCAN
PRE12-CLASSIFY_SNPs_BY_REGION

Core-processing:
CORE1-RUN_TARGETSCAN_REF
CORE2-RUN_TARGETSCAN_ALT
CORE3-RUN-MIRMAP REF
CORE4-RUN-MIRMAP ALT

Pos-processing
Pos1-COMPARE_TARGETS

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

	nextflow run ${pipeline_name}.nf --mirna_gff <path to input 1> --utrbed <path to input 2>
  --vcf <path to input 3> --fasta <path to input 4>   [--output_dir path to results ]

		--mirna_gff	<- miRNA gff file;

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
params.mirna_gff = false  //if no inputh path is provided, value is false to provoke the error during the parameter validation block
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
if ( !params.mirna_gff | !params.utrbed | !params.vcf | !params.fasta_dir ) {
  log.error " Please provide the --mirna_gff AND --utrbed AND --vcf --fasta \n\n" +
  " For more information, execute: nextflow run ${pipeline_name} --help"
  exit 1
}

/*
Output directory definition
Default value to create directory is the parent dir of --input_dir
*/
params.output_dir = file(params.mirna_gff).getParent() //!! maybe creates bug, should check

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
pipelinesummary['Input miRNA bed']			= params.mirna_gff
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

	/* Load GFF file into channel */

/* Process _001A_extract_mirna_FASTA_ref */
Channel
	.fromPath( "${params.mirna_gff}" )
	.set{ gff_input }

/* _pre1_split_chromosomes */
/* Load VCF file into channel */
Channel
	.fromPath( "${params.vcf}" )
	.set{ vcf_input }

/* Process _pre2_make_consensus_sequence
/* Load FASTA files into channel */
Channel
	.fromPath( "${params.fasta_dir}*.fa" )
	.set{ fasta_input }


/*_002A_extract_utr_FASTA_ref
/* Load utr bed file into channel */
Channel
.fromPath( "${params.utrbed}" )
.set{ utrbed_input}


/*
 Load R fileS
*/

/* R_script_1 */
Channel
	.fromPath( "./modules/pre/extract-mirna-seed/extract_mirna_seed.R" )
	.set{ R_script_1 }

/* R_script_2 */
Channel
	.fromPath( "./modules/pre/convert-miRNA-to-targetscan/convert_mirna_data_to_targetscan.R" )
	.set{ R_script_2 }

/* R_script_3*/
Channel
	.fromPath( "./modules/pre/convert-UTR-to-targetscan/convert_utr_data_to_targetscan.R" )
	.set{ R_script_3 }

/* R_script_4*/
Channel
	.fromPath( "./modules/pre/classify-snps-by-region/clasify_SNPs_by_region.R" )
	.set{ R_script_4 }


/* R_script_5*/
Channel
	.fromPath( "./modules/pos/compare-tools/compare_tools.r" )
	.set{ R_script_5}

	/* R_script_6*/
	Channel
		.fromPath( "./modules/pos/compare-targets/compare_targets.r" )
		.set{ R_script_6}

	/* Load TargetScan script */
Channel
	.fromPath( "./modules/core/run-targetscan/targetscan_70.pl" )
	.set{ TargetScan_script }

/* Load miRmap script */
Channel
	.fromPath( "./modules/core/run-mirmap/mirmap_script.py" )
	.set{ miRmap_script }

/* Load vcf_split.py script */
	Channel
		.fromPath( "./modules/pre/split-vcf/split_vcf.py" )
		.set{ split_vcf_script }

	/*	  Import modules */
											/* PRE-processing */
include {	CONVERT_GFF_TO_BED	} from './modules/pre/convert-gff-to-bed/main.nf'
include {	GREP_MATURE_MICRORNA	} from './modules/pre/grep-mature-mirnas/main.nf'
include {EXTRACT_BIALLELIC_SNPs} from './modules/pre/extract-biallelic-snps/main.nf'
include {	EXTRACT_MIRNA_SEED	} from './modules/pre/extract-mirna-seed/main.nf'
include {	INTERSECT_BED_VCF	} from './modules/pre/intersect-bed-vcf/main.nf'
include {	INTERSECT_BED_VCF as INTERSECT_SEED_BED_VCF	} from './modules/pre/intersect-bed-vcf/main.nf'
include {WRITE_SEED_VCF} from './modules/pre/write-seed-vcf/main.nf'
include {SPLIT_VCF} from './modules/pre/split-vcf/main.nf'
include {VCF_CONSENSUS_SEQ} from './modules/pre/vcf-consensus-seq/main.nf'
include{EXTRACT_MIRNA_FASTA} from './modules/pre/extract-mirna-fastas/main.nf'
include{EXTRACT_MIRNA_FASTA as EXTRACT_MIRNA_ALT_FASTA} from './modules/pre/extract-mirna-fastas/main.nf'
include{EXTRACT_UTR_FASTA} from './modules/pre/extract-utr-fastas/main.nf'
include{EXTRACT_UTR_FASTA as EXTRACT_UTR_ALT_FASTA} from './modules/pre/extract-utr-fastas/main.nf'
include{CONVERT_miRNA_TO_TARGETSCAN} from './modules/pre/convert-miRNA-to-targetscan/main.nf'
include{CONVERT_miRNA_TO_TARGETSCAN as CONVERT_miRNA_TO_TARGETSCAN_ALT} from './modules/pre/convert-miRNA-to-targetscan/main.nf'
include{CAT_UTRs} from './modules/pre/cat-utr-data/main.nf'
include{CAT_UTRs_ALT} from './modules/pre/cat-utr-alt-data/main.nf'
include{CONVERT_UTR_TO_TARGETSCAN} from './modules/pre/convert-UTR-to-targetscan/main.nf'
include{CONVERT_UTR_TO_TARGETSCAN as CONVERT_UTR_TO_TARGETSCAN_ALT} from './modules/pre/convert-UTR-to-targetscan/main.nf'
include{CLASSIFY_SNPs_BY_REGION} from './modules/pre/classify-snps-by-region/main.nf'

								/* CORE-processing */
include{RUN_TARGETSCAN} from './modules/core/run-targetscan/main.nf'
include{RUN_TARGETSCAN as  RUN_TARGETSCAN_ALT} from './modules/core/run-targetscan/main.nf'
//include{CAT_TARGETSCAN_REF} from './modules/core/cat-ref-targetscan/main.nf'
//include{CAT_TARGETSCAN_ALT} from './modules/core/cat-alt-targetscan/main.nf'
include{RUN_MIRMAP} from './modules/core/run-mirmap/main.nf'
include{RUN_MIRMAP as RUN_MIRMAP_ALT} from './modules/core/run-mirmap/main.nf'

								/*POS-processing */
include{CAT_TARGETSCAN as CAT_TARGETSCAN_REF} from './modules/pos/cat-targetscan/main.nf' addParams(output_name: 'All_targets_ref.tsout')
include{CAT_TARGETSCAN as CAT_TARGETSCAN_ALT} from './modules/pos/cat-targetscan/main.nf' addParams(output_name: 'All_targets_alt.tsout')
include{CAT_MIRMAP as CAT_MIRMAP_ALT} from './modules/pos/cat-mirmap/main.nf' addParams(output_name: 'All_targets_alt.mirmapout')
include{CAT_MIRMAP as CAT_MIRMAP_REF} from './modules/pos/cat-mirmap/main.nf' addParams(output_name: 'All_targets_ref.mirmapout')


include{COMPARE_TARGETS_TOOLS as COMPARE_TOOLS_REF} from './modules/pos/compare-tools/main.nf' addParams(output_name: 'All_targets.ref')
include{COMPARE_TARGETS_TOOLS as COMPARE_TOOLS_ALT} from './modules/pos/compare-tools/main.nf' addParams(output_name: 'All_targets.alt')

include{COMPARE_TARGETS} from './modules/pos/compare-targets/main.nf'



/*  main pipeline logic */
workflow  {
/* PRE-processing */
						// PRE 1: CONVERT_GFF_TO_BED
						CONVERT_GFF_TO_BED(gff_input)
						// PRE 2: extract miRNA  seed from BED file
						EXTRACT_MIRNA_SEED(CONVERT_GFF_TO_BED.out, R_script_1)
						// PRE 3: Grep maturer microRNAs
						GREP_MATURE_MICRORNA(CONVERT_GFF_TO_BED.out)
						// PRE 4: INTERSECT_BED_VCF intersect mature and primary miRNAs and VCF file
						MATURE_INTERSECT = INTERSECT_BED_VCF(CONVERT_GFF_TO_BED.out, vcf_input)
						// PRE 4: INTERSECT_BED_VCF intersect seed miRNAs and VCF file
						SEED_INTERSECT = INTERSECT_SEED_BED_VCF(EXTRACT_MIRNA_SEED.out, vcf_input)
						// PRE 5: EXTRACT_BIALLELIC_SNPs from VCF file
						EXTRACT_BIALLELIC_SNPs(vcf_input)
						// PRE 6: Split VCF per Chromosome
						SPLIT_VCF(EXTRACT_BIALLELIC_SNPs.out, split_vcf_script)

						// Define a function to get the chromosome of each vcf splited file
						def get_chrom_prefix = { file -> file.baseName.replaceAll(/.vcf/, "") }
						// Build VCF tuple
						GROUP_VCFs = SPLIT_VCF.out
													.flatten()
													.map{ file -> tuple(get_chrom_prefix(file) , file) }
						// Tuple FASTA files by chr
						GROUP_FASTAS = fasta_input.map{ file -> tuple(file.baseName , file) } // This line requires FASTAs to be named by chromosome
						// join VCFs
						GROUP_BY_CHR_VCF = GROUP_FASTAS.join(GROUP_VCFs)

						// PRE 7: Write consensus FASTA sequence from VCF variants
						VCF_CONSENSUS_SEQ(GROUP_BY_CHR_VCF)
						// PRE 8: Extract FASTA consensus (ALT) sequence
						MIRNA_ALT_FASTA = EXTRACT_MIRNA_ALT_FASTA(GREP_MATURE_MICRORNA.out, VCF_CONSENSUS_SEQ.out)
						UTR_ALT_FASTA = EXTRACT_UTR_ALT_FASTA(utrbed_input, VCF_CONSENSUS_SEQ.out)
						// PRE 8: Extract FASTA reference sequence
						MIRNA_REF_FASTA = EXTRACT_MIRNA_FASTA(GREP_MATURE_MICRORNA.out, fasta_input)
						UTR_REF_FASTA = EXTRACT_UTR_FASTA(utrbed_input, fasta_input)
						// PRE 9:Convert miRNA data to targetScan INPUT
						REF_MIRNA = CONVERT_miRNA_TO_TARGETSCAN(MIRNA_REF_FASTA, R_script_2)
						ALT_MIRNA = CONVERT_miRNA_TO_TARGETSCAN_ALT(MIRNA_ALT_FASTA, R_script_2)
						// PRE 10: CAT UTR FASTAS
						CAT_UTR_REF = CAT_UTRs(UTR_REF_FASTA.collect())
						CAT_UTR_ALT = CAT_UTRs_ALT(UTR_ALT_FASTA.collect())
						// PRE 11: Convert UTR data to TargetScan INPUT
						REF_UTR = CONVERT_UTR_TO_TARGETSCAN(CAT_UTR_REF, R_script_3)
						ALT_UTR = CONVERT_UTR_TO_TARGETSCAN_ALT(CAT_UTR_ALT, R_script_3)
						// PRE12-CLASSIFY_SNPs_BY_REGION
						CLASSIFY_SNPs_BY_REGION(MATURE_INTERSECT, SEED_INTERSECT, R_script_4)

/* CORE-processing */
						// CORE1-RUN_TARGETSCAN_REF
						TARGETSCAN_REF = RUN_TARGETSCAN(REF_MIRNA, REF_UTR, TargetScan_script)
						// CORE2-RUN_TARGETSCAN_ALT
						TARGETSCAN_ALT = RUN_TARGETSCAN_ALT(ALT_MIRNA, ALT_UTR, TargetScan_script)
						// CORE3-RUN-MIRMAP REF
						MIRMAP_REF = RUN_MIRMAP(MIRNA_REF_FASTA, CAT_UTR_REF, miRmap_script)
						// CORE4-RUN-MIRMAP ALT
						MIRMAP_ALT = RUN_MIRMAP_ALT(MIRNA_ALT_FASTA, CAT_UTR_ALT, miRmap_script)

/* pos-processing */
						// collect targets outputs
				//		T1 = TARGETSCAN_REF.collect()
				// 		T2 = MIRMAP_REF.collect()
							// Cat targetScan
							ALL_TARGETSCAN_REF = CAT_TARGETSCAN_REF(TARGETSCAN_REF.collect())
							ALL_TARGETSCAN_ALT = CAT_TARGETSCAN_ALT(TARGETSCAN_ALT.collect())
							 //CAT miRmap
							ALL_MIRMAP_REF = CAT_MIRMAP_REF(MIRMAP_REF.collect())
							ALL_MIRMAP_ALT = CAT_MIRMAP_ALT(MIRMAP_ALT.collect())
						// Merge mirmap and targetscan data
						 REF_TARGETS = COMPARE_TOOLS_REF(ALL_TARGETSCAN_REF,
							 																ALL_MIRMAP_REF,
																							CONVERT_GFF_TO_BED.out,
																							R_script_5)
						// Merge mirmap and targetscan data
					  ALT_TARGETS = COMPARE_TOOLS_ALT(ALL_TARGETSCAN_ALT,
																						ALL_MIRMAP_ALT,
																						CONVERT_GFF_TO_BED.out,
																								R_script_5)
						// COMPARE_TARGETS: Compare REF and ALT targets
						COMPARE_TARGETS(REF_TARGETS.TSV, ALT_TARGETS.TSV, R_script_6)

}
