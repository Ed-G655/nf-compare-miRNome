## load libraries

library("dplyr")
library("stringr")

## Read args from command line
args = commandArgs(trailingOnly=TRUE)

## Uncomment For debugging only
## Comment for production mode only
#args[1] <- "test/data/sample.utr.fa" ## FASTA file
#args[2] <- "test/data/sample.utr.txt" ## ouput file

##get the FASTA file from args
FASTA_file <- args[1]

##get output file from args
ouput_file <- args[2]

## Read FASTA file
UTRs <- readLines(FASTA_file)

## Convert FASTA file to dataframe
output.df <- file(ouput_file,"w")

currentSeq <- 0
newLine <- 0

for(i in 1:length(UTRs)) {
  if(strtrim(UTRs[i], 1) == ">") {
    if(currentSeq == 0) {
      writeLines(paste(UTRs[i],"\t"), output.df, sep="")
      currentSeq <- currentSeq + 1
    } else {
      writeLines(paste("\n",UTRs[i],"\t", sep =""), output.df, sep="")
    }
  } else {
    writeLines(paste(UTRs[i]), output.df, sep="")
  }
}

close(output.df)

## Read UTR dataframe
output.df <- read.table(file = ouput_file,
                        header = FALSE, sep = "\t",
                        stringsAsFactors = FALSE)

## Remove ">" from sequence names  
output.df <- mutate(output.df,V1= str_remove_all(output.df[,1], pattern = ">"))

## Remove any space or tab
output.df <- mutate(output.df,V1= str_remove_all(output.df[,1], pattern = "[:blank:]"))

## Add the species ID in the second column
  ## The species ID for "Homo Sapiens" is "9606" according to the NCBI taxonomic classification. 
output.df<- mutate(output.df, V3 = V2) %>%  mutate(output.df, V2 = "9606")

## Save outputfile as text file to TargetScan 
write.table(output.df, file = ouput_file, sep = "\t", 
            row.names = FALSE, col.names = FALSE, quote = FALSE)
  
