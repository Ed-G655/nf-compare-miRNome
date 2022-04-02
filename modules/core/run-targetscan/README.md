# TargetScan_module

##Module description:
This module use the TargetScan software to predicts miRNA targets.
  Basic ideas:
      1. Grab .txt data files.
      5. Identify miRNA targets with TargetScan.
      4. Convert the output file to a TSV file
      6. Create a unique identifier for each result and export it in a TSV file
---

##Inputs:
This module take 2 input files:

	1) A tab-delimited file that lists the miRNA seed sequences and the
	species in which they are present.The file must have the name ending "* mirna.txt"
	Each line of the miRNA seed sequence file consists of 3 tab separated entries
			1) Name of the miRNA.
			2) The 7 nucleotide long seed region sequence.
			3) List (semicolon-delimited) of Species IDs of this miRNA family
				 (which should match species IDs in UTR input file), "9606" for homo sapiens.

			Example line(s):
````
				hsa-miR-181b-5p ACAUUCA	9606
				hsa-miR-199a-3p	CAGUAGU	9606
				hsa-miR-23a-5p	GGGUUCC	9606
        ...
````

		2) A tab-delimited file with sequence  of the 3' UTRs of genes.
			 Each line of the alignment file consists of 3 tab separated entries
					1) Gene symbol or transcript ID.
					2) Species/taxonomy ID (which should match species IDs in miRNA input file).
					3) Sequence.

				Example line(s):
					CDC2L6	10090	CCCACUCCCUCUGCUUGGCCUUGGACUCCAGCAGGGUGG...

For more information read the README_70.txt file of TargetScan.
---
##Ouputs:
  A .txt and .tsv file with the results of TargetScan

  Example line(s):
````
    CDC2L6	hsa-let-7a-2-3p	9606	810	815	810	815	1	6mer	x	6mer	9606		0
    CDC2L6	hsa-let-7a-2-3p	9606	937	942	937	942	2	6mer	x	6mer	9606		0
    CDC2L6	hsa-let-7a-3p	9606	1526	1532	1526	1532	3	7mer-m8	x	7mer-m8	9606		0
    ...
````
    For more information read the README_70.txt file of TargetScan.

  A .id.tsv file with an unique identifier (id) for each miRNA target

  Example line(s):
````
  Gene_ID-miRNA_ID-UTR_start-UTR_end-Site_type
  CDC2L6-hsa-let-7a-2-3p-810-815-6mer
  CDC2L6-hsa-let-7a-2-3p-937-942-6mer
  CDC2L6-hsa-let-7a-3p-1526-1532-7mer-m8
  ...
````
---

####Module Dependencies:
NONE
---

####Autors
José Eduardo Garcia lopez
---

####References

*  Lewis, B. P., Burge, C. B., & Bartel, D. P. (2005). Conserved seed pairing, often flanked
  by adenosines, indicates that thousands of human genes are microRNA targets. Cell, 120(1),
  15–20. https://doi.org/10.1016/j.cell.2004.12.035
