#!/usr/bin/env sh
# run_cufflinke_v2.sh
# Version 1.9
# Author: Tuo Zhang
# Date: 03/18/2016
# NEW: add parameters: cufflinks; cpu
#

if [ $# -ne 9 ]
then
	echo "run_cufflinks.sh sample_id bamdir cuffoutdir refann refseq libtype(fr-unstranded/fr-firststrand) mask-gtf cufflinks cpu"
	exit 1
fi

sid=$1
#cpu=8
cpu=$9
#cufflinks=/home/freshtuo/Softwares/cufflinks-2.1.1.Linux_x86_64/cufflinks
cufflinks=$8
bamdir=$2
bam=${bamdir}/Aligned.sortedByCoord.out.bam
####outdir=cufflinks_out
outdir=$3
####refann=/db1/Refs/Mus_musculus/UCSC/mm9/Annotation/Genes/genes.gtf
refann=$4
####refseq=/db1/Refs/Mus_musculus/UCSC/mm9/Sequence/WholeGenomeFasta/genome.fa
refseq=$5
libtype=$6
maskgtf=$7

# default value is 1,000,000
maxBundleFrags=100000000

# Guide RABT assembly: Output will include all reference transcripts as well as any novel genes and isoforms that are assembled.
#flag="--GTF-guide ${refann}"
# Do NOT assemble novel transcripts, and the program will ignore alignments not structurally compatible with any reference transcript. 
#flag="--GTF ${refann}"
#flag="--GTF ${refann} --compatible-hits-norm"
flag="--GTF ${refann} --compatible-hits-norm  --max-bundle-frags ${maxBundleFrags}"
# Do NOT use reference transcripts
#flag=""
# normalization
norm="--upper-quartile-norm"

${cufflinks} --output-dir ${outdir} --num-threads ${cpu} ${flag} ${norm} --frag-bias-correct ${refseq} --multi-read-correct --library-type ${libtype} --mask-file ${maskgtf} ${bam}

