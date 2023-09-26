#!/bin/bash
#SBATCH -p batch  
#SBATCH --ntasks 4 
#SBATCH --nodes 1 
#SBATCH --mem 24G 
#SBATCH --out logs/fix.%a.log
#SBATCH -J FunFix
#SBATCH --array 1
#SBATCH --time=1-0:00:00

module unload perl
module unload miniconda2
module unload miniconda3
module load anaconda3
module load funannotate/1.8
module unload perl
module unload python
source activate funannotate-1.8

export AUGUSTUS_CONFIG_PATH=$(realpath lib/augustus/3.3/config)
# Set some vars

export FUNANNOTATE_DB=/bigdata/stajichlab/shared/lib/funannotate_db
export PASAHOMEPATH=$(dirname `which Launch_PASA_pipeline.pl`)
export PASAHOME=$(dirname  `which Launch_PASA_pipeline.pl`)
export TRINITY=$(realpath `which Trinity`)
export TRINITYHOMEPATH=$(dirname $TRINITY)
export PASACONF=$(realpath ~/pasa.config.txt)


INDIR=genomes
OUTDIR=annotate
SAMPFILE=genomes/samples.csv


funannotate fix -i annotate-1.8.8/CimmitisRS/update_results/Coccidioides_immitis_RS.gbk -t annotate-1.8.8/CimmitisRS/update_results/Coccidioides_immitis_RS.tbl
