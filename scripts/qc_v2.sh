#!/usr/bin/env sh
# qc_v2.sh
# Version 1.1
# Author: Tuo Zhang
# Date: 03/17/2016
# NEW: add parameter 1) CPU; 2) fastqc
# 

if [ $# -ne 4 ]
then
	#echo "qc_v2.sh sample_id SR(1)/PE(2)"
	echo "qc_v2.sh sample_id outputdir fastqc #cpu"
	exit 1
fi

sid=$1
outdir=$2
####fastqc=/home/freshtuo/Softwares/FastQC/fastqc
fastqc=$3
####cpu=8
cpu=$4

if [ ! -d ${outdir} ]
then
	mkdir ${outdir}
else
	echo "output folder ${outdir} already exists!!!"
	exit 2
fi

seqfile=`ls ${sid}_*_R?_*.fastq.gz`
echo "Following files to QC:"
for x in ${seqfile}
do
	echo ${x}
done

#echo "QC starts."
${fastqc}  --outdir  ${outdir}  --casava  --threads ${cpu}  --quiet  ${seqfile}
# clear zipped QC files
rm ${outdir}/*.zip
echo "QC completes."

