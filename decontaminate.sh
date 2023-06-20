#!/bin/bash/

##### Step 1: Quality check

##### Step 2: Check for rRNA contamination

##### Step 3: Clean sequences with kraken2 results 

# kraken single-end reads
for f in ../raw_data/*fastq.gz;
do base_nm=$(basename ${f} _R1.fastq.gz);

kraken2 --use-names \
        --threads 64 \
        --db ../database/ \
        --gzip-compressed \
        --report ${base_nm}.report.kraken \
        --output ${base_nm}.kraken \
        ${f};
echo "Finished run for ${base_nm} at $(date)";
done


##### Step 4:  Remove sequences classified as homo sapiens

# extract seq id from kraken files into list
for file in /kraken_results/*.kraken;
do bs_name=$(basename ${file} .kraken);
grep -v 'Homo sapiens' ${file} | cut -f2 > list_cleaned_${bs_name};
rm ${file};

# seqtk subseq the listed ids from original fastq into new cleaned_fastq files
seqtk subseq ../raw_data/${bs_name}.fastq.gz list_cleaned_${bs_name} | gzip > cleaned_${bs_name}.fastq.gz;
echo "${bs_name} ...done at $(date)";
done


##### Step 5: Second clean with Bowtie2 results

# bowtie2 single-end reads
for f in /kraken_clean/*file_R1_.fastq.gz;
do bs_name=$(basename ${f} _R1.fastq.gz);
bowtie2 -t -p 32 -x ../bowtie2/GRCh37/GRCh37 \
        -U ${f} \
        -S ${bs_name}.sam;
rm ${f};
echo "${bs_name} ...done at $(date)";
done


##### Step 6: Clean sequences using SAMtools with bowtie2 results 

# single-end reads
for f in /bowtie2/cleaned*;
do bs_name=$(basename ${f} .sam);
# convert SAM to BAM
samtools view -b ${f} -o ${bs_name}.bam;
# optional: rm large files
rm ${f};
samtools fastq -f 0x4 \
        -0 ${bs_name}1.fastq.gz \
        -s /dev/null -n ${bs_name}.bam;
echo " ${bs_name} ...done at $(date)";
done

##### Step 7: Second kraken2 report

# kraken single-end reads
for f in /cleaned/*fastq.gz;
do base_nm=$(basename ${f} _R1.fastq.gz);

kraken2 --use-names \
        --threads 64 \
        --db ../database/ \
        --gzip-compressed \
        --report ${base_nm}.report.kraken \
        --output ${base_nm}.kraken \
        ${f};
echo "Finished run for ${base_nm} at $(date)";
done

# Step 8: Bracken species OR Krona plots?

