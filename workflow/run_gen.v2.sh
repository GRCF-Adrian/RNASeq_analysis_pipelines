#!/usr/bin/env sh
# run_gen.v2.sh
# RNAseq analysis
# Version 1.2
# Author: Tuo Zhang
# Date: 04/11/2019
# NEW: modified for running on gc5
# 

# Tools
fastqc=/data/gc-core/yit2001/Softwares/FastQC/fastqc
cutadapt=cutadapt
star=/data/gc-core/yit2001/Softwares/STAR-2.5.2b/bin/Linux_x86_64_static/STAR
picard=/data/gc-core/yit2001/Softwares/picard-tools-1.110
java=java
cufflinks=/data/gc-core/yit2001/Softwares/cufflinks-2.1.1.Linux_x86_64/cufflinks
python=python
RSeQCsrc=/data/gc-core/yit2001/Softwares/RSeQC-2.6.2/scripts

# Working directories
workdir=/data/gc-core/yit2001/RNASeq/Project_Granstein-LS-15363_231221

# Source directory
srcdir=/data/gc-core/yit2001/pipelines/RNASeq/grcf_star/src/phase1

# Sequencing type: SR(1) or PE(2)
exp=2

# CPU
cpu=8

# memory for java
mem=8g

#human genome assemly GRCh38
genomename=Homo_sapiens
genomeid=GRCh38
release=100


# Analysis folders
qcdir=QC
fastqdir=fastq
outdir=star_out
cuffdir=cufflinks_out_v2
bamqcdir=bamQC
logdir=logs

# Trimming parameters
trim=T
minlen=25
qscore=10
overlap=5

##TrueSeq Adapters
adapter3=AGATCGGAAGAGCACACGTCTGAACTCCAGTCAC
adapter5=AGATCGGAAGAGCGTCGTGTAGGGAAAGAGTGT

##Nextera Adapters
#adapter3=CTGTCTCTTATACACATCTCCGAGCCCACGAGAC
#adapter5=CTGTCTCTTATACACATCTGACGCTGCCG

# parameters for Tophat2
refseq=/data/gc-core/database/Refs/${genomename}/Ensembl/${genomeid}/Sequence/WholeGenomeFasta/genome.fa

#libtype=fr-unstranded
libtype=fr-firststrand
#libtype=fr-secondstrand

# parameters for STAR
#for human, use this one
stargenomedir=/data/gc-core/database/Refs/${genomename}/Ensembl/${genomeid}/Sequence/StarIndex/100bp.old

seedLmax=30

# parameters for RSeQC
RSeQCdb=/data/gc-core/yit2001/Softwares/RSeQC-2.6.2/db

# parameters for cufflinks
refgtf=/data/gc-core/database/Refs/${genomename}/Ensembl/${genomeid}/Annotation/Genes/my_gtf/${genomename}.${genomeid}.${release}.clean.with_filt_chr_noMT.gtf
maskgtf=/data/gc-core/database/Refs/${genomename}/Ensembl/${genomeid}/Annotation/Genes/mask/${genomeid}.rRNA.tRNA.chrM.gtf

# for PE data only
readlen=51

cd ${workdir}

for folder in `ls -d Sample_*`
#for folder in Sample_test
do
	smp=${folder#Sample_}
	echo Sample_${smp}
	cd ${workdir}/Sample_${smp}/
	# Copy codes
	cp ${srcdir}/qc_v2.sh ./
	cp ${srcdir}/prepare_fastq.sh ./
	cp ${srcdir}/run_STAR.sh ./
	cp ${srcdir}/RSeQC.b37.sh ./
	cp ${srcdir}/run_cufflinks_v2.b37.sh ./
	# Create log folders
	if [ ! -d ${logdir} ]
	then
		mkdir ${logdir}
	fi
	# QC on raw fastq files
	sh qc_v2.sh ${smp} ${qcdir} ${fastqc} ${cpu} >${logdir}/qc_v2.log 2>&1
	# Clean fastq reads for alignment
	sh prepare_fastq.sh ${smp} ${exp} ${trim} ${fastqdir} ${minlen} ${qscore} ${logdir} ${cpu} ${cutadapt} ${overlap} ${adapter3} ${adapter5} ${fastqc} >${logdir}/prepare_fastq.log 2>&1
	# Align reads using STAR
	sh run_STAR.sh ${smp} ${exp} ${fastqdir} ${outdir} ${stargenomedir} ${libtype} ${seedLmax} ${star} ${cpu} >${logdir}/run_STAR.log 2>&1
	# Alignment QC
	sh RSeQC.b37.sh ${smp} ${outdir}/Aligned.sortedByCoord.out.bam ${bamqcdir} ${genomeid} ${exp} ${python} ${RSeQCsrc} ${RSeQCdb} >${logdir}/RSeQC.b37.log 2>&1
	# Estimate expression
	sh run_cufflinks_v2.b37.sh ${smp} ${outdir} ${cuffdir} ${refgtf} ${refseq} ${libtype} ${maskgtf} ${cufflinks} ${cpu} >${logdir}/run_cufflinks_v2.b37.log 2>&1
	# clean fastq
	rm ${fastqdir}/*.fastq
done

echo "All complete!"

