#!/bin/bash

files="file_name_1
file_name_2
file_name_3"


### The following loop will run ustacks on each sample in the project. 
id=1
for sample in $files
do
    ustacks -t gzfastq -f /project/${sample}.1.fq.gz -o /project/stacks -i $id --name $sample -M 5 -p 12
    let "id+=1"
done

# Build the catalog of loci available in the metapopulation from the samples contained in the population map.
cstacks -n 6 -P /project/stacks -M /project/popmap.txt -p 16

# Run sstacks. Match all samples supplied in the population map against the catalog.
sstacks -P /project/stacks -M /project/popmap.txt -p 16

# Run tsv2bam to transpose the data so it is stored by locus, instead of by sample.
tsv2bam -P /project/stacks -M /project/popmap.txt  --pe-reads-dir /project/samples -t 16

# Run gstacks: build a paired-end contig from the metapopulation data, align reads per sample, call variant sites in the population, genotypes in each individual.
gstacks -P /project/stacks -M /project/popmap.txt -t 16

# Run populations. Calculate Hardy-Weinberg deviation, population statistics, f-statistics. Export as genepop and vcf
populations -P /project/stacks -M /project/popmap.txt --out-path /project/stacks -t 16 -r 0.75 --fstats --hwe --genepop --vcf
