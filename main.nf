#!/usr/bin/env nextflow

fastq_ids = Channel.fromPath( params.in ).splitText()
reference = file(params.db)

process sradownload {

    //errorStrategy 'ignore'
    publishDir params.out, pattern: "*.fastq", overwrite: true
    maxForks 1

    input:
    val(fastq_id) from fastq_ids

    output:
    tuple val("${fastq_id.trim()}"), file("${fastq_id.trim()}.fastq") into fastqs 
    

    """
    fastq-dump ${fastq_id.trim()}
    """
}

process mash {

    //errorStrategy 'ignore'
    publishDir params.out, mode: 'copy', pattern: "*.out", overwrite: true

    input:
    tuple val(name), file(fastq) from fastqs

    output:
    file("${name}.out") into results

    """
    mash screen -w ${reference} $fastq | sort -gr > ${name}.out
    """
}
