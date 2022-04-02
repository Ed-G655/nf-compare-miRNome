## load libraries

library("dplyr")
library("stringr")

## Read args from command line
args = commandArgs(trailingOnly=TRUE)

## Uncomment For debugging only
## Comment for production mode only
#args[1] <- "test/data/sample1.mirna.fa" ## FASTA file
#args[2] <- "test/data/sample1.mirna.txt" ## ouput file

##get the FASTA file from args
FASTA_file <- args[1]

##get output file from args
ouput_file <- args[2]

## Read FASTA file
miRNAs <- readLines(FASTA_file)

## Convert FASTA file to dataframe

mirna.df <- file(ouput_file,"w")

currentSeq <- 0
newLine <- 0

for(i in 1:length(miRNAs)) {
  if(strtrim(miRNAs[i], 1) == ">") {
    if(currentSeq == 0) {
      writeLines(paste(miRNAs[i],"\t"), mirna.df, sep="")
      currentSeq <- currentSeq + 1
    } else {
      writeLines(paste("\n",miRNAs[i],"\t", sep =""), mirna.df, sep="")
    }
  } else {
    writeLines(paste(miRNAs[i]), mirna.df, sep="")
  }
}

close(mirna.df)

## Read miRNA dataframe
mirna.df <- read.table(file = ouput_file,
                       header = FALSE, sep = "\t",
                       stringsAsFactors = FALSE)

## Extract seed region of miRNA sequences

    # The seed region is a conserved heptametrical sequence which
    #     is mostly situated at positions 2-7 from the miRNA 5´-end.

miRNA_seed.df <- mutate(mirna.df, V2 = str_sub(mirna.df[,2],
                                                start = 2 , end = 8))
## Remove mirbase IDs

miRNA_seed.df <- mutate(miRNA_seed.df, V1 = str_remove_all(mirna.df[,1], pattern = "\\sMIM\\w+"))

## Remove ">" from sequence names  

miRNA_seed.df <- mutate(miRNA_seed.df,V1= str_remove_all(miRNA_seed.df[,1], pattern = ">"))

## Add the species ID in a third column
    ## The species ID for "Homo Sapiens" is "9606" according to the NCBI taxonomic classification. 

mirna.df<- mutate(miRNA_seed.df, V3 = "9606")

## Save outputfile as text file to TargetScan
write.table(mirna.df, file = ouput_file, sep = "\t",
            row.names = FALSE, col.names = FALSE, quote = FALSE)

