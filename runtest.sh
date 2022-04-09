mirna_gff="test/data/sample.gff3"
utrbed="test/data/sample.utr.bed"
vcf="test/data/sample.vcf.gz"
fasta="test/data/"
output_directory="$(dirname $mirna_gff)/results"

echo -e "======\n Testing NF execution \n======" \
&& rm -rf $output_directory \
&& nextflow run nf-compare-miRNome.nf \
	--mirna_gff $mirna_gff \
  --utrbed $utrbed \
	--vcf $vcf \
	--fasta_dir $fasta \
	--output_dir $output_directory \
	-resume \
	-with-report $output_directory/`date +%Y%m%d_%H%M%S`_report.html \
	-with-dag $output_directory/`date +%Y%m%d_%H%M%S`.DAG.html \
	-with-timeline $output_directory/`date +%Y%m%d_%H%M%S`_timeline.html \
&& echo -e "======\n Basic pipeline TEST SUCCESSFUL \n======"
	#-stub-run \
