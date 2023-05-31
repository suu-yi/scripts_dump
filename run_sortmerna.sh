#!/usr/bin/env bash

echo "#####################################################"
echo ">>> Starting sortmerna at $(date)"

for file in HI_data/*/*1_001.fastq.gz;
        do bn=$(basename ${file} _R1_001.fastq.gz);
	sortmerna \
		--threads 16 \
		-ref silva_rrna/silva-bac-16s-id90.fasta \
		-ref silva_rrna/silva-bac-23s-id98.fasta \
		-ref silva_rrna/silva-euk-18s-id95.fasta \
		-ref silva_rrna/silva-euk-28s-id98.fasta \
		-reads ${file} \
		-reads ${file%%1_001.fastq.gz}2_001.fastq.gz;
	mkdir sortmerna/run/${bn};
	mv sortmerna/run/[or]* sortmerna/run/${bn}/
	rm -rf $HOME/sortmerna/run/kvdb/;
	echo "... ${bn} done";
done

echo ">>> Completed at $(date)"

