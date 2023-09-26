#!/bin/bash
#SBATCH -p batch --time 2-0:00:00 --ntasks 16 --nodes 1 --mem 24G --out logs/predict.%a.log
module unload miniconda2
module unload miniconda3
module load funannotate/1.8

#export AUGUSTUS_CONFIG_PATH=/bigdata/stajichlab/shared/pkg/augustus/3.3/config
export AUGUSTUS_CONFIG_PATH=$(realpath lib/augustus/3.3/config)

CPU=1
if [ $SLURM_CPUS_ON_NODE ]; then
    CPU=$SLURM_CPUS_ON_NODE
fi

OUTDIR=annotate
INDIR=genomes
SAMPFILE=strains.csv
SEED_SPECIES=coccidioides_immitis
BUSCO=eurotiomycetes_odb10
TRANSCRIPTS=$(realpath lib/mRNAs.fasta)
#ascomycota_odb9
which funannotate

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
    MASKED=$(realpath $INDIR/$BASE.masked.fasta)
    if [ ! -f $MASKED ]; then
     	echo "Cannot find $BASE.masked.fasta in $INDIR - may not have been run yet"
     	exit
    fi
    name=$(echo "${SPECIES}_$STRAIN" | perl -p -e 'chomp; s/\s+/_/g; ')
    species=$(echo "$SPECIES" | perl -p -e 'chomp; s/\s+/_/g;')
    TEMPLATE=$(realpath lib/authors.sbt)
    mkdir $name.predict.$$
    pushd $name.predict.$$
    if [ -d ../$OUTDIR/$BASE/training ]; then
    	funannotate predict --cpus $CPU --keep_no_stops --SeqCenter Broad --busco_db $BUSCO --strain "$STRAIN" \
	-i $MASKED --name $LOCUS --optimize_augustus --transcript_evidence $TRANSCRIPTS \
	-s $species -o ../$OUTDIR/$BASE --busco_seed_species $SEED_SPECIES --genemark_mode ET --min_protlen 30
     else
	echo "expected a training run before this for C.immitis"
	exit
     fi

    popd
    rmdir $name.predict.$$
done
