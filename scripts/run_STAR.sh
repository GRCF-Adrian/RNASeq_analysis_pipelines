#!/usr/bin/env sh
# run_STAR.sh
# Version: 1.0
# Author: Tuo Zhang
# Date: 09/30/2016
# New: first version
# Note:
# 

if [ $# -ne 9 ]
then
	echo "run_STAR.sh sample_id SR(1)/PE(2) fastqdir outdir refidx libtype(fr-unstranded/fr-firststrand) seedLmax star cpu"
	exit 1
fi

sid=$1
nr=$2

cpu=$9
#star=/home/freshtuo/Softwares/STAR-2.5.2b/bin/Linux_x86_64_static/STAR
star=$8
#fastqdir=fastq
fastqdir=$3
#outdir=star_out
outdir=$4
#refidx=/db2/Refs/Homo_sapiens/Ensembl/GRCh37/Sequence/StarIndex/100bp
refidx=$5
libtype=$6
seedLmax=$7

phred=33

flag=""

if [ ${nr} -eq 1 ]
then
	flag="${flag} --readFilesIn ../${fastqdir}/${sid}_R1.phred${phred}.fastq"
else
	flag="${flag} --readFilesIn ../${fastqdir}/${sid}_R1.phred${phred}.fastq ../${fastqdir}/${sid}_R2.phred${phred}.fastq"
fi

if [ "${libtype}" == "fr-unstranded" ]
then
	flag="${flag} --outSAMstrandField intronMotif"
fi

if [ ! -d ${outdir} ]
then
	mkdir ${outdir}
fi

cd ${outdir}

${star} \
--runThreadN ${cpu} \
--genomeDir ${refidx} \
${flag} \
--outReadsUnmapped Fastx \
--outSAMtype BAM SortedByCoordinate \
--outFilterType BySJout \
--outFilterMultimapNmax 20 \
--alignSJoverhangMin 5 \
--alignSJDBoverhangMin 1 \
--seedSearchStartLmax ${seedLmax} \
--twopassMode Basic \

gzip Unmapped.out.mate*

