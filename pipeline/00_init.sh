#!/usr/bin/bash
#SBATCH -p short -N 1 -n 2 --mem 2gb

OUTDIR=genomes

RELEASE=46
SPECIES=CimmitisRS
URL=https://fungidb.org/common/downloads/release-${RELEASE}
FASTA=$URL/$SPECIES/fasta/data/FungiDB-${RELEASE}_${SPECIES}_Genome.fasta
GFF=$URL/$SPECIES/gff/data/FungiDB-${RELEASE}_${SPECIES}.gff
mkdir -p $OUTDIR
pushd $OUTDIR
for name in $FASTA $GFF
do
 file=$(basename $name)
 if [ ! -f $file ]; then
	curl -o $file $name
 fi
done

