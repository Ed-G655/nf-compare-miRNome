#Scrip to plot the number of snp in microRNA regions

## load libraries
library("eulerr")
library("ggplot2")
library("dplyr")
library("stringr")

## Read args from command line
args = commandArgs(trailingOnly=TRUE)

## Uncomment For debugging only
## Comment for production mode only
#args[1] <-"./test/data/sample.tsv" # BED test file
#args[2] <- "./test/data/sample.seed.tsv" # BED seed test file

#args[3] <- "sample" # output png file

## get the BED files
miRNAs <- args[1]

miRNA_seed <- args[2]

## pass to named objects
output_baseName <- args[3]

##Read files
miRNAs.df <- read.table(file = miRNAs , sep = "\t", header = F )
miRNAs.df <- cbind(subset(miRNAs.df, select = 1:5),
                subset(miRNAs.df, select =(ncol(miRNAs.df)-4):ncol(miRNAs.df)))

names(miRNAs.df)[1] <- "chrom"
names(miRNAs.df)[2] <- "pos"
names(miRNAs.df)[4] <- "ref"
names(miRNAs.df)[5] <- "alt"
names(miRNAs.df)[6] <- "mir"
names(miRNAs.df)[8] <- "strand"
names(miRNAs.df)[10] <- "type"

primary_mirRNAs.df <- miRNAs.df %>% filter(type=="miRNA_primary_transcript")
mature_miRNAS.df <- miRNAs.df %>% filter(type=="miRNA")


seed_miRNAS.df<- read.table(file = miRNA_seed, sep = "\t", header = F, colClasses = "character")

seed_miRNAS.df <- cbind(subset(seed_miRNAS.df, select = 1:5),
                          subset(seed_miRNAS.df, select =(ncol(seed_miRNAS.df)-3):ncol(seed_miRNAS.df)))

names(seed_miRNAS.df)[1] <- "chrom"
names(seed_miRNAS.df)[2] <- "pos"
names(seed_miRNAS.df)[4] <- "ref"
names(seed_miRNAS.df)[5] <- "alt"
names(seed_miRNAS.df)[6] <- "mir"
names(seed_miRNAS.df)[8] <- "strand"
names(seed_miRNAS.df)[9] <- "type"

primary_mirRNAs.df <- primary_mirRNAs.df %>%  mutate( ID = str_c(primary_mirRNAs.df$chrom,"_",
                                                                 primary_mirRNAs.df$pos,"_",
                                                                 primary_mirRNAs.df$ref, "_",
                                                                 primary_mirRNAs.df$alt,"_",
                                                                 primary_mirRNAs.df$strand) )



mature_miRNAS.df <- mature_miRNAS.df %>%  mutate( ID = str_c(mature_miRNAS.df$chrom,"_",
                                                             mature_miRNAS.df$pos,"_",
                                                             mature_miRNAS.df$ref, "_",
                                                             mature_miRNAS.df$alt,"_",
                                                             mature_miRNAS.df$strand) )

seed_miRNAS.df <- seed_miRNAS.df %>%  mutate( ID = str_c(seed_miRNAS.df$chrom,"_",
                                                         seed_miRNAS.df$pos,"_",
                                                         seed_miRNAS.df$ref, "_",
                                                         seed_miRNAS.df$alt,"_",
                                                         seed_miRNAS.df$strand) )
#Plot eulerr diagram
Venn_list <- list(
  A = primary_mirRNAs.df %>% pull(ID),
  B = mature_miRNAS.df %>% pull(ID),
  C = seed_miRNAS.df %>%  pull(ID)
  )

## Name the source of the ids
names(Venn_list) <- c("primary regions", "mature regions","seed regions")

## Make eulerr plot
microRNAs_euler <- euler(Venn_list)

microRNAs_euler.p <- plot( x = microRNAs_euler,
                           quantities = TRUE,
                           main = "SNVs in microRNAs",
                           fill = c("#e99690","#90e996","#9690e9") )

ggsave( filename = str_interp("${output_baseName}.png"),
        plot = microRNAs_euler.p,
        device = "png",
        height = 7,
        width = 14,
        units = "in",
        dpi = 300 )

# write a dataframe from the uniques SNPs of each region
primary_mirRNAs_IDs <- primary_mirRNAs.df %>% pull(ID) %>% unique()
mature_miRNAS_IDs <- mature_miRNAS.df %>% pull(ID) %>% unique()
seed_miRNAS_IDs <- seed_miRNAS.df %>% pull(ID) %>% unique()

unique_primary_mirRNAs.df <- primary_mirRNAs.df %>%
  filter( !(ID %in% mature_miRNAS_IDs )) %>%
  select(chrom, pos, ref, alt, mir, strand, type)

unique_mature_miRNA.df <- mature_miRNAS.df %>%
  filter( !(ID %in% seed_miRNAS_IDs )) %>%
  select(chrom, pos, ref, alt, mir, strand, type)

unique_seed_miRNA.df <-seed_miRNAS.df %>%
  select(chrom, pos, ref, alt, mir, strand, type)

all_miRNAs.df <- rbind(unique_primary_mirRNAs.df,
                           unique_mature_miRNA.df,
                           unique_seed_miRNA.df)

write.table(all_miRNAs.df,
            file = str_interp("${output_baseName}.tsv"),
            sep = "\t",
            row.names = F, col.names = T, quote = F)

