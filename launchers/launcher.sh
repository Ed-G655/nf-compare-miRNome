#!/usr/bin/env bash
cd ../

mirnabed="/bodega/projects/miRNome_project/references/beds/hsa_mature_miRNAs.bed"
utrbed="/bodega/projects/miRNome_project/references/beds/3utr.bed"
vcf="/bodega/projects/miRNome_project/references/vcfs/LXXVIg_PASS_AF_OV.vcf.gz"
fasta="/bodega/projects/miRNome_project/references/fastas/"
output_directory="/bodega/projects/miRNome_project/analisis/100GMX/results"

echo -e "======\n Lauching NF execution \n======" \
&& rm -rf $output_directory \
&& nextflow run nf-compare-miRNome.nf \
	--mirnabed $mirnabed \
  --utrbed $utrbed \
	--vcf $vcf \
	--fasta_dir $fasta \
	--output_dir $output_directory \
	-resume \
	-with-report $output_directory/`date +%Y%m%d_%H%M%S`_report.html \
	-with-dag $output_directory/`date +%Y%m%d_%H%M%S`.DAG.html \
&& echo -e "======\n  pipeline execution END \n======"
