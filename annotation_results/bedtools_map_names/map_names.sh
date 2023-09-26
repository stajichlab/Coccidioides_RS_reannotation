#!/usr/bin/bash
#SBATCH -p short 

module load bedtools

# get released RS annotation
if [ ! -s FungiDB-46_CimmitisRS.gff ]; then
	curl -O https://fungidb.org/common/downloads/release-46/CimmitisRS/gff/data/FungiDB-46_CimmitisRS.gff
fi
if [ ! -s FungiDB-46_CimmitisRS.genes.gff ]; then
	grep -P "\tgene\t" FungiDB-46_CimmitisRS.gff | bedtools sort -i - > FungiDB-46_CimmitisRS.genes.gff
fi
if [ ! -s Coccidioides_immitis_RS.new_genes.gff ]; then
	zgrep -P "\tgene\t" ../Coccidioides_immitis_RS.gff3.gz  | bedtools sort -i - > Coccidioides_immitis_RS.new_genes.gff
	# if you don't have zgrep installed then uncomment this
	# gunzip -dc ../Coccidioides_immitis_RS.gff3.gz | grep -P "\tgene\t" > Coccidioides_immitis_RS.NEW_ANNOTATION.gff3
fi

bedtools intersect -a Coccidioides_immitis_RS.new_genes.gff -b FungiDB-46_CimmitisRS.genes.gff -wo -loj > NewFun2RS_gene_intersection.tab
cut -f1,4-5,7,9,13-14,16,18 NewFun2RS_gene_intersection.tab | perl -p -e 's/ID=(\S+)/$1/g; s/;(\s+)/$1/g;' > NewFun2RS_gene_name_mapping.tab

bedtools intersect -b Coccidioides_immitis_RS.new_genes.gff -a FungiDB-46_CimmitisRS.genes.gff -wo -loj > RS2NewFun_gene_intersection.tab
cut -f1,4-5,7,9,13-14,16,18 RS2NewFun_gene_intersection.tab | perl -p -e 's/ID=(\S+)/$1/g; s/;(\s+)/$1/g;' > RS2NewFun_gene_name_mapping.tab

