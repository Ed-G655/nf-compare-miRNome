# This script calculates the start and end coordinates of the seed region ofa mature miRNA from a BED file,
# taking into account the length of the seed region and the sense of the strand.

## load libraries
library("dplyr")

## Read args from command line
args = commandArgs(trailingOnly=TRUE)

## Uncomment For debugging only
## Comment for production mode only
#args[1] <-"test/data/sample.bed"

#args[2] <- "test/results/sample.seed.bed" # output file

## get the BED file
bed_file <- args[1]

## pass to named objects
output_file <- args[2]

##load BED file data
bed.df <- read.table(file = bed_file , header = F, sep = "\t")  %>%
  filter(V8=="miRNA")

##Select the first 6 columns corresponding to BED format  described on the UCSC Genome Browser website
mirna.df <- bed.df %>% select(V1, V2, V3, V4, V5, V6)

mirna.df <- mirna.df %>% rename(chrom = V1, start = V2, end = V3, name = V4,score = V5, strand = V6 )


##Calculate the start and end of each seed region taking into account the sense of the strand
seed_mirna.df <- mirna.df %>% mutate(start = ifelse(mirna.df$strand == "+",
                                                      mirna.df$start + 1,
                                                      mirna.df$end - 8)) %>%
  mutate(end = ifelse(mirna.df$strand == "+",
                      mirna.df$start + 8,
                      mirna.df$end - 1))
#Add type column
seed_mirna.df <- seed_mirna.df %>%  mutate(type = "miRNA_seed")

#Write bed with the coordinates of just miRNA seeds
write.table(seed_mirna.df,
            file = output_file ,
            sep = "\t",
            row.names = F, col.names = F, quote = F)

