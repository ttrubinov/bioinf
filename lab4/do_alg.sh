#!/bin/bash

cd ~/Downloads/bioinf
./FastQC/fastqc SRR12799740_1.fastq SRR12799740_2.fastq -o ./fastqc_output
./bwa/bwa mem ./hg38.fa ./SRR12799740_1.fastq ./SRR12799740_2.fastq > aln.sam
./samtools/samtools view -but hg38.fa.gz aln.sam > aln.bam
output_file="out.txt"
./samtools/samtools flagstat aln.bam > $output_file
mapped_percentage=$(grep "mapped" "$output_file" | head -n 1 | awk -F'[()%]' '{print $2}')
echo "Mapped Percentage: ${mapped_percentage}%"
if (( $(echo "$mapped_percentage < 90" | bc -l) )); then
  echo "NOT OK :("
else
  echo "OK :)"
  ./samtools/samtools sort aln.bam > sample.sorted.bam
  ./freebayes/freebayes hg38.fa sample.sorted.bam > sample.vcf
fi
