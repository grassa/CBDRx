# 2017-07-30 06:54:26
#
# Generated with:
#     /home/cg/install/mccortex/scripts/make-pipeline.pl 19,25,31,47 mccortexF1 F1.samples
#
# To use this file:
#     make -f <thisfile> [options] [target]
#
# Valid targets:
#   graphs         <- build and clean graphs
#   links          <- build and clean links
#   bubbles        <- make bubble calls
#   breakpoints    <- make breakpoint calls
#   bub-vcf        <- make bubble VCF
#   brk-vcf        <- make breakpoint VCF
#   bub-geno-vcf   <- genotyped bubble VCF
#   brk-geno-vcf   <- genotyped breakpoint VCF
#   vcfs           <- make all vcfs  [default]
#   contigs        <- assemble contigs for each sample
#   contigs-pop    <- assemble contigs after popping bubbles
#   unitigs        <- dump unitigs for each sample
#
# Debugging:
#   print-VAR      <- Print the value of VAR
#
# Options:
#   --always-make          List/run all commands even if dependencies exist.
#   --dry-run              Print commands but not run them
#   CTXDIR=<mccortex-dir>  McCortex directory e.g. CTXDIR=~/bin/mccortex
#   MEM=<mem-to-use>       max memory to use e.g. MEM=80G  => 80 gigabytes of RAM
#   NKMERS=<num-kmers>     capacity of the graph e.g. NKMERS=20M  => 20 million kmers
#   NTHREADS=<nthreads>    number of threads to use
#   USE_LINKS=<B>          <B> is 'yes' or 'no'
#   JOINT_CALLING=<B>      Call samples together or 1-by-1. <B> is 'yes' or 'no'
#   MATEPAIR=<MP>          MP can be FF,FR,RF,RR (default: FR)
#   MIN_FRAG_LEN=<L>       min. good fragment length bp (=read+gap+read)
#   MAX_FRAG_LEN=<L>       max. good fragment length bp (=read+gap+read)
#   FQ_CUTOFF=10           base quality cut off (0=off) [default: 10]
#   HP_CUTOFF=0            homopolymer run cut off (0=off) [default: 0]
#   BRK_REF_KMERS=N        num. of flanking ref kmers required by breakpoint caller
#   MAX_BRANCH_LEN=N       max distance to assemble and align to ref
#   MIN_MAPQ=Q             min. flank mapping quality required by bubble caller
#   PLOIDY=P               '1','2', or '-P SAMPLE[,..]:CHR[,..]:PLOIDY [-P ...]' (genotyping)
#   ERR=0.01,0.005         Per base seq error rate. Comma-sep list one per sample. (genotyping)


#
# File structure:
# ---------------
#
# <K> is kmer size
# <S> is sample name
# <P> set of sample names and "joint"
#
# Roughly listed in order of generation
#
# <outdir>/
#   -> k<K>/
#     -> graphs/
#       -> <S>.raw.ctx
#       -> <S>.raw.ctx.log
#       -> <S>.raw.cov.csv
#       -> <S>.clean.ctx
#       -> <S>.clean.ctx.log
#       -> <S>.clean.cov.csv
#       -> <S>.inferedges.ctx.log
#       -> <S>.clean.unitigs.fa.gz
#     -> links/
#       -> <S>.se.raw.ctp.gz
#       -> <S>.se.raw.ctp.gz.log
#       -> <S>.se.clean.ctp.gz
#       -> <S>.se.clean.ctp.gz.log
#       -> <S>.se.thresh.txt
#       -> <S>.se.thresh.txt.log
#       -> <S>.se.links.csv
#       -> <S>.pe.raw.ctp.gz
#       -> <S>.pe.raw.ctp.gz.log
#       -> <S>.pe.clean.ctp.gz
#       -> <S>.pe.clean.ctp.gz.log
#       -> <S>.pe.thresh.txt
#       -> <S>.pe.thresh.txt.log
#       -> <S>.pe.links.csv
#     -> bubbles_links/
#       -> <P>.bub.gz
#       -> <P>.bub.gz.log
#       -> <P>.flanks.fa.gz
#       -> <P>.flanks.sam
#       -> <P>.bub.raw.vcf
#       -> <P>.bub.raw.vcf.log
#       -> <P>.bub.sort.vcf
#       -> <P>.bub.norm.vcf.gz
#       -> <P>.bub.norm.vcf.gz.csi
#     -> bubbles_plain/
#       -> SAME AS ../bubbles_links/
#     -> breakpoints_links/
#       -> <P>.brk.gz
#       -> <P>.brk.gz.log
#       -> <P>.brk.raw.vcf
#       -> <P>.brk.raw.vcf.log
#       -> <P>.brk.sort.vcf
#       -> <P>.brk.norm.vcf.gz
#       -> <P>.brk.norm.vcf.gz.csi
#     -> breakpoints_plain/
#       -> SAME AS ../breakpoints_links/
#     -> contigs_plain/
#       -> <S>.raw.fa.gz
#       -> <S>.raw.fa.gz.log
#       -> <S>.rmdup.fa.gz
#       -> <S>.rmdup.fa.gz.log
#     -> contigs_links/
#       -> SAME AS ../contigs_plain/
#     -> ref/
#       -> ref.ctx
#       -> ref.ctx.log
#     -> vcfcov/
#       -> {breakpoints,bubbles}.{joint,1by1}.{links,plain}.{kmers}.<SAMPLE>.vcf.gz
#       -> {breakpoints,bubbles}.{joint,1by1}.{links,plain}.{kmers}.<SAMPLE>.vcf.gz.log
#       e.g.
#       -> breakpoints.joint.plain.k29.k31.NA12878.vcf.gz
#   -> vcfs/
#     -> <breakpoints|bubbles>.<joint|1by1>.<plain|links>.k<K>.vcf.gz
#     -> <breakpoints|bubbles>.<joint|1by1>.<plain|links>.k<K>.vcf.gz.csi
#     -> <breakpoints|bubbles>.<joint|1by1>.<plain|links>.k<K>.geno.vcf.gz
#     -> <breakpoints|bubbles>.<joint|1by1>.<plain|links>.k<K>.geno.vcf.gz.csi
#     e.g.
#     -> breakpoints.joint.plain.k29.k31.vcf.gz
#     -> breakpoints.joint.plain.k29.k31.vcf.gz.csi
#     -> breakpoints.1by1.plain.k29.k31.vcf.gz
#     -> breakpoints.1by1.plain.k29.k31.vcf.gz.csi
#     -> breakpoints.joint.links.k29.k31.vcf.gz
#     -> breakpoints.joint.links.k29.k31.vcf.gz.csi
#     -> breakpoints.1by1.links.k29.k31.vcf.gz
#     -> breakpoints.1by1.links.k29.k31.vcf.gz.csi
#     -> bubbles.joint.plain.k29.k31.vcf.gz
#     -> bubbles.joint.plain.k29.k31.vcf.gz.csi
#     -> bubbles.1by1.plain.k29.k31.vcf.gz
#     -> bubbles.1by1.plain.k29.k31.vcf.gz.csi
#     -> bubbles.joint.links.k29.k31.vcf.gz
#     -> bubbles.joint.links.k29.k31.vcf.gz.csi
#     -> bubbles.1by1.links.k29.k31.vcf.gz
#     -> bubbles.1by1.links.k29.k31.vcf.gz.csi
#

SHELL=/bin/bash -eou pipefail

#
# Configuration (you can edit this bit)
#

CTXDIR=~/mccortex/
MEM=1G
NTHREADS=2
# Reference sequence (FASTA/FASTQ file) leave blank if none
REF_FILE=

# Matepair orientation of library (FR,FF,RR,RF)
MAX_BRANCH_LEN=1000
MATEPAIR=FR
MIN_FRAG_LEN=150
MAX_FRAG_LEN=1000
FQ_CUTOFF=10
HP_CUTOFF=0
MIN_MAPQ=30
PLOIDY=2
ERR_RATE=0.01

# Genotyping: Ploidy for human, haploid and diploid
# PLOIDY_ARGS=--ploidy 2 --ploidy .:chrY:1 --ploidy ben,tom:chrX:1
# PLOIDY_ARGS=--ploidy 1
# PLOIDY_ARGS=--ploidy $(PLOIDY)
PLOIDY_ARGS=--ploidy $(PLOIDY)

ERR_ARGS=--err $(ERR_RATE)

SEQ_PREFS=--fq-cutoff $(FQ_CUTOFF) --cut-hp $(HP_CUTOFF) --matepair $(MATEPAIR)
BRK_REF_KMERS=10

# Command arguments
BUILD_ARGS=$(SEQ_PREFS) --keep-pcr
KMER_CLEANING_ARGS=--fallback 2 -T -U
POP_BUBBLES_ARGS=--max-diff 50 --max-covg 5
THREAD_ARGS=$(SEQ_PREFS) --min-frag-len $(MIN_FRAG_LEN) --max-frag-len $(MAX_FRAG_LEN) --one-way --gap-diff-const 5 --gap-diff-coeff 0.1
LINK_CLEANING_ARGS=--limit 5000  --max-dist 250 --max-covg 250
BREAKPOINTS_ARGS=--minref $(BRK_REF_KMERS) --maxref $(MAX_BRANCH_LEN)
BUBBLES_ARGS=--max-allele $(MAX_BRANCH_LEN) --max-flank 1000
CALL2VCF_ARGS=--max-align $(MAX_BRANCH_LEN) --max-allele 100
CONTIG_ARGS=--no-missing-check --confid-step 0.99
CONTIG_POP_ARGS=--confid-step 0.99
VCFCOV_ARGS=--low-mem
# VCFGENO_ARGS=--rm-cov --llk
VCFGENO_ARGS=

#
# End of configuration
#

# Paths to scripts
CTXKCOV=$(CTXDIR)/scripts/mccortex-kcovg.pl
CTXFLANKS=$(CTXDIR)/scripts/cortex_print_flanks.sh
VCFSORT=$(CTXDIR)/libs/biogrok/vcf-sort
HRUNANNOT=$(CTXDIR)/libs/vcf-slim/bin/vcfhp

# Third party libraries packaged in McCortex
BWA=$(CTXDIR)/libs/bwa/bwa
BGZIP=$(CTXDIR)/libs/htslib/bgzip
BCFTOOLS=$(CTXDIR)/libs/bcftools/bcftools
STAMPY=
STAMPY_BASE=

# Set up memory, threads and number of kmers in the graph
ifdef MEM
  CTX_ARGS_MEM=-m $(MEM)
endif
ifdef NKMERS
  CTX_ARGS_NKMERS=-n $(NKMERS)
endif
ifdef NTHREADS
  CTX_ARGS_THREADS=-t $(NTHREADS)
endif
CTX_ARGS=$(CTX_ARGS_MEM) $(CTX_ARGS_NKMERS) $(CTX_ARGS_THREADS)

#
# Parse USE_LINKS and JOINT_CALLING Makefile options
#

# Use links is default on
ifeq ($(USE_LINKS),yes)
  LINKS=1
endif
ifeq ($(USE_LINKS),true)
  LINKS=1
endif
ifeq ($(USE_LINKS),1)
  LINKS=1
endif
ifndef USE_LINKS
  LINKS=1
endif

# Joint calling is default on
ifeq ($(JOINT_CALLING),yes)
  JOINT=1
endif
ifeq ($(JOINT_CALLING),true)
  JOINT=1
endif
ifeq ($(JOINT_CALLING),1)
  JOINT=1
endif
ifndef JOINT_CALLING
  JOINT=1
endif

# LINKS is defined iff we are using links
# JOINT is defined iff we are doing joint calling
# Files at k=19
RAW_GRAPHS_K19=mccortexF1/k19/graphs/F1.raw.ctx
CLEAN_GRAPHS_K19=$(RAW_GRAPHS_K19:.raw.ctx=.clean.ctx)
CLEAN_UNITIGS_K19=$(CLEAN_GRAPHS_K19:.ctx=.unitigs.fa.gz)
RAW_SE_LINKS_K19=mccortexF1/k19/links/F1.se.raw.ctp.gz
RAW_PE_LINKS_K19=mccortexF1/k19/links/F1.pe.raw.ctp.gz
CLEAN_SE_LINKS_K19=$(RAW_SE_LINKS_K19:.raw.ctp.gz=.clean.ctp.gz)
CLEAN_PE_LINKS_K19=$(RAW_PE_LINKS_K19:.raw.ctp.gz=.clean.ctp.gz)
CONTIGS_PLAIN_K19=mccortexF1/k19/contigs_plain/F1.rmdup.fa.gz
CONTIGS_LINKS_K19=mccortexF1/k19/contigs_links/F1.rmdup.fa.gz
CONTIGS_POP_K19=mccortexF1/k19/contigs_links/F1.pop.rmdup.fa.gz

# Files at k=25
RAW_GRAPHS_K25=mccortexF1/k25/graphs/F1.raw.ctx
CLEAN_GRAPHS_K25=$(RAW_GRAPHS_K25:.raw.ctx=.clean.ctx)
CLEAN_UNITIGS_K25=$(CLEAN_GRAPHS_K25:.ctx=.unitigs.fa.gz)
RAW_SE_LINKS_K25=mccortexF1/k25/links/F1.se.raw.ctp.gz
RAW_PE_LINKS_K25=mccortexF1/k25/links/F1.pe.raw.ctp.gz
CLEAN_SE_LINKS_K25=$(RAW_SE_LINKS_K25:.raw.ctp.gz=.clean.ctp.gz)
CLEAN_PE_LINKS_K25=$(RAW_PE_LINKS_K25:.raw.ctp.gz=.clean.ctp.gz)
CONTIGS_PLAIN_K25=mccortexF1/k25/contigs_plain/F1.rmdup.fa.gz
CONTIGS_LINKS_K25=mccortexF1/k25/contigs_links/F1.rmdup.fa.gz
CONTIGS_POP_K25=mccortexF1/k25/contigs_links/F1.pop.rmdup.fa.gz

# Files at k=31
RAW_GRAPHS_K31=mccortexF1/k31/graphs/F1.raw.ctx
CLEAN_GRAPHS_K31=$(RAW_GRAPHS_K31:.raw.ctx=.clean.ctx)
CLEAN_UNITIGS_K31=$(CLEAN_GRAPHS_K31:.ctx=.unitigs.fa.gz)
RAW_SE_LINKS_K31=mccortexF1/k31/links/F1.se.raw.ctp.gz
RAW_PE_LINKS_K31=mccortexF1/k31/links/F1.pe.raw.ctp.gz
CLEAN_SE_LINKS_K31=$(RAW_SE_LINKS_K31:.raw.ctp.gz=.clean.ctp.gz)
CLEAN_PE_LINKS_K31=$(RAW_PE_LINKS_K31:.raw.ctp.gz=.clean.ctp.gz)
CONTIGS_PLAIN_K31=mccortexF1/k31/contigs_plain/F1.rmdup.fa.gz
CONTIGS_LINKS_K31=mccortexF1/k31/contigs_links/F1.rmdup.fa.gz
CONTIGS_POP_K31=mccortexF1/k31/contigs_links/F1.pop.rmdup.fa.gz

# Files at k=47
RAW_GRAPHS_K47=mccortexF1/k47/graphs/F1.raw.ctx
CLEAN_GRAPHS_K47=$(RAW_GRAPHS_K47:.raw.ctx=.clean.ctx)
CLEAN_UNITIGS_K47=$(CLEAN_GRAPHS_K47:.ctx=.unitigs.fa.gz)
RAW_SE_LINKS_K47=mccortexF1/k47/links/F1.se.raw.ctp.gz
RAW_PE_LINKS_K47=mccortexF1/k47/links/F1.pe.raw.ctp.gz
CLEAN_SE_LINKS_K47=$(RAW_SE_LINKS_K47:.raw.ctp.gz=.clean.ctp.gz)
CLEAN_PE_LINKS_K47=$(RAW_PE_LINKS_K47:.raw.ctp.gz=.clean.ctp.gz)
CONTIGS_PLAIN_K47=mccortexF1/k47/contigs_plain/F1.rmdup.fa.gz
CONTIGS_LINKS_K47=mccortexF1/k47/contigs_links/F1.rmdup.fa.gz
CONTIGS_POP_K47=mccortexF1/k47/contigs_links/F1.pop.rmdup.fa.gz


ifdef LINKS
	ifdef JOINT
		BUBBLES_K19=mccortexF1/k19/bubbles_links/joint.bub.gz
		BREAKPOINTS_K19=
		BUBBLES_K25=mccortexF1/k25/bubbles_links/joint.bub.gz
		BREAKPOINTS_K25=
		BUBBLES_K31=mccortexF1/k31/bubbles_links/joint.bub.gz
		BREAKPOINTS_K31=
		BUBBLES_K47=mccortexF1/k47/bubbles_links/joint.bub.gz
		BREAKPOINTS_K47=
		BUBBLES_UNION_VCFS=
		BREAKPOINTS_UNION_VCFS=
	else
		BUBBLES_K19=mccortexF1/k19/bubbles_links/F1.bub.gz
		BREAKPOINTS_K19=mccortexF1/k19/breakpoints_links/F1.brk.gz
		BUBBLES_K25=mccortexF1/k25/bubbles_links/F1.bub.gz
		BREAKPOINTS_K25=mccortexF1/k25/breakpoints_links/F1.brk.gz
		BUBBLES_K31=mccortexF1/k31/bubbles_links/F1.bub.gz
		BREAKPOINTS_K31=mccortexF1/k31/breakpoints_links/F1.brk.gz
		BUBBLES_K47=mccortexF1/k47/bubbles_links/F1.bub.gz
		BREAKPOINTS_K47=mccortexF1/k47/breakpoints_links/F1.brk.gz
		BUBBLES_UNION_VCFS=
		BREAKPOINTS_UNION_VCFS=
	endif
	CONTIGS=$(CONTIGS_PLAIN_K19) $(CONTIGS_PLAIN_K25) $(CONTIGS_PLAIN_K31) $(CONTIGS_PLAIN_K47)
else
	ifdef JOINT
		BUBBLES_K19=mccortexF1/k19/bubbles_plain/joint.bub.gz
		BREAKPOINTS_K19=
		BUBBLES_K25=mccortexF1/k25/bubbles_plain/joint.bub.gz
		BREAKPOINTS_K25=
		BUBBLES_K31=mccortexF1/k31/bubbles_plain/joint.bub.gz
		BREAKPOINTS_K31=
		BUBBLES_K47=mccortexF1/k47/bubbles_plain/joint.bub.gz
		BREAKPOINTS_K47=
		BUBBLES_UNION_VCFS=
		BREAKPOINTS_UNION_VCFS=
	else
		BUBBLES_K19=mccortexF1/k19/bubbles_plain/F1.bub.gz
		BREAKPOINTS_K19=mccortexF1/k19/breakpoints_plain/F1.brk.gz
		BUBBLES_K25=mccortexF1/k25/bubbles_plain/F1.bub.gz
		BREAKPOINTS_K25=mccortexF1/k25/breakpoints_plain/F1.brk.gz
		BUBBLES_K31=mccortexF1/k31/bubbles_plain/F1.bub.gz
		BREAKPOINTS_K31=mccortexF1/k31/breakpoints_plain/F1.brk.gz
		BUBBLES_K47=mccortexF1/k47/bubbles_plain/F1.bub.gz
		BREAKPOINTS_K47=mccortexF1/k47/breakpoints_plain/F1.brk.gz
		BUBBLES_UNION_VCFS=
		BREAKPOINTS_UNION_VCFS=
	endif
	CONTIGS=$(CONTIGS_LINKS_K19) $(CONTIGS_LINKS_K25) $(CONTIGS_LINKS_K31) $(CONTIGS_LINKS_K47)
endif

RAW_GRAPHS=$(RAW_GRAPHS_K19) $(RAW_GRAPHS_K25) $(RAW_GRAPHS_K31) $(RAW_GRAPHS_K47)
CLEAN_GRAPHS=$(RAW_GRAPHS:.raw.ctx=.clean.ctx)
CLEAN_UNITIGS=$(CLEAN_GRAPHS:.ctx=.unitigs.fa.gz)
RAW_LINKS=$(RAW_SE_LINKS_K19) $(RAW_PE_LINKS_K19)  $(RAW_SE_LINKS_K25) $(RAW_PE_LINKS_K25)  $(RAW_SE_LINKS_K31) $(RAW_PE_LINKS_K31)  $(RAW_SE_LINKS_K47) $(RAW_PE_LINKS_K47) 
CLEAN_SE_LINKS=$(CLEAN_SE_LINKS_K19) $(CLEAN_SE_LINKS_K25) $(CLEAN_SE_LINKS_K31) $(CLEAN_SE_LINKS_K47)
CLEAN_PE_LINKS=$(CLEAN_PE_LINKS_K19) $(CLEAN_PE_LINKS_K25) $(CLEAN_PE_LINKS_K31) $(CLEAN_PE_LINKS_K47)
FINAL_LINKS=$(CLEAN_PE_LINKS)
BUBBLES=$(BUBBLES_K19) $(BUBBLES_K25) $(BUBBLES_K31) $(BUBBLES_K47)
BREAKPOINTS=$(BREAKPOINTS_K19) $(BREAKPOINTS_K25) $(BREAKPOINTS_K31) $(BREAKPOINTS_K47)
CONTIGS_POP=$(CONTIGS_POP_K19) $(CONTIGS_POP_K25) $(CONTIGS_POP_K31) $(CONTIGS_POP_K47)
BREAKPOINTS_GENO_VCFS=$(subst .vcf,.geno.vcf,$(BREAKPOINTS_UNION_VCFS))
BUBBLES_GENO_VCFS=$(subst .vcf,.geno.vcf,$(BUBBLES_UNION_VCFS))


# Files to merge to create various union VCFs
# .csi are index files (for VCF in this case)
BUBBLES_JOINT_PLAIN_VCFS=mccortexF1/k19/bubbles_plain/joint.bub.norm.vcf.gz mccortexF1/k25/bubbles_plain/joint.bub.norm.vcf.gz mccortexF1/k31/bubbles_plain/joint.bub.norm.vcf.gz mccortexF1/k47/bubbles_plain/joint.bub.norm.vcf.gz
BUBBLES_JOINT_LINKS_VCFS=mccortexF1/k19/bubbles_links/joint.bub.norm.vcf.gz mccortexF1/k25/bubbles_links/joint.bub.norm.vcf.gz mccortexF1/k31/bubbles_links/joint.bub.norm.vcf.gz mccortexF1/k47/bubbles_links/joint.bub.norm.vcf.gz
BREAKPOINTS_JOINT_PLAIN_VCFS=mccortexF1/k19/breakpoints_plain/joint.brk.norm.vcf.gz mccortexF1/k25/breakpoints_plain/joint.brk.norm.vcf.gz mccortexF1/k31/breakpoints_plain/joint.brk.norm.vcf.gz mccortexF1/k47/breakpoints_plain/joint.brk.norm.vcf.gz
BREAKPOINTS_JOINT_LINKS_VCFS=mccortexF1/k19/breakpoints_links/joint.brk.norm.vcf.gz mccortexF1/k25/breakpoints_links/joint.brk.norm.vcf.gz mccortexF1/k31/breakpoints_links/joint.brk.norm.vcf.gz mccortexF1/k47/breakpoints_links/joint.brk.norm.vcf.gz
BUBBLES_1BY1_PLAIN_VCFS=mccortexF1/k19/bubbles_plain/F1.bub.norm.vcf.gz mccortexF1/k25/bubbles_plain/F1.bub.norm.vcf.gz mccortexF1/k31/bubbles_plain/F1.bub.norm.vcf.gz mccortexF1/k47/bubbles_plain/F1.bub.norm.vcf.gz
BUBBLES_1BY1_LINKS_VCFS=mccortexF1/k19/bubbles_links/F1.bub.norm.vcf.gz mccortexF1/k25/bubbles_links/F1.bub.norm.vcf.gz mccortexF1/k31/bubbles_links/F1.bub.norm.vcf.gz mccortexF1/k47/bubbles_links/F1.bub.norm.vcf.gz
BREAKPOINTS_1BY1_PLAIN_VCFS=mccortexF1/k19/breakpoints_plain/F1.brk.norm.vcf.gz mccortexF1/k25/breakpoints_plain/F1.brk.norm.vcf.gz mccortexF1/k31/breakpoints_plain/F1.brk.norm.vcf.gz mccortexF1/k47/breakpoints_plain/F1.brk.norm.vcf.gz
BREAKPOINTS_1BY1_LINKS_VCFS=mccortexF1/k19/breakpoints_links/F1.brk.norm.vcf.gz mccortexF1/k25/breakpoints_links/F1.brk.norm.vcf.gz mccortexF1/k31/breakpoints_links/F1.brk.norm.vcf.gz mccortexF1/k47/breakpoints_links/F1.brk.norm.vcf.gz

BUBBLES_JOINT_LINKS_CSIS=$(BUBBLES_JOINT_LINKS_VCFS:.vcf.gz=.vcf.gz.csi)
BUBBLES_JOINT_PLAIN_CSIS=$(BUBBLES_JOINT_PLAIN_VCFS:.vcf.gz=.vcf.gz.csi)
BREAKPOINTS_JOINT_LINKS_CSIS=$(BREAKPOINTS_JOINT_LINKS_VCFS:.vcf.gz=.vcf.gz.csi)
BREAKPOINTS_JOINT_PLAIN_CSIS=$(BREAKPOINTS_JOINT_PLAIN_VCFS:.vcf.gz=.vcf.gz.csi)
BUBBLES_1BY1_LINKS_CSIS=$(BUBBLES_1BY1_LINKS_VCFS:.vcf.gz=.vcf.gz.csi)
BUBBLES_1BY1_PLAIN_CSIS=$(BUBBLES_1BY1_PLAIN_VCFS:.vcf.gz=.vcf.gz.csi)
BREAKPOINTS_1BY1_LINKS_CSIS=$(BREAKPOINTS_1BY1_LINKS_VCFS:.vcf.gz=.vcf.gz.csi)
BREAKPOINTS_1BY1_PLAIN_CSIS=$(BREAKPOINTS_1BY1_PLAIN_VCFS:.vcf.gz=.vcf.gz.csi)

DIRS=mccortexF1/k19/graphs/ mccortexF1/k19/links/ mccortexF1/k19/contigs_plain/ mccortexF1/k19/contigs_links/ mccortexF1/k19/bubbles_plain/ mccortexF1/k19/bubbles_links/ mccortexF1/k19/breakpoints_plain/ mccortexF1/k19/breakpoints_links/ mccortexF1/k19/ref/ mccortexF1/k19/vcfcov/ \
     mccortexF1/k25/graphs/ mccortexF1/k25/links/ mccortexF1/k25/contigs_plain/ mccortexF1/k25/contigs_links/ mccortexF1/k25/bubbles_plain/ mccortexF1/k25/bubbles_links/ mccortexF1/k25/breakpoints_plain/ mccortexF1/k25/breakpoints_links/ mccortexF1/k25/ref/ mccortexF1/k25/vcfcov/ \
     mccortexF1/k31/graphs/ mccortexF1/k31/links/ mccortexF1/k31/contigs_plain/ mccortexF1/k31/contigs_links/ mccortexF1/k31/bubbles_plain/ mccortexF1/k31/bubbles_links/ mccortexF1/k31/breakpoints_plain/ mccortexF1/k31/breakpoints_links/ mccortexF1/k31/ref/ mccortexF1/k31/vcfcov/ \
     mccortexF1/k47/graphs/ mccortexF1/k47/links/ mccortexF1/k47/contigs_plain/ mccortexF1/k47/contigs_links/ mccortexF1/k47/bubbles_plain/ mccortexF1/k47/bubbles_links/ mccortexF1/k47/breakpoints_plain/ mccortexF1/k47/breakpoints_links/ mccortexF1/k47/ref/ mccortexF1/k47/vcfcov/ \
     mccortexF1/vcfs

# Referece Graphs
REF_GRAPH_K19=
REF_GRAPH_K25=
REF_GRAPH_K31=
REF_GRAPH_K47=

# Mark all dependencies as secondary
# It means don't re-run if the dependency file disappears -- allows us to delete unused files
.SECONDARY:

# Delete files if their recipe fails
.DELETE_ON_ERROR:

# Remove in-built rules for certain file suffixes
.SUFFIXES:

.DEFAULT_GOAL = bubbles

all: bubbles unitigs | checks

graphs: $(CLEAN_GRAPHS) | checks

unitigs: $(CLEAN_UNITIGS) | checks

links: $(FINAL_LINKS) | checks

bubbles: $(BUBBLES) | checks
breakpoints:
	@echo 'Need to give make-pipeline.pl --ref <r.fa> to run breakpoints 2>1 && false

bub-vcf:
	@echo 'Need to give make-pipeline.pl --ref <r.fa> to run bub-vcf 2>1 && false

brk-vcf:
	@echo 'Need to give make-pipeline.pl --ref <r.fa> to run brk-vcf 2>1 && false

geno-vcfs:
	@echo 'Need to give make-pipeline.pl --ref <r.fa> to run geno-vcfs 2>1 && false

vcfs:
	@echo 'Need to give make-pipeline.pl --ref <r.fa> to run vcfs 2>1 && false


contigs: $(CONTIGS) | checks
contigs-pop: $(CONTIGS_POP) | checks

checks:
	@[ -x $(CTXDIR)/bin/mccortex63 ] || ( echo 'Error: Please compile McCortex with `make MAXK=63 all` or pass CTXDIR=<path/to/mccortex/>' 1>&2 && false )
	@[ -x $(CTXDIR)/bin/mccortex31 ] || ( echo 'Error: Please compile McCortex with `make MAXK=31 all` or pass CTXDIR=<path/to/mccortex/>' 1>&2 && false )
	@[ -x $(CTXDIR)/libs/bcftools/bcftools ] || ( echo 'Error: Please compile McCortex with `make all` or pass CTXDIR=<path/to/mccortex/>' 1>&2 && false )

dirs: $(DIRS)

$(DIRS):
	mkdir -p $@

clean:
	@echo To delete: rm -rf mccortexF1

.PHONY: all clean checks graphs links unitigs contigs contigs-pop
.PHONY: bubbles breakpoints
.PHONY: bub-vcf brk-vcf bub-geno-vcf brk-geno-vcf geno-vcfs plain-vcfs vcfs

# Print any variable with `make -f file.mk print-VARNAME`
print-%:
	@echo '$*=$($*)'

#
# Build graph files
#
# building sample graphs at k=19
mccortexF1/k19/graphs/F1.raw.ctx: tadpole/tadpole.M.fastq.gz tadpole/tadpole.1.fastq.gz tadpole/tadpole.2.fastq.gz | dirs
	$(CTXDIR)/bin/mccortex31 build $(BUILD_ARGS) $(CTX_ARGS) -k 19 --sample F1 --seq tadpole/tadpole.M.fastq.gz --seq2 tadpole/tadpole.1.fastq.gz:tadpole/tadpole.2.fastq.gz $@ >& $@.log

# Generate individual graphs for sample assembly with high covg indiv.
# Clean and pop bubbles at k=19
mccortexF1/k19/graphs/%.pop.raw.cov.csv: mccortexF1/k19/graphs/%.pop.clean.ctx
mccortexF1/k19/graphs/%.pop.clean.ctx: mccortexF1/k19/graphs/%.raw.ctx
	$(CTXDIR)/bin/mccortex31 clean $(CTX_ARGS) $(KMER_CLEANING_ARGS) --covg-before mccortexF1/k19/graphs/$*.pop.raw.cov.csv -o $@ $< >& $@.log
mccortexF1/k19/graphs/%.pop.clean.ctx: mccortexF1/k19/graphs/%.pop.clean.ctx
	$(CTXDIR)/bin/mccortex31 popbubbles $(CTX_ARGS) $(POP_BUBBLES_ARGS) -o $@ $< >& $@.log

# sample graph cleaning at k=19
mccortexF1/k19/graphs/%.raw.cov.csv mccortexF1/k19/graphs/%.clean.cov.csv mccortexF1/k19/graphs/%.raw.len.csv mccortexF1/k19/graphs/%.clean.len.csv mccortexF1/k19/graphs/%.clean.ctx.log mccortexF1/k19/graphs/%.clean.ctx: mccortexF1/k19/graphs/%.raw.ctx
	$(CTXDIR)/bin/mccortex31 clean $(CTX_ARGS) $(KMER_CLEANING_ARGS) --covg-before mccortexF1/k19/graphs/$*.raw.cov.csv --covg-after mccortexF1/k19/graphs/$*.clean.cov.csv --len-before mccortexF1/k19/graphs/$*.raw.len.csv --len-after mccortexF1/k19/graphs/$*.clean.len.csv -o mccortexF1/k19/graphs/$*.clean.ctx mccortexF1/k19/graphs/$*.raw.ctx >& mccortexF1/k19/graphs/$*.clean.ctx.log
	$(CTXDIR)/bin/mccortex31 inferedges $(CTX_ARGS) mccortexF1/k19/graphs/$*.clean.ctx >& mccortexF1/k19/graphs/$*.inferedges.ctx.log

mccortexF1/k19/graphs/%.clean.nkmers: mccortexF1/k19/graphs/%.clean.ctx.log
	grep -oE 'Dumped [0-9,]+ kmers' $< | tr -d ',' | grep -oE '[0-9]+' > $@

mccortexF1/k19/graphs/%.clean.kmercov: mccortexF1/k19/graphs/%.clean.ctx mccortexF1/k19/graphs/%.clean.nkmers
	$(CTXKCOV) 19 `cat mccortexF1/k19/graphs/$*.clean.nkmers` $< > $@ 2> $@.log

# sample graph unitigs at k=19
mccortexF1/k19/graphs/%.clean.unitigs.fa.gz: mccortexF1/k19/graphs/%.clean.ctx
	($(CTXDIR)/bin/mccortex31 unitigs $(CTX_ARGS) $< | $(BGZIP) -c > $@) 2> $@.log

# building sample graphs at k=25
mccortexF1/k25/graphs/F1.raw.ctx: tadpole/tadpole.M.fastq.gz tadpole/tadpole.1.fastq.gz tadpole/tadpole.2.fastq.gz | dirs
	$(CTXDIR)/bin/mccortex31 build $(BUILD_ARGS) $(CTX_ARGS) -k 25 --sample F1 --seq tadpole/tadpole.M.fastq.gz --seq2 tadpole/tadpole.1.fastq.gz:tadpole/tadpole.2.fastq.gz $@ >& $@.log

# Generate individual graphs for sample assembly with high covg indiv.
# Clean and pop bubbles at k=25
mccortexF1/k25/graphs/%.pop.raw.cov.csv: mccortexF1/k25/graphs/%.pop.clean.ctx
mccortexF1/k25/graphs/%.pop.clean.ctx: mccortexF1/k25/graphs/%.raw.ctx
	$(CTXDIR)/bin/mccortex31 clean $(CTX_ARGS) $(KMER_CLEANING_ARGS) --covg-before mccortexF1/k25/graphs/$*.pop.raw.cov.csv -o $@ $< >& $@.log
mccortexF1/k25/graphs/%.pop.clean.ctx: mccortexF1/k25/graphs/%.pop.clean.ctx
	$(CTXDIR)/bin/mccortex31 popbubbles $(CTX_ARGS) $(POP_BUBBLES_ARGS) -o $@ $< >& $@.log

# sample graph cleaning at k=25
mccortexF1/k25/graphs/%.raw.cov.csv mccortexF1/k25/graphs/%.clean.cov.csv mccortexF1/k25/graphs/%.raw.len.csv mccortexF1/k25/graphs/%.clean.len.csv mccortexF1/k25/graphs/%.clean.ctx.log mccortexF1/k25/graphs/%.clean.ctx: mccortexF1/k25/graphs/%.raw.ctx
	$(CTXDIR)/bin/mccortex31 clean $(CTX_ARGS) $(KMER_CLEANING_ARGS) --covg-before mccortexF1/k25/graphs/$*.raw.cov.csv --covg-after mccortexF1/k25/graphs/$*.clean.cov.csv --len-before mccortexF1/k25/graphs/$*.raw.len.csv --len-after mccortexF1/k25/graphs/$*.clean.len.csv -o mccortexF1/k25/graphs/$*.clean.ctx mccortexF1/k25/graphs/$*.raw.ctx >& mccortexF1/k25/graphs/$*.clean.ctx.log
	$(CTXDIR)/bin/mccortex31 inferedges $(CTX_ARGS) mccortexF1/k25/graphs/$*.clean.ctx >& mccortexF1/k25/graphs/$*.inferedges.ctx.log

mccortexF1/k25/graphs/%.clean.nkmers: mccortexF1/k25/graphs/%.clean.ctx.log
	grep -oE 'Dumped [0-9,]+ kmers' $< | tr -d ',' | grep -oE '[0-9]+' > $@

mccortexF1/k25/graphs/%.clean.kmercov: mccortexF1/k25/graphs/%.clean.ctx mccortexF1/k25/graphs/%.clean.nkmers
	$(CTXKCOV) 25 `cat mccortexF1/k25/graphs/$*.clean.nkmers` $< > $@ 2> $@.log

# sample graph unitigs at k=25
mccortexF1/k25/graphs/%.clean.unitigs.fa.gz: mccortexF1/k25/graphs/%.clean.ctx
	($(CTXDIR)/bin/mccortex31 unitigs $(CTX_ARGS) $< | $(BGZIP) -c > $@) 2> $@.log

# building sample graphs at k=31
mccortexF1/k31/graphs/F1.raw.ctx: tadpole/tadpole.M.fastq.gz tadpole/tadpole.1.fastq.gz tadpole/tadpole.2.fastq.gz | dirs
	$(CTXDIR)/bin/mccortex31 build $(BUILD_ARGS) $(CTX_ARGS) -k 31 --sample F1 --seq tadpole/tadpole.M.fastq.gz --seq2 tadpole/tadpole.1.fastq.gz:tadpole/tadpole.2.fastq.gz $@ >& $@.log

# Generate individual graphs for sample assembly with high covg indiv.
# Clean and pop bubbles at k=31
mccortexF1/k31/graphs/%.pop.raw.cov.csv: mccortexF1/k31/graphs/%.pop.clean.ctx
mccortexF1/k31/graphs/%.pop.clean.ctx: mccortexF1/k31/graphs/%.raw.ctx
	$(CTXDIR)/bin/mccortex31 clean $(CTX_ARGS) $(KMER_CLEANING_ARGS) --covg-before mccortexF1/k31/graphs/$*.pop.raw.cov.csv -o $@ $< >& $@.log
mccortexF1/k31/graphs/%.pop.clean.ctx: mccortexF1/k31/graphs/%.pop.clean.ctx
	$(CTXDIR)/bin/mccortex31 popbubbles $(CTX_ARGS) $(POP_BUBBLES_ARGS) -o $@ $< >& $@.log

# sample graph cleaning at k=31
mccortexF1/k31/graphs/%.raw.cov.csv mccortexF1/k31/graphs/%.clean.cov.csv mccortexF1/k31/graphs/%.raw.len.csv mccortexF1/k31/graphs/%.clean.len.csv mccortexF1/k31/graphs/%.clean.ctx.log mccortexF1/k31/graphs/%.clean.ctx: mccortexF1/k31/graphs/%.raw.ctx
	$(CTXDIR)/bin/mccortex31 clean $(CTX_ARGS) $(KMER_CLEANING_ARGS) --covg-before mccortexF1/k31/graphs/$*.raw.cov.csv --covg-after mccortexF1/k31/graphs/$*.clean.cov.csv --len-before mccortexF1/k31/graphs/$*.raw.len.csv --len-after mccortexF1/k31/graphs/$*.clean.len.csv -o mccortexF1/k31/graphs/$*.clean.ctx mccortexF1/k31/graphs/$*.raw.ctx >& mccortexF1/k31/graphs/$*.clean.ctx.log
	$(CTXDIR)/bin/mccortex31 inferedges $(CTX_ARGS) mccortexF1/k31/graphs/$*.clean.ctx >& mccortexF1/k31/graphs/$*.inferedges.ctx.log

mccortexF1/k31/graphs/%.clean.nkmers: mccortexF1/k31/graphs/%.clean.ctx.log
	grep -oE 'Dumped [0-9,]+ kmers' $< | tr -d ',' | grep -oE '[0-9]+' > $@

mccortexF1/k31/graphs/%.clean.kmercov: mccortexF1/k31/graphs/%.clean.ctx mccortexF1/k31/graphs/%.clean.nkmers
	$(CTXKCOV) 31 `cat mccortexF1/k31/graphs/$*.clean.nkmers` $< > $@ 2> $@.log

# sample graph unitigs at k=31
mccortexF1/k31/graphs/%.clean.unitigs.fa.gz: mccortexF1/k31/graphs/%.clean.ctx
	($(CTXDIR)/bin/mccortex31 unitigs $(CTX_ARGS) $< | $(BGZIP) -c > $@) 2> $@.log

# building sample graphs at k=47
mccortexF1/k47/graphs/F1.raw.ctx: tadpole/tadpole.M.fastq.gz tadpole/tadpole.1.fastq.gz tadpole/tadpole.2.fastq.gz | dirs
	$(CTXDIR)/bin/mccortex63 build $(BUILD_ARGS) $(CTX_ARGS) -k 47 --sample F1 --seq tadpole/tadpole.M.fastq.gz --seq2 tadpole/tadpole.1.fastq.gz:tadpole/tadpole.2.fastq.gz $@ >& $@.log

# Generate individual graphs for sample assembly with high covg indiv.
# Clean and pop bubbles at k=47
mccortexF1/k47/graphs/%.pop.raw.cov.csv: mccortexF1/k47/graphs/%.pop.clean.ctx
mccortexF1/k47/graphs/%.pop.clean.ctx: mccortexF1/k47/graphs/%.raw.ctx
	$(CTXDIR)/bin/mccortex63 clean $(CTX_ARGS) $(KMER_CLEANING_ARGS) --covg-before mccortexF1/k47/graphs/$*.pop.raw.cov.csv -o $@ $< >& $@.log
mccortexF1/k47/graphs/%.pop.clean.ctx: mccortexF1/k47/graphs/%.pop.clean.ctx
	$(CTXDIR)/bin/mccortex63 popbubbles $(CTX_ARGS) $(POP_BUBBLES_ARGS) -o $@ $< >& $@.log

# sample graph cleaning at k=47
mccortexF1/k47/graphs/%.raw.cov.csv mccortexF1/k47/graphs/%.clean.cov.csv mccortexF1/k47/graphs/%.raw.len.csv mccortexF1/k47/graphs/%.clean.len.csv mccortexF1/k47/graphs/%.clean.ctx.log mccortexF1/k47/graphs/%.clean.ctx: mccortexF1/k47/graphs/%.raw.ctx
	$(CTXDIR)/bin/mccortex63 clean $(CTX_ARGS) $(KMER_CLEANING_ARGS) --covg-before mccortexF1/k47/graphs/$*.raw.cov.csv --covg-after mccortexF1/k47/graphs/$*.clean.cov.csv --len-before mccortexF1/k47/graphs/$*.raw.len.csv --len-after mccortexF1/k47/graphs/$*.clean.len.csv -o mccortexF1/k47/graphs/$*.clean.ctx mccortexF1/k47/graphs/$*.raw.ctx >& mccortexF1/k47/graphs/$*.clean.ctx.log
	$(CTXDIR)/bin/mccortex63 inferedges $(CTX_ARGS) mccortexF1/k47/graphs/$*.clean.ctx >& mccortexF1/k47/graphs/$*.inferedges.ctx.log

mccortexF1/k47/graphs/%.clean.nkmers: mccortexF1/k47/graphs/%.clean.ctx.log
	grep -oE 'Dumped [0-9,]+ kmers' $< | tr -d ',' | grep -oE '[0-9]+' > $@

mccortexF1/k47/graphs/%.clean.kmercov: mccortexF1/k47/graphs/%.clean.ctx mccortexF1/k47/graphs/%.clean.nkmers
	$(CTXKCOV) 47 `cat mccortexF1/k47/graphs/$*.clean.nkmers` $< > $@ 2> $@.log

# sample graph unitigs at k=47
mccortexF1/k47/graphs/%.clean.unitigs.fa.gz: mccortexF1/k47/graphs/%.clean.ctx
	($(CTXDIR)/bin/mccortex63 unitigs $(CTX_ARGS) $< | $(BGZIP) -c > $@) 2> $@.log

#
# Generate link files
#
# creating links at k=19
mccortexF1/k19/links/F1.se.raw.ctp.gz: mccortexF1/k19/graphs/F1.clean.ctx tadpole/tadpole.M.fastq.gz tadpole/tadpole.1.fastq.gz tadpole/tadpole.2.fastq.gz | dirs
	$(CTXDIR)/bin/mccortex31 thread $(CTX_ARGS) $(THREAD_ARGS) --seq tadpole/tadpole.M.fastq.gz --seq tadpole/tadpole.1.fastq.gz --seq tadpole/tadpole.2.fastq.gz -o $@ $< >& $@.log

mccortexF1/k19/links/F1.pe.raw.ctp.gz: mccortexF1/k19/graphs/F1.clean.ctx mccortexF1/k19/links/F1.se.clean.ctp.gz tadpole/tadpole.1.fastq.gz tadpole/tadpole.2.fastq.gz | dirs
	$(CTXDIR)/bin/mccortex31 thread $(CTX_ARGS) $(THREAD_ARGS) -p mccortexF1/k19/links/F1.se.clean.ctp.gz --zero-paths --seq2 tadpole/tadpole.1.fastq.gz:tadpole/tadpole.2.fastq.gz -o $@ $< >& $@.log

mccortexF1/k19/links/F1.pop.se.raw.ctp.gz: mccortexF1/k19/graphs/F1.pop.clean.ctx tadpole/tadpole.M.fastq.gz tadpole/tadpole.1.fastq.gz tadpole/tadpole.2.fastq.gz | dirs
	$(CTXDIR)/bin/mccortex31 thread $(CTX_ARGS) $(THREAD_ARGS) --seq tadpole/tadpole.M.fastq.gz --seq tadpole/tadpole.1.fastq.gz --seq tadpole/tadpole.2.fastq.gz -o $@ $< >& $@.log

mccortexF1/k19/links/F1.pop.pe.raw.ctp.gz: mccortexF1/k19/graphs/F1.pop.clean.ctx mccortexF1/k19/links/F1.pop.se.clean.ctp.gz tadpole/tadpole.1.fastq.gz tadpole/tadpole.2.fastq.gz | dirs
	$(CTXDIR)/bin/mccortex31 thread $(CTX_ARGS) $(THREAD_ARGS) -p mccortexF1/k19/links/F1.pop.se.clean.ctp.gz --zero-paths --seq2 tadpole/tadpole.1.fastq.gz:tadpole/tadpole.2.fastq.gz -o $@ $< >& $@.log

# link cleaning at k=19
mccortexF1/k19/links/%.links.csv: mccortexF1/k19/links/%.thresh.txt
mccortexF1/k19/links/%.thresh.txt: mccortexF1/k19/links/%.raw.ctp.gz
	$(CTXDIR)/bin/mccortex31 links $(LINK_CLEANING_ARGS) --covg-hist mccortexF1/k19/links/$*.links.csv --threshold $@ $< >& $@.log

mccortexF1/k19/links/%.clean.ctp.gz: mccortexF1/k19/links/%.raw.ctp.gz mccortexF1/k19/links/%.thresh.txt
	THRESH=`tail -1 mccortexF1/k19/links/$*.thresh.txt | grep -oE '[0-9]+$$'`; \
$(CTXDIR)/bin/mccortex31 links -c "$$THRESH" -o $@ $< >& $@.log

# creating links at k=25
mccortexF1/k25/links/F1.se.raw.ctp.gz: mccortexF1/k25/graphs/F1.clean.ctx tadpole/tadpole.M.fastq.gz tadpole/tadpole.1.fastq.gz tadpole/tadpole.2.fastq.gz | dirs
	$(CTXDIR)/bin/mccortex31 thread $(CTX_ARGS) $(THREAD_ARGS) --seq tadpole/tadpole.M.fastq.gz --seq tadpole/tadpole.1.fastq.gz --seq tadpole/tadpole.2.fastq.gz -o $@ $< >& $@.log

mccortexF1/k25/links/F1.pe.raw.ctp.gz: mccortexF1/k25/graphs/F1.clean.ctx mccortexF1/k25/links/F1.se.clean.ctp.gz tadpole/tadpole.1.fastq.gz tadpole/tadpole.2.fastq.gz | dirs
	$(CTXDIR)/bin/mccortex31 thread $(CTX_ARGS) $(THREAD_ARGS) -p mccortexF1/k25/links/F1.se.clean.ctp.gz --zero-paths --seq2 tadpole/tadpole.1.fastq.gz:tadpole/tadpole.2.fastq.gz -o $@ $< >& $@.log

mccortexF1/k25/links/F1.pop.se.raw.ctp.gz: mccortexF1/k25/graphs/F1.pop.clean.ctx tadpole/tadpole.M.fastq.gz tadpole/tadpole.1.fastq.gz tadpole/tadpole.2.fastq.gz | dirs
	$(CTXDIR)/bin/mccortex31 thread $(CTX_ARGS) $(THREAD_ARGS) --seq tadpole/tadpole.M.fastq.gz --seq tadpole/tadpole.1.fastq.gz --seq tadpole/tadpole.2.fastq.gz -o $@ $< >& $@.log

mccortexF1/k25/links/F1.pop.pe.raw.ctp.gz: mccortexF1/k25/graphs/F1.pop.clean.ctx mccortexF1/k25/links/F1.pop.se.clean.ctp.gz tadpole/tadpole.1.fastq.gz tadpole/tadpole.2.fastq.gz | dirs
	$(CTXDIR)/bin/mccortex31 thread $(CTX_ARGS) $(THREAD_ARGS) -p mccortexF1/k25/links/F1.pop.se.clean.ctp.gz --zero-paths --seq2 tadpole/tadpole.1.fastq.gz:tadpole/tadpole.2.fastq.gz -o $@ $< >& $@.log

# link cleaning at k=25
mccortexF1/k25/links/%.links.csv: mccortexF1/k25/links/%.thresh.txt
mccortexF1/k25/links/%.thresh.txt: mccortexF1/k25/links/%.raw.ctp.gz
	$(CTXDIR)/bin/mccortex31 links $(LINK_CLEANING_ARGS) --covg-hist mccortexF1/k25/links/$*.links.csv --threshold $@ $< >& $@.log

mccortexF1/k25/links/%.clean.ctp.gz: mccortexF1/k25/links/%.raw.ctp.gz mccortexF1/k25/links/%.thresh.txt
	THRESH=`tail -1 mccortexF1/k25/links/$*.thresh.txt | grep -oE '[0-9]+$$'`; \
$(CTXDIR)/bin/mccortex31 links -c "$$THRESH" -o $@ $< >& $@.log

# creating links at k=31
mccortexF1/k31/links/F1.se.raw.ctp.gz: mccortexF1/k31/graphs/F1.clean.ctx tadpole/tadpole.M.fastq.gz tadpole/tadpole.1.fastq.gz tadpole/tadpole.2.fastq.gz | dirs
	$(CTXDIR)/bin/mccortex31 thread $(CTX_ARGS) $(THREAD_ARGS) --seq tadpole/tadpole.M.fastq.gz --seq tadpole/tadpole.1.fastq.gz --seq tadpole/tadpole.2.fastq.gz -o $@ $< >& $@.log

mccortexF1/k31/links/F1.pe.raw.ctp.gz: mccortexF1/k31/graphs/F1.clean.ctx mccortexF1/k31/links/F1.se.clean.ctp.gz tadpole/tadpole.1.fastq.gz tadpole/tadpole.2.fastq.gz | dirs
	$(CTXDIR)/bin/mccortex31 thread $(CTX_ARGS) $(THREAD_ARGS) -p mccortexF1/k31/links/F1.se.clean.ctp.gz --zero-paths --seq2 tadpole/tadpole.1.fastq.gz:tadpole/tadpole.2.fastq.gz -o $@ $< >& $@.log

mccortexF1/k31/links/F1.pop.se.raw.ctp.gz: mccortexF1/k31/graphs/F1.pop.clean.ctx tadpole/tadpole.M.fastq.gz tadpole/tadpole.1.fastq.gz tadpole/tadpole.2.fastq.gz | dirs
	$(CTXDIR)/bin/mccortex31 thread $(CTX_ARGS) $(THREAD_ARGS) --seq tadpole/tadpole.M.fastq.gz --seq tadpole/tadpole.1.fastq.gz --seq tadpole/tadpole.2.fastq.gz -o $@ $< >& $@.log

mccortexF1/k31/links/F1.pop.pe.raw.ctp.gz: mccortexF1/k31/graphs/F1.pop.clean.ctx mccortexF1/k31/links/F1.pop.se.clean.ctp.gz tadpole/tadpole.1.fastq.gz tadpole/tadpole.2.fastq.gz | dirs
	$(CTXDIR)/bin/mccortex31 thread $(CTX_ARGS) $(THREAD_ARGS) -p mccortexF1/k31/links/F1.pop.se.clean.ctp.gz --zero-paths --seq2 tadpole/tadpole.1.fastq.gz:tadpole/tadpole.2.fastq.gz -o $@ $< >& $@.log

# link cleaning at k=31
mccortexF1/k31/links/%.links.csv: mccortexF1/k31/links/%.thresh.txt
mccortexF1/k31/links/%.thresh.txt: mccortexF1/k31/links/%.raw.ctp.gz
	$(CTXDIR)/bin/mccortex31 links $(LINK_CLEANING_ARGS) --covg-hist mccortexF1/k31/links/$*.links.csv --threshold $@ $< >& $@.log

mccortexF1/k31/links/%.clean.ctp.gz: mccortexF1/k31/links/%.raw.ctp.gz mccortexF1/k31/links/%.thresh.txt
	THRESH=`tail -1 mccortexF1/k31/links/$*.thresh.txt | grep -oE '[0-9]+$$'`; \
$(CTXDIR)/bin/mccortex31 links -c "$$THRESH" -o $@ $< >& $@.log

# creating links at k=47
mccortexF1/k47/links/F1.se.raw.ctp.gz: mccortexF1/k47/graphs/F1.clean.ctx tadpole/tadpole.M.fastq.gz tadpole/tadpole.1.fastq.gz tadpole/tadpole.2.fastq.gz | dirs
	$(CTXDIR)/bin/mccortex63 thread $(CTX_ARGS) $(THREAD_ARGS) --seq tadpole/tadpole.M.fastq.gz --seq tadpole/tadpole.1.fastq.gz --seq tadpole/tadpole.2.fastq.gz -o $@ $< >& $@.log

mccortexF1/k47/links/F1.pe.raw.ctp.gz: mccortexF1/k47/graphs/F1.clean.ctx mccortexF1/k47/links/F1.se.clean.ctp.gz tadpole/tadpole.1.fastq.gz tadpole/tadpole.2.fastq.gz | dirs
	$(CTXDIR)/bin/mccortex63 thread $(CTX_ARGS) $(THREAD_ARGS) -p mccortexF1/k47/links/F1.se.clean.ctp.gz --zero-paths --seq2 tadpole/tadpole.1.fastq.gz:tadpole/tadpole.2.fastq.gz -o $@ $< >& $@.log

mccortexF1/k47/links/F1.pop.se.raw.ctp.gz: mccortexF1/k47/graphs/F1.pop.clean.ctx tadpole/tadpole.M.fastq.gz tadpole/tadpole.1.fastq.gz tadpole/tadpole.2.fastq.gz | dirs
	$(CTXDIR)/bin/mccortex63 thread $(CTX_ARGS) $(THREAD_ARGS) --seq tadpole/tadpole.M.fastq.gz --seq tadpole/tadpole.1.fastq.gz --seq tadpole/tadpole.2.fastq.gz -o $@ $< >& $@.log

mccortexF1/k47/links/F1.pop.pe.raw.ctp.gz: mccortexF1/k47/graphs/F1.pop.clean.ctx mccortexF1/k47/links/F1.pop.se.clean.ctp.gz tadpole/tadpole.1.fastq.gz tadpole/tadpole.2.fastq.gz | dirs
	$(CTXDIR)/bin/mccortex63 thread $(CTX_ARGS) $(THREAD_ARGS) -p mccortexF1/k47/links/F1.pop.se.clean.ctp.gz --zero-paths --seq2 tadpole/tadpole.1.fastq.gz:tadpole/tadpole.2.fastq.gz -o $@ $< >& $@.log

# link cleaning at k=47
mccortexF1/k47/links/%.links.csv: mccortexF1/k47/links/%.thresh.txt
mccortexF1/k47/links/%.thresh.txt: mccortexF1/k47/links/%.raw.ctp.gz
	$(CTXDIR)/bin/mccortex63 links $(LINK_CLEANING_ARGS) --covg-hist mccortexF1/k47/links/$*.links.csv --threshold $@ $< >& $@.log

mccortexF1/k47/links/%.clean.ctp.gz: mccortexF1/k47/links/%.raw.ctp.gz mccortexF1/k47/links/%.thresh.txt
	THRESH=`tail -1 mccortexF1/k47/links/$*.thresh.txt | grep -oE '[0-9]+$$'`; \
$(CTXDIR)/bin/mccortex63 links -c "$$THRESH" -o $@ $< >& $@.log

#
# Assemble contigs
#
# assembly high covg sample k=19
mccortexF1/k19/contigs_links/%.pop.raw.fa.gz: mccortexF1/k19/graphs/%.pop.clean.ctx mccortexF1/k19/links/%.pop.pe.clean.ctp.gz | dirs
	( $(CTXDIR)/bin/mccortex31 contigs $(CTX_ARGS) $(CONTIG_POP_ARGS) -o - -p mccortexF1/k19/links/$*.pop.pe.clean.ctp.gz $< | $(BGZIP) -c > $@ ) >& $@.log

# assembly k=19 with links
mccortexF1/k19/contigs_links/%.raw.fa.gz: mccortexF1/k19/graphs/%.clean.ctx mccortexF1/k19/links/%.pe.clean.ctp.gz $(REF_GRAPH_K19) | dirs
	( $(CTXDIR)/bin/mccortex31 contigs $(CTX_ARGS) $(CONTIG_ARGS) -o - -p mccortexF1/k19/links/$*.pe.clean.ctp.gz $< $(REF_GRAPH_K19) | $(BGZIP) -c > $@ ) >& $@.log

# assembly k=19
mccortexF1/k19/contigs_plain/%.raw.fa.gz: mccortexF1/k19/graphs/%.clean.ctx $(REF_GRAPH_K19) | dirs
	( $(CTXDIR)/bin/mccortex31 contigs $(CTX_ARGS) $(CONTIG_ARGS) -o - $< $(REF_GRAPH_K19) | $(BGZIP) -c > $@ ) >& $@.log

# Remove redundant contigs
mccortexF1/k19/contigs%.rmdup.fa.gz: mccortexF1/k19/contigs%.raw.fa.gz
	( $(CTXDIR)/bin/mccortex31 rmsubstr $(CTX_ARGS) -k 19 -o - $< | $(BGZIP) -c > $@ ) >& $@.log

# assembly high covg sample k=25
mccortexF1/k25/contigs_links/%.pop.raw.fa.gz: mccortexF1/k25/graphs/%.pop.clean.ctx mccortexF1/k25/links/%.pop.pe.clean.ctp.gz | dirs
	( $(CTXDIR)/bin/mccortex31 contigs $(CTX_ARGS) $(CONTIG_POP_ARGS) -o - -p mccortexF1/k25/links/$*.pop.pe.clean.ctp.gz $< | $(BGZIP) -c > $@ ) >& $@.log

# assembly k=25 with links
mccortexF1/k25/contigs_links/%.raw.fa.gz: mccortexF1/k25/graphs/%.clean.ctx mccortexF1/k25/links/%.pe.clean.ctp.gz $(REF_GRAPH_K25) | dirs
	( $(CTXDIR)/bin/mccortex31 contigs $(CTX_ARGS) $(CONTIG_ARGS) -o - -p mccortexF1/k25/links/$*.pe.clean.ctp.gz $< $(REF_GRAPH_K25) | $(BGZIP) -c > $@ ) >& $@.log

# assembly k=25
mccortexF1/k25/contigs_plain/%.raw.fa.gz: mccortexF1/k25/graphs/%.clean.ctx $(REF_GRAPH_K25) | dirs
	( $(CTXDIR)/bin/mccortex31 contigs $(CTX_ARGS) $(CONTIG_ARGS) -o - $< $(REF_GRAPH_K25) | $(BGZIP) -c > $@ ) >& $@.log

# Remove redundant contigs
mccortexF1/k25/contigs%.rmdup.fa.gz: mccortexF1/k25/contigs%.raw.fa.gz
	( $(CTXDIR)/bin/mccortex31 rmsubstr $(CTX_ARGS) -k 25 -o - $< | $(BGZIP) -c > $@ ) >& $@.log

# assembly high covg sample k=31
mccortexF1/k31/contigs_links/%.pop.raw.fa.gz: mccortexF1/k31/graphs/%.pop.clean.ctx mccortexF1/k31/links/%.pop.pe.clean.ctp.gz | dirs
	( $(CTXDIR)/bin/mccortex31 contigs $(CTX_ARGS) $(CONTIG_POP_ARGS) -o - -p mccortexF1/k31/links/$*.pop.pe.clean.ctp.gz $< | $(BGZIP) -c > $@ ) >& $@.log

# assembly k=31 with links
mccortexF1/k31/contigs_links/%.raw.fa.gz: mccortexF1/k31/graphs/%.clean.ctx mccortexF1/k31/links/%.pe.clean.ctp.gz $(REF_GRAPH_K31) | dirs
	( $(CTXDIR)/bin/mccortex31 contigs $(CTX_ARGS) $(CONTIG_ARGS) -o - -p mccortexF1/k31/links/$*.pe.clean.ctp.gz $< $(REF_GRAPH_K31) | $(BGZIP) -c > $@ ) >& $@.log

# assembly k=31
mccortexF1/k31/contigs_plain/%.raw.fa.gz: mccortexF1/k31/graphs/%.clean.ctx $(REF_GRAPH_K31) | dirs
	( $(CTXDIR)/bin/mccortex31 contigs $(CTX_ARGS) $(CONTIG_ARGS) -o - $< $(REF_GRAPH_K31) | $(BGZIP) -c > $@ ) >& $@.log

# Remove redundant contigs
mccortexF1/k31/contigs%.rmdup.fa.gz: mccortexF1/k31/contigs%.raw.fa.gz
	( $(CTXDIR)/bin/mccortex31 rmsubstr $(CTX_ARGS) -k 31 -o - $< | $(BGZIP) -c > $@ ) >& $@.log

# assembly high covg sample k=47
mccortexF1/k47/contigs_links/%.pop.raw.fa.gz: mccortexF1/k47/graphs/%.pop.clean.ctx mccortexF1/k47/links/%.pop.pe.clean.ctp.gz | dirs
	( $(CTXDIR)/bin/mccortex63 contigs $(CTX_ARGS) $(CONTIG_POP_ARGS) -o - -p mccortexF1/k47/links/$*.pop.pe.clean.ctp.gz $< | $(BGZIP) -c > $@ ) >& $@.log

# assembly k=47 with links
mccortexF1/k47/contigs_links/%.raw.fa.gz: mccortexF1/k47/graphs/%.clean.ctx mccortexF1/k47/links/%.pe.clean.ctp.gz $(REF_GRAPH_K47) | dirs
	( $(CTXDIR)/bin/mccortex63 contigs $(CTX_ARGS) $(CONTIG_ARGS) -o - -p mccortexF1/k47/links/$*.pe.clean.ctp.gz $< $(REF_GRAPH_K47) | $(BGZIP) -c > $@ ) >& $@.log

# assembly k=47
mccortexF1/k47/contigs_plain/%.raw.fa.gz: mccortexF1/k47/graphs/%.clean.ctx $(REF_GRAPH_K47) | dirs
	( $(CTXDIR)/bin/mccortex63 contigs $(CTX_ARGS) $(CONTIG_ARGS) -o - $< $(REF_GRAPH_K47) | $(BGZIP) -c > $@ ) >& $@.log

# Remove redundant contigs
mccortexF1/k47/contigs%.rmdup.fa.gz: mccortexF1/k47/contigs%.raw.fa.gz
	( $(CTXDIR)/bin/mccortex63 rmsubstr $(CTX_ARGS) -k 47 -o - $< | $(BGZIP) -c > $@ ) >& $@.log

#
# Make bubble calls
#
# bubble calls k=19 joint+links
mccortexF1/k19/bubbles_links/joint.bub.gz: $(CLEAN_GRAPHS_K19) $(REF_GRAPH_K19) $(CLEAN_PE_LINKS_K19) | dirs
	$(CTXDIR)/bin/mccortex31 bubbles $(CTX_ARGS) $(BUBBLES_ARGS)  -o $@ -p 0:mccortexF1/k19/links/F1.pe.clean.ctp.gz $(CLEAN_GRAPHS_K19) $(REF_GRAPH_K19) >& $@.log

# bubble calls k=19 joint+nolinks
mccortexF1/k19/bubbles_plain/joint.bub.gz: $(CLEAN_GRAPHS_K19) $(REF_GRAPH_K19) | dirs
	$(CTXDIR)/bin/mccortex31 bubbles $(CTX_ARGS) $(BUBBLES_ARGS)  -o $@ $(CLEAN_GRAPHS_K19) $(REF_GRAPH_K19) >& $@.log

# bubble calls k=19 1by1+links
mccortexF1/k19/bubbles_links/%.bub.gz: mccortexF1/k19/graphs/%.clean.ctx $(REF_GRAPH_K19) mccortexF1/k19/links/%.pe.clean.ctp.gz | dirs
	$(CTXDIR)/bin/mccortex31 bubbles $(CTX_ARGS) $(BUBBLES_ARGS)  -o $@ -p mccortexF1/k19/links/$*.pe.clean.ctp.gz $< $(REF_GRAPH_K19) >& $@.log

# bubble calls k=19 1by1+nolinks
mccortexF1/k19/bubbles_plain/%.bub.gz: mccortexF1/k19/graphs/%.clean.ctx $(REF_GRAPH_K19) | dirs
	$(CTXDIR)/bin/mccortex31 bubbles $(CTX_ARGS) $(BUBBLES_ARGS)  -o $@ $< $(REF_GRAPH_K19) >& $@.log

# bubble calls k=25 joint+links
mccortexF1/k25/bubbles_links/joint.bub.gz: $(CLEAN_GRAPHS_K25) $(REF_GRAPH_K25) $(CLEAN_PE_LINKS_K25) | dirs
	$(CTXDIR)/bin/mccortex31 bubbles $(CTX_ARGS) $(BUBBLES_ARGS)  -o $@ -p 0:mccortexF1/k25/links/F1.pe.clean.ctp.gz $(CLEAN_GRAPHS_K25) $(REF_GRAPH_K25) >& $@.log

# bubble calls k=25 joint+nolinks
mccortexF1/k25/bubbles_plain/joint.bub.gz: $(CLEAN_GRAPHS_K25) $(REF_GRAPH_K25) | dirs
	$(CTXDIR)/bin/mccortex31 bubbles $(CTX_ARGS) $(BUBBLES_ARGS)  -o $@ $(CLEAN_GRAPHS_K25) $(REF_GRAPH_K25) >& $@.log

# bubble calls k=25 1by1+links
mccortexF1/k25/bubbles_links/%.bub.gz: mccortexF1/k25/graphs/%.clean.ctx $(REF_GRAPH_K25) mccortexF1/k25/links/%.pe.clean.ctp.gz | dirs
	$(CTXDIR)/bin/mccortex31 bubbles $(CTX_ARGS) $(BUBBLES_ARGS)  -o $@ -p mccortexF1/k25/links/$*.pe.clean.ctp.gz $< $(REF_GRAPH_K25) >& $@.log

# bubble calls k=25 1by1+nolinks
mccortexF1/k25/bubbles_plain/%.bub.gz: mccortexF1/k25/graphs/%.clean.ctx $(REF_GRAPH_K25) | dirs
	$(CTXDIR)/bin/mccortex31 bubbles $(CTX_ARGS) $(BUBBLES_ARGS)  -o $@ $< $(REF_GRAPH_K25) >& $@.log

# bubble calls k=31 joint+links
mccortexF1/k31/bubbles_links/joint.bub.gz: $(CLEAN_GRAPHS_K31) $(REF_GRAPH_K31) $(CLEAN_PE_LINKS_K31) | dirs
	$(CTXDIR)/bin/mccortex31 bubbles $(CTX_ARGS) $(BUBBLES_ARGS)  -o $@ -p 0:mccortexF1/k31/links/F1.pe.clean.ctp.gz $(CLEAN_GRAPHS_K31) $(REF_GRAPH_K31) >& $@.log

# bubble calls k=31 joint+nolinks
mccortexF1/k31/bubbles_plain/joint.bub.gz: $(CLEAN_GRAPHS_K31) $(REF_GRAPH_K31) | dirs
	$(CTXDIR)/bin/mccortex31 bubbles $(CTX_ARGS) $(BUBBLES_ARGS)  -o $@ $(CLEAN_GRAPHS_K31) $(REF_GRAPH_K31) >& $@.log

# bubble calls k=31 1by1+links
mccortexF1/k31/bubbles_links/%.bub.gz: mccortexF1/k31/graphs/%.clean.ctx $(REF_GRAPH_K31) mccortexF1/k31/links/%.pe.clean.ctp.gz | dirs
	$(CTXDIR)/bin/mccortex31 bubbles $(CTX_ARGS) $(BUBBLES_ARGS)  -o $@ -p mccortexF1/k31/links/$*.pe.clean.ctp.gz $< $(REF_GRAPH_K31) >& $@.log

# bubble calls k=31 1by1+nolinks
mccortexF1/k31/bubbles_plain/%.bub.gz: mccortexF1/k31/graphs/%.clean.ctx $(REF_GRAPH_K31) | dirs
	$(CTXDIR)/bin/mccortex31 bubbles $(CTX_ARGS) $(BUBBLES_ARGS)  -o $@ $< $(REF_GRAPH_K31) >& $@.log

# bubble calls k=47 joint+links
mccortexF1/k47/bubbles_links/joint.bub.gz: $(CLEAN_GRAPHS_K47) $(REF_GRAPH_K47) $(CLEAN_PE_LINKS_K47) | dirs
	$(CTXDIR)/bin/mccortex63 bubbles $(CTX_ARGS) $(BUBBLES_ARGS)  -o $@ -p 0:mccortexF1/k47/links/F1.pe.clean.ctp.gz $(CLEAN_GRAPHS_K47) $(REF_GRAPH_K47) >& $@.log

# bubble calls k=47 joint+nolinks
mccortexF1/k47/bubbles_plain/joint.bub.gz: $(CLEAN_GRAPHS_K47) $(REF_GRAPH_K47) | dirs
	$(CTXDIR)/bin/mccortex63 bubbles $(CTX_ARGS) $(BUBBLES_ARGS)  -o $@ $(CLEAN_GRAPHS_K47) $(REF_GRAPH_K47) >& $@.log

# bubble calls k=47 1by1+links
mccortexF1/k47/bubbles_links/%.bub.gz: mccortexF1/k47/graphs/%.clean.ctx $(REF_GRAPH_K47) mccortexF1/k47/links/%.pe.clean.ctp.gz | dirs
	$(CTXDIR)/bin/mccortex63 bubbles $(CTX_ARGS) $(BUBBLES_ARGS)  -o $@ -p mccortexF1/k47/links/$*.pe.clean.ctp.gz $< $(REF_GRAPH_K47) >& $@.log

# bubble calls k=47 1by1+nolinks
mccortexF1/k47/bubbles_plain/%.bub.gz: mccortexF1/k47/graphs/%.clean.ctx $(REF_GRAPH_K47) | dirs
	$(CTXDIR)/bin/mccortex63 bubbles $(CTX_ARGS) $(BUBBLES_ARGS)  -o $@ $< $(REF_GRAPH_K47) >& $@.log

