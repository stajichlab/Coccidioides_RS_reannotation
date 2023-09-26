#!/bin/bash -l

#SBATCH --nodes=1
#SBATCH --ntasks=16
#SBATCH --mem 192gb -p intel,batch
#SBATCH --time=7-00:15:00   
#SBATCH --output=logs/train.%a.log
#SBATCH --job-name="TrainFun"
module load funannotate/1.8

# Set some vars
#export SINGULARITY_BINDPATH=/rhome/kelseya/bigdata
export FUNANNOTATE_DB=/bigdata/stajichlab/shared/lib/funannotate_db
#export SINGULARITYENV_PASACONF=/rhome/kelseya/pasa.CONFIG.template
export PASACONF=$HOME/pasa.CONFIG.template
module unload miniconda2
#module unload miniconda3
#module load funannotate/development
#module unload perl
#module unload python

PASAHOMEPATH=$(dirname `which Launch_PASA_pipeline.pl`)
TRINITY=$(realpath `which Trinity`)
TRINITYHOMEPATH=$(dirname $TRINITY)

export AUGUSTUS_CONFIG_PATH=$(realpath lib/augustus/3.3/config)
CPUS=$SLURM_CPUS_ON_NODE

#echo "PASA is $PASAHOME Trinity is Trinity"
MEM=192G

if [ ! $CPUS ]; then
 CPUS=2
fi

ODIR=annotate
INDIR=genomes
RNAFOLDER=lib/RNASeq
SAMPLEFILE=strains.csv
N=${SLURM_ARRAY_TASK_ID}

if [ ! $N ]; then
    N=$1
    if [ ! $N ]; then
        echo "need to provide a number by --array or cmdline"
        exit
    fi
fi
IFS=,
cat $SAMPLEFILE | sed -n ${N}p | while read BASE SPECIES STRAIN RNASEQSET LOCUS
do
    MASKED=$(realpath $INDIR/$BASE.masked.fasta)
    if [ ! -f $MASKED ]; then
     	echo "Cannot find $BASE.masked.fasta in $INDIR - may not have been run yet"
     	exit
    fi
#--PASAHOME $PASAHOMEPATH --TRINITYHOME $TRINITYHOMEPATH \
 #  --stranded RF --jaccard_clip --species "$SPECIES" --isolate $STRAIN  --cpus $CPUS --memory $MEM
 	funannotate train -i $MASKED -o $ODIR/$BASE \
	    --left $RNAFOLDER/${RNASEQSET}_R1.fq.gz --right $RNAFOLDER/${RNASEQSET}_R2.fq.gz \
	    --jaccard_clip --species "$SPECIES" --isolate $STRAIN  --cpus $CPUS \
	    --memory $MEM --pasa_db mysql

done
