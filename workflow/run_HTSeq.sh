#!/usr/bin/env sh
# RNAseq analysis using HTSeq and edgeR
# Version 2.5
# Author: Tuo Zhang
# Date: 07/18/2016
# Modification: support both SR and PE runs, 
#               for PE, sort the sam file by read name first
#               add an option of mask "NH:i:*" tag
# NEW: add parameter strand (yes/no/reverse)

workdir=/data/gc-core/yit2001/RNASeq/Project_Granstein-LS-15363_231221
refann=/data/gc-core/database/Refs/Homo_sapiens/Ensembl/GRCh38/Annotation/Genes/Homo_sapiens.GRCh38.100.noheader.gtf

# SR(1) or PE(2)
exp=2
cpu=8
mem="1G"
strand=reverse
#strand=no

for folder in `ls -d Sample*`
do
	smp=${folder#Sample_}
	echo Sample_$smp
	cd $workdir/Sample_$smp/
	if [ $exp -eq 1 ]
	then
		samtools view star_out/Aligned.sortedByCoord.out.bam |HTSeq-count-reads.sh $refann genes.HTSeq.count ${strand} >HTSeq-count-reads.log 2>&1
		gzip HTSeq-count-reads.log
		####gzip HTSeq-count-reads.multi_align.log
	elif [ $exp -eq 2 ]
	then
		samtools sort -n -@ $cpu -m $mem -T sort.tmp -O sam star_out/Aligned.sortedByCoord.out.bam |HTSeq-count-reads.sh $refann genes.HTSeq.count ${strand} >HTSeq-count-reads.log 2>&1
		gzip HTSeq-count-reads.log
	fi
done

