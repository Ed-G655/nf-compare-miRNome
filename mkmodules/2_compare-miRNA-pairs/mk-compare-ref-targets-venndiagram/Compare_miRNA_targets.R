  
## load libraries
library ("dplyr")
library("ggplot2")
library("ggvenn")
library("stringr")

## Read args from command line
args = commandArgs(trailingOnly=TRUE)

## Uncomment For debugging only
## Comment for production mode only
#args[1] <-"test/data/CHROM22mut.mirmapid"
#"test/data/sample1.mirmapid" #miRmap data
#args[2] <- "test/data/CHROM22mut.tsid"
  #"test/data/sample1.tsid" # target_scan data
#args[3] <- "test/data/sample1.targets" # output file

## get the mirmap tsv file from args
mirmap_id_file <- args[1]

## get targetscan tsv file from args
targetscan_id_file <- args[2]

## pass to named objects
ids_targets <- args[3]

## Read miRNA targets IDs
IDs_mirmap.df <- read.table(file= mirmap_id_file, header = T,
                           sep = "\t", stringsAsFactors = FALSE)

IDs_targetscan.df <- read.table(file= targetscan_id_file, header = T,
                          sep = "\t", stringsAsFactors = FALSE)
## Change header
names(IDs_mirmap.df)[1] <- "miRNA_ID"

names(IDs_targetscan.df)[1] <- "miRNA_ID"

##Remove any space or tab
IDs_mirmap.df <- mutate(IDs_mirmap.df, miRNA_ID = str_remove_all(IDs_mirmap.df[,1],"[:blank:]"))
IDs_targetscan.df <- mutate(IDs_targetscan.df, miRNA_ID = str_remove_all(IDs_targetscan.df[,1],"[:blank:]"))

## Make a list with the unique IDs
IDs_mirmap.list <- IDs_mirmap.df %>%  pull(1) %>%  unique()

IDs_targetscan.list <- IDs_targetscan.df %>%  pull(1) %>%  unique()

## Sort the ids list within a list for ggvenn
Venn_list <- list(
  A = IDs_mirmap.list,
  B = IDs_targetscan.list)

## Name the source of the ids
names(Venn_list) <- c("miRmap","TargetScan")

## Ṕlot a Venn diagram
miRNAs_Venn.p <- ggvenn(Venn_list, fill_color = c("#EE6352", "#59CD90"),
                        stroke_size = 0.5, set_name_size = 4 , text_size = 4)

## Save plot
ggsave( filename = str_interp("${ids_targets}.png"),
        plot = miRNAs_Venn.p,
        device = "png",
        height = 7, width = 14,
        units = "in")

## get unique IDs for each file
IDs_mirmap.df <- data.frame(IDs_mirmap.df) %>%  unique()

IDs_targetscan.df <- data.frame(IDs_targetscan.df %>%  unique())

## Get mirna targets present in both tools
IDs_intersect <-IDs_mirmap.df %>%  intersect(IDs_targetscan.df)

#IDs_intersect_2 <- IDs_targetscan.df %>%  intersect(IDs_mirmap.df)

#IDs_intersect_3 <-  data.frame(full_join(IDs_intersect_1, IDs_intersect_2, "miRNA_ID") %>%  unique())

##Get miRNA targets ids that differ
IDs_mirmap_differ.df <- IDs_mirmap.df %>% setdiff(IDs_targetscan.df)

IDs_targetscan_differ.df <- IDs_targetscan.df %>% setdiff(IDs_mirmap.df)

## Define the source of miRNA ID
IDs_intersect <-IDs_intersect %>%  mutate(prediction_tool = "both")

IDs_mirmap_differ.df <- IDs_mirmap_differ.df %>%  mutate(prediction_tool = "mirmap")

IDs_targetscan_differ.df <- IDs_targetscan_differ.df %>%  mutate(prediction_tool = "targetscan")

## Merge the miRNA targets ids that differ into a single dataframe
IDs_differ.df <- full_join(x = IDs_mirmap_differ.df, y = IDs_targetscan_differ.df,
                               by = c("miRNA_ID", "prediction_tool") )

## Merge all miRNA targets ids into a single dataframe
All_IDs.df <- full_join(x = IDs_intersect, y = IDs_differ.df,
                        by = c("miRNA_ID", "prediction_tool") )

## Save dataframe
write.table(All_IDs.df, file = ids_targets, sep = "\t", na = "NA", quote = F, row.names = F)
