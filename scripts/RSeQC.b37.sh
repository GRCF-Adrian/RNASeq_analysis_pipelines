#!/usr/bin/env sh
# RSeQC.b37.sh
# run RSeQC on an aligned bam file
# Version 1.0
# Author: Tuo Zhang
# Date: 10/6/2016
# NEW: Modify for b37
# 

if [ $# -ne 8 ]
then
	echo "Usage: RSeQC.b37.sh sid bamfile outdir genome_assembly(GRCh37) SR(1)/PE(2) python RSeQCsrc RSeQCdb"
	exit 1
fi

sid=$1
bamfile=$2
outdir=$3

#genome=hg19
genome=$4
nr=$5

seqtype="SE"
if [ ${nr} -eq 2 ]
then
	seqtype="PE"
fi

#python=/home/freshtuo/Softwares/python-2.7.10/bin/python
python=$6
#tooldir=/home/freshtuo/Softwares/RSeQC-2.6.2/scripts
tooldir=$7
#dbdir=/home/freshtuo/Softwares/RSeQC-2.6.2/db
dbdir=$8
logdir=${outdir}/logs

housekeepinggenes=${dbdir}/${genome}.HouseKeepingGenes.bed
refseqgenes=${dbdir}/${genome}_RefSeq.bed
chromsize=${dbdir}/${genome}.chrom.sizes
rRNAs=${dbdir}/${genome}_rRNA.bed

# create output folders
if [ ! -d ${outdir} ]
then
	mkdir ${outdir}
fi
# create log folder
if [ ! -d ${logdir} ]
then
	mkdir ${logdir}
fi

# index bam
if [ ! -e ${bamfile}.bai ]
then
	echo -n "index bam file..."
	samtools index ${bamfile}
	echo "ok."
fi

# bam_stat
echo -n bam_stat...
time ${python} ${tooldir}/bam_stat.py -i ${bamfile} >${outdir}/${sid}.bam_stat.txt 2>&1
echo ok.

# clipping_profile
#echo -n clipping_profile...
#time ${python} ${tooldir}/clipping_profile.py -i ${bamfile} -o ${outdir}/${sid}.clipping_profile -s ${seqtype} >${logdir}/${sid}.clipping_profile.log 2>&1
#echo ok.

# geneBody_coverage
echo -n geneBody_coverage...
time ${python} ${tooldir}/geneBody_coverage.py -i ${bamfile} -o ${outdir}/${sid}.geneBody_coverage -r ${housekeepinggenes} >${logdir}/${sid}.geneBody_coverage.log 2>&1
echo ok.

# geneBody_coverage2
#echo -n geneBody_coverage2...
#time ${python} ${tooldir}/bam2wig.py -i ${bamfile} -o ${outdir}/${sid} -s ${chromsize} >${logdir}/${sid}.bam2wig.log 2>&1
#time ${python} ${tooldir}/geneBody_coverage2.py -i ${outdir}/${sid}.bw -o ${outdir}/${sid}.geneBody_coverage2 -r ${housekeepinggenes} -t png >${logdir}/${sid}.geneBody_coverage2.log 2>&1
#rm ${outdir}/${sid}.wig
#rm ${outdir}/${sid}.bw
#echo ok.

# inner_distance
#if [ ${seqtype} == "PE" ]
#then
#	echo -n inner_distance...
#	time ${python} ${tooldir}/inner_distance.py -i ${bamfile} -o ${outdir}/${sid}.inner_distance -r ${refseqgenes} >${logdir}/${sid}.inner_distance.log 2>&1
#	echo ok.
#fi

# junction_annotation
#echo -n junction_annotation...
#time ${python} ${tooldir}/junction_annotation.py -i ${bamfile} -r ${refseqgenes} -o ${outdir}/${sid}.junction_annotation >${logdir}/${sid}.junction_annotation.log 2>&1
#echo ok.

# junction_saturation
#echo -n junction_saturation...
#time ${python} ${tooldir}/junction_saturation.py -i ${bamfile} -o ${outdir}/${sid}.junction_saturation -r ${refseqgenes} >${logdir}/${sid}.junction_saturation.log 2>&1
#echo ok.

# read_distribution
echo -n read_distribution...
time ${python} ${tooldir}/read_distribution.py -i ${bamfile} -r ${refseqgenes} >${outdir}/${sid}.read_distribution.txt 2>${logdir}/${sid}.read_distribution.log
echo ok.

# read_duplication
#echo -n read_duplication...
#time ${python} ${tooldir}/read_duplication.py -i ${bamfile} -o ${outdir}/${sid}.read_duplication >${logdir}/${sid}.read_duplication.log 2>&1
#echo ok.

# RPKM_saturation
#echo -n RPKM_saturation...
#time ${python} ${tooldir}/RPKM_saturation.py -i ${bamfile} -o ${outdir}/${sid}.RPKM_saturation -r ${refseqgenes} >${logdir}/${sid}.RPKM_saturation.log 2>&1
#echo ok.

# split_bam
echo -n split_bam for rRNA...
time ${python} ${tooldir}/split_bam.py -i ${bamfile} -r ${rRNAs} -o ${outdir}/${sid}.rRNA >${outdir}/${sid}.rRNA_stat.txt 2>&1
rm ${outdir}/${sid}.rRNA.ex.bam
rm ${outdir}/${sid}.rRNA.junk.bam
echo ok.

echo "Complete!"

