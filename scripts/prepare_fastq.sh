#!/usr/bin/env sh
# prepare_fastq.sh
# Version 4.0
# Author: Tuo Zhang
# Date: 03/17/2016
# NEW: totally re-design for 1) trimming adapters using cutadapt only for both SR and PE; 2) add paramter: cutadapt; CPU; adapter sequences
# 

if [ $# -ne 13 ]
then
	echo "prepare_fastq.sh sample_id SR(1)/PE(2) Trim(T)/No-Trim(N) outdir minlen qscore logdir cpu cutadapt adaptoverlap adapter3 adapter5 fastqc"
	echo "Trim: both adapter sequences and low-quality bases"
	exit 1
fi

sid=$1
nr=$2
trim=$3
####outdir=fastq
outdir=$4
####minlen=45
minlen=$5
####qscore=10
qscore=$6
logdir=$7
cpu=$8
####fastq_quality_trimmer=fastq_quality_trimmer
####cutadapt=cutadapt
cutadapt=$9
####overlap=5
overlap=${10}
####adapter3=AGATCGGAAGAGCACACGTCTGAACTCCAGTCAC
adapter3=${11}
####adapter5=AGATCGGAAGAGCGTCGTGTAGGGAAAGAGTGT
adapter5=${12}
fastqc=${13}
reqcdir=QC_trimmed

# create fastq folder
if [ ! -d ${outdir} ]
then
	mkdir ${outdir}
else
	echo "${outdir} folder already exists, overwriting it."
fi

# SR
if [ "${nr}" == "1" ]
then
	echo "Unzipping Read 1"
	if [ "${trim}" == "T" ]
	then
		zcat ${sid}_*_R1_*.fastq.gz |${cutadapt} -O ${overlap} -m ${minlen} -q ${qscore} -a ${adapter3} - -o ${outdir}/${sid}_R1.phred33.fastq >${logdir}/cutadapt.read1.stat 2>&1
	elif [ "${trim}" == "N" ]
	then
		zcat ${sid}_*_R1_*.fastq.gz >${outdir}/${sid}_R1.phred33.fastq
	fi
	nlines=`zcat ${sid}_*_R1_*.fastq.gz |wc -l |cut -f 1 -d ' '`
	nreads=`expr ${nlines} / 4`
	nfiltlines=`wc -l ${outdir}/${sid}_R1.phred33.fastq |cut -f 1 -d ' '`
	nfiltreads=`expr ${nfiltlines} / 4`
	echo "${nlines} lines in total."
	echo "${nreads} reads."
	echo "After QC filter..."
	echo "${nfiltreads} remain."
	mkdir ${reqcdir}
	${fastqc} --outdir ${reqcdir} --threads ${cpu} --quiet ${outdir}/${sid}_R1.phred33.fastq
	# clear zipped QC files
	rm ${reqcdir}/*.zip
# PE
elif [ "${nr}" == "2" ]
then
	for i in `seq 1 1 ${nr}`
	do
		echo "Unzipping Read ${i}"
		zcat ${sid}_*_R${i}_*.fastq.gz >${outdir}/${sid}_R${i}.phred33.raw.fastq
		nlines=`wc -l ${outdir}/${sid}_R${i}.phred33.raw.fastq |cut -f 1 -d ' '`
		nreads=`expr ${nlines} / 4`
		echo "${nlines} lines in total."
		echo "${nreads} reads."
	done
	# trim low quality bases for PE data
	# use my code "pairend_trimmer.py"
	if [ "${trim}" == "T" ]
	then
		cutadapt -O ${overlap} -m ${minlen} -q ${qscore} -a ${adapter3} -A ${adapter5} -o ${outdir}/${sid}_R1.phred33.fastq -p ${outdir}/${sid}_R2.phred33.fastq ${outdir}/${sid}_R1.phred33.raw.fastq ${outdir}/${sid}_R2.phred33.raw.fastq >${logdir}/cutadapt.read1.read2.stat 2>&1
		rm ${outdir}/${sid}_R?.phred33.raw.fastq
	elif [ "${trim}" == "N" ]
	then
		mv ${outdir}/${sid}_R1.phred33.raw.fastq ${outdir}/${sid}_R1.phred33.fastq
		mv ${outdir}/${sid}_R2.phred33.raw.fastq ${outdir}/${sid}_R2.phred33.fastq
	fi
	# statistics after QC
	nfiltlines=`wc -l ${outdir}/${sid}_R1.phred33.fastq |cut -f 1 -d ' '`
	nfiltreads=`expr ${nfiltlines} / 4`
	ndiscardreads=`expr ${nreads} - ${nfiltreads}`
	echo "${nlines} lines in total."
	echo "${nreads} paired reads, out of which:"
	echo "${ndiscardreads} are filtered."
	echo "${nfiltreads} remain."
	mkdir ${reqcdir}
	${fastqc} --outdir ${reqcdir} --threads ${cpu} --quiet ${outdir}/${sid}_R1.phred33.fastq ${outdir}/${sid}_R2.phred33.fastq
	# clear zipped QC files
	rm ${reqcdir}/*.zip
fi

