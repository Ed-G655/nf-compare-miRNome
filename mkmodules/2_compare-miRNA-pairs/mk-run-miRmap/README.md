# miRmap_module

This module use the python miRmap libray to predicts miRNA targets.
## Basic ideas:
    * Grab FASTA files.
    * Identify miRNA targets with Targetscan and miRmap
    * Create a unique identifier for each result and export it in a TSV file
---

## Inputs:
This module take 2 input files:

* A FASTA file that list the miRNA sequences and they miRNA ID.

Example line(s):
````
      >hsa-let-7a-5p
      UGAGGUAGUAGGUUGUAUAGUU
      >hsa-let-7f-2-3p
      CUAUACAGUCUACUGUCUUUCC
      >hsa-miR-22-5p
      AGUUCUUCAGUGGCAAGCUUUA
      ...
````

* A FASTA file that list the 3' UTRs sequences of desired genes.
 Example line(s):


````
		>CDC2L6
		CCAGCUCCCGUUGGGCCAGGCCAGCCCAGCCCAGAGCACAG...
		>FNDC3A
		AAAUAUAACUUUAUUUUUUAACUCUAUUACAUUUUAUUUUG...
      	 	 ...
````

---
## Ouputs

A .tsv file with the results of miRmap script

Example line(s):
````
  GeneID	miRNA_ID	UTR_start	UTR_end	Site_type
  CDC2L6	hsa-let-7f-2-3p	4240	4245	6mer
  CDC2L6	hsa-let-7f-2-3p	3886	3892	7mer-1a
  CDC2L6	hsa-let-7f-2-3p	3466	3471	6mer
  ...
````
---

#### Module Dependencies:

miRmap libray > https://mirmap.ezlab.org/docs/
Biopython > https://biopython.org/wiki/Download

---

#### Autors
José Eduardo Garcia lopez

---

#### References

*  Charles E. Vejnar and Evgeny M. Zdobnov
  miRmap: Comprehensive prediction of microRNA target repression strength
  Nucleic Acids Research 2012 Dec 1;40(22):11673-83. doi: 10.1093/nar/gks901
