# created by Eduardo Garcia (jeduardogl655@gmail.com) on 04/Feb/2022
Files comes from...

# Sample VCF data; 1000 Genomes project data, re-called in GRCh38
Article Source: https://wellcomeopenresearch.org/articles/4-50
Description: We present a set of biallelic SNVs and INDELs, from 2,548 samples spanning 26 populations from the 1000 Genomes Project, called de novo on GRCh38. We believe this will be a useful reference resource for those using GRCh38. It represents an improvement over the “lift-overs” of the 1000 Genomes Project data that have been available to date by encompassing all of the GRCh38 primary assembly autosomes and pseudo-autosomal regions, including novel, medically relevant loci. Here, we describe how the data set was created and benchmark our call set against that produced by the final phase of the 1000 Genomes Project on GRCh37 and the lift-over of that data to GRCh38.

-Data availability
...
This call set is also available from the International Genome Sample Resource (IGSR)4
 at: http://ftp.1000genomes.ebi.
ac.uk/vol1/ftp/data_collections/1000_genomes_project/release/20190312_biallelic_SNV_and_INDEL/.

#
Downloaded at Nov28 00:14
by iaguilaror@gmail.com
with:
wget2 --progress=bar \
--chunk-size=1G \
--max-threads=10 \
http://ftp.1000genomes.ebi.ac.uk/vol1/ftp/data_collections/1000_genomes_project/release/20190312_biallelic_SNV_and_INDEL/ALL.wgs.shapeit2_integrated_snvindels_v2a.GRCh38.27022019.sites.vcf.gz

# Data seems to come double compressed.
you need to gunzip the file, then rename to *.gz
then bcftools can read it without a problem

To prepare the sample data the following commands were used (by jeduardogl655@gmail.com);
 bcftools norm -m+ ALL.wgs.shapeit2_integrated_snvindels_v2a.GRCh38.27022019.sites.vcf.gz \ 
 | bcftools view -m2 -M2 -v snps \ 
 | bgzip -c >  1000GP_GRCh38_biallelic_SNPs.vcf.gz

 bcftools index 1000GP_GRCh38_biallelic_SNPs.vcf.gz 
 bcftools view -r 21 1000GP_GRCh38_biallelic_SNPs.vcf.gz > sample.vcf

# Sample GFF3 data: Chromosomal coordinates of Homo sapiens microRNAs
# microRNAs:               miRBase v22
# genome-build-id:         GRCh38
# genome-build-accession:  NCBI_Assembly:GCA_000001405.15

# Hairpin precursor sequences have type "miRNA_primary_transcript". 
# Note, these sequences do not represent the full primary transcript, 
# rather a predicted stem-loop portion that includes the precursor 
# miRNA. Mature sequences have type "miRNA".

-Data availability:
This coordinates are avaible at:
https://www.mirbase.org/ftp/CURRENT/genomes/hsa.gff3

Dowloaded at 04/FEB/2022
by jeduardogl655@gmail.com
with;
curl -O https://www.mirbase.org/ftp/CURRENT/genomes/hsa.gff3 

To prepare the sample data the following commands were used (by jeduardogl655@gmail.com);

less -S hsa.gff3 \ 
| grep "chr21" \ 
| sed -r 's/chr//g' > sample.gff3
 
 
