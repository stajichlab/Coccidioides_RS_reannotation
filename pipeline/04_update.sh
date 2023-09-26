#!/bin/bash
#SBATCH -p batch --time 2-0:00:00 --ntasks 16 --nodes 1 --mem 24G --out logs/update.%a.log

module unload miniconda2
module load funannotate/1.8

export PASACONF=$HOME/pasa.CONFIG.template
PASAHOMEPATH=$(dirname `which Launch_PASA_pipeline.pl`)
TRINITYHOMEPATH=$(dirname `which Trinity`)
export AUGUSTUS_CONFIG_PATH=$(realpath lib/augustus/3.3/config)
CPU=$SLURM_CPUS_ON_NODE
if [ -z $CPU ]; then
	CPU=1
fi

INDIR=genomes
OUTDIR=annotate
SAMPFILE=strains.csv

N=${SLURM_ARRAY_TASK_ID}

if [ ! $N ]; then
    N=$1
    if [ ! $N ]; then
        echo "need to provide a number by --array or cmdline"
        exit
    fi
fi
MAX=`wc -l $SAMPFILE | awk '{print $1}'`
if [ -z "$MAX" ]; then
    MAX=0
fi
if [ $N -gt $MAX ]; then
    echo "$N is too big, only $MAX lines in $SAMPFILE"
    exit
fi
IFS=,

cat $SAMPFILE | sed -n ${N}p | while read BASE SPECIES STRAIN RNASEQSET LOCUS
do
	TEMPLATE=$(realpath lib/authors.sbt)
    funannotate update --cpus $CPU -i $OUTDIR/$BASE --out $OUTDIR/$BASE --sbt $TEMPLATE --pasa_db mysql  --pasa_config $PASACONF
done
