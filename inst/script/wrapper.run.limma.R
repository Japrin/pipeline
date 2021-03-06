#!/usr/bin/env Rscript

suppressPackageStartupMessages(library("argparse"))

parser <- ArgumentParser()
parser$add_argument("-b", "--bFile", type="character", required=TRUE, help="input sce file list")
parser$add_argument("-o", "--outPrefix", type="character", required=TRUE, help="outPrefix")
parser$add_argument("-p", "--platform",type="character",required=TRUE,help="platform such as 10X, SmartSeq2")
parser$add_argument("-n", "--ncores", type="integer",default=16L, help="[default %(default)s]")
parser$add_argument("-m", "--measurement",type="character",default="counts",help="[default %(default)s]")
parser$add_argument("-w", "--ncellDEG",type="integer",default=1500,
                    help="number of cells to downsample to for each group. used in DEG analysis. [default %(default)s]")
parser$add_argument("-c", "--stype", type="character", help="only analyze stype specified (default all)")
parser$add_argument("-a", "--group", type="character",default="ClusterID", help="group var (default ClusterID)")
parser$add_argument("-d", "--groupMode", type="character",default="multi", help="group mode (default multi)")
parser$add_argument("-q", "--filter", type="character",help="comma(,) seperated group list (default: don't apply filter)")
###parser$add_argument("-a", "--aFile", type="character", required=TRUE, help="input seu file list")
####parser$add_argument("-s", "--sample", type="character", default="SAMPLE", help="sample id")
####parser$add_argument("-d", "--npc", type="integer",default=15L, help="[default %(default)s]")
args <- parser$parse_args()
print(args)

############## tune parametrs  ########
#sce.file <- "/lustre1/zeminz_pkuhpc/zhenglt/work/panC/ana/zhangLab.10X/A20190515/inte.sscClust/OUT.byDataset/T.CD8/T.CD8.CRC.zhangLabSS2/T.CD8.CRC.zhangLabSS2.sce.rds"
#out.prefix <- "OUT.test/TEST"
#opt.ncores <- 12
#opt.measurement <- "counts"
#opt.stype <- "all"
#opt.platform <- "SmartSeq2"

###seu.file <- args$aFile
sce.file <- args$bFile
out.prefix <- args$outPrefix
opt.ncores <- args$ncores
opt.measurement <- args$measurement
opt.ncellDEG <- args$ncellDEG
opt.stype <- args$stype
opt.platform <- args$platform
opt.group <- args$group
opt.mode <- args$groupMode
opt.filter <- args$filter

#gene.exclude.file <- "/lustre1/zeminz_pkuhpc/zhenglt/work/panC/data/geneSet/exclude/exclude.gene.misc.misc.RData"

dir.create(dirname(out.prefix),F,T)

############## tune parametrs  ########
library("sscClust")
library("Seurat")
library("tictoc")
library("plyr")
library("dplyr")
library("tibble")
library("doParallel")
library("sscClust")
library("Matrix")
library("data.table")
library("R.utils")
library("gplots")
library("ggplot2")
library("ggpubr")
library("cowplot")
library("limma")
library("reticulate")

#RhpcBLASctl::omp_set_num_threads(1)
#doParallel::registerDoParallel(cores = opt.ncores)
options(stringsAsFactors = FALSE)

#####source("/lustre1/zeminz_pkuhpc/zhenglt/02.pipeline/cancer/lib/scRNAToolKit.R")
#source("/lustre1/zeminz_pkuhpc/zhenglt/work/panC/ana/zhangLab.10X/A20190515/inte.sscClust/run.seurat3.lib.R")

######################

#env.misc <- loadToEnv(gene.exclude.file)
#env.misc$all.gene.ignore.df %>% head

if(grepl("\\.rds$",sce.file)){
	##seu <- readRDS(seu.file)
	sce <- readRDS(sce.file)
}else{
	##env.a <- loadToEnv(seu.file)
	##obj.name.a <- names(env.a)[1]
	##seu <- env.a[[obj.name.a]]
	##rm(env.a)
	env.b <- loadToEnv(sce.file)
	obj.name.b <- names(env.b)[1]
	sce <- env.b[[obj.name.b]]
	rm(env.b)
}

if(!is.null(opt.stype)){
	sce <- sce[,sce$stype==opt.stype]
}

if(!is.null(opt.filter)){
	filter.group <- unlist(strsplit(opt.filter,",",perl=T))
	cat(sprintf("filter groups belong to one of:\n"))
	print(filter.group)
	sce <- sce[,!(sce[[opt.group]] %in% filter.group)]
	#group.levels <- setdiff(levels(sce[[opt.group]]),filter.group)
	#sce[[opt.group]] <- factor(as.character(sce[[opt.group]]),levels=group.levels)
}

tic("run limma")

if(!("norm_exprs" %in% assayNames(sce)))
{
	assay(sce,"norm_exprs") <- assay(sce,"log2TPM")
}
assay.name <- "norm_exprs"

#if(opt.measurement=="TPM"){
#	#### TPM
#	assay.name <- "log2TPM"
#}else{
#	#### counts, cpm
#	assay.name <- "norm_exprs"
#}

if("meta.cluster" %in% colnames(colData(sce)) )
{
    m <- regexec("^CD[48]",sce$meta.cluster,perl=T)
    sce$stype <- sapply(regmatches(sce$meta.cluster,m),function(x){ x[1] })
    print(table(sce$stype))
}

n.group <- unclass(table(sce[[opt.group]]))
print(n.group)
n.group.flt <- n.group[n.group>=2]
print(n.group.flt)

sce <- sce[,sce[[opt.group]] %in% names(n.group.flt)]

nBatch <- length(table(sce$batchV))

set.seed(9998)
tic("limma")
de.out <- ssc.DEGene.limma(sce,assay.name=assay.name,
			   ####ncell.downsample=if(opt.mode=="multi") 1500 else 25000,
			   #ncell.downsample=if(opt.mode=="multi") 1500 else NULL,
			   ncell.downsample=opt.ncellDEG,
			   ####ncell.downsample=if(opt.mode=="multi") 1500 else 100,
			   group.var=opt.group,batch=if(nBatch>1) "batchV" else NULL,
			   verbose=3,
			   group.mode=opt.mode,
			   out.prefix=out.prefix,n.cores=opt.ncores,
			   #T.expr=0.3,T.bin.useZ=T,
			   T.logFC=if(opt.platform=="SmartSeq2") 1 else 0.25)

saveRDS(de.out,file=sprintf("%s.de.out.rda",out.prefix))
toc()


