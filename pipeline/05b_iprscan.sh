#!/bin/bash
#SBATCH --ntasks 8 --nodes 1 --mem 96G -p intel 
#SBATCH --time 72:00:00 --out logs/iprscan.%a.log
module unload miniconda2
module unload miniconda3
module load anaconda3
module load funannotate/development
module unload perl
module unload python
source activate funannotate
module load iprscan
CPU=1
if [ ! -z $SLURM_CPUS_ON_NODE ]; then
    CPU=$SLURM_CPUS_ON_NODE
fi
OUTDIR=annotate
SAMPFILE=samples.csv
N=${SLURM_ARRAY_TASK_ID}
if [ ! $N ]; then
    N=$1
    if [ ! $N ]; then
        echo "need to provide a number by --array or cmdline"
        exit
    fi
fi
MAX=`wc -l $SAMPFILE | awk '{print $1}'`

if [ $N -gt $MAX ]; then
    echo "$N is too big, only $MAX lines in $SAMPFILE"
    exit
fi
IFS=,
cat $SAMPFILE | sed -n ${N}p | while read BASE SPECIES STRAIN RNASEQSET LOCUS
do

	 if [ ! -d $OUTDIR/$BASE ]; then
		echo "No annotation dir for ${BASE}"
		exit
 	fi
	mkdir -p $OUTDIR/$BASE/annotate_misc
	XML=$OUTDIR/$BASE/annotate_misc/iprscan.xml
	IPRPATH=$(which interproscan.sh)
	if [ ! -f $XML ]; then
	    funannotate iprscan -i $OUTDIR/$BASE -o $XML -m local -c $CPU --iprscan_path $IPRPATH
	fi
done
