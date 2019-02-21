rule download_sra:
    output:
        r1='data/{sample}/left.fq',
        r2='data/{sample}/right.fq'
    threads: 8
    params:
        accession=lambda wildcards: get_accession(wildcards.sample)
    shell:
        'fasterq-dump {params.accession} -e {threads} --split-3 '
        '-O data/{wildcards.sample}/ && '
        'mv data/{wildcards.sample}/{params.accession}_1.fastq {output.r1} && '
        'mv data/{wildcards.sample}/{params.accession}_2.fastq {output.r2}'


rule download_data:
    input: *data()


rule trimmomatic:
    input:
        r1="data/{sample}/left.fq",
        r2="data/{sample}/right.fq"
    output:
        r1="outputs/{sample}/left.trimmed.fq",
        r2="outputs/{sample}/right.trimmed.fq",
        # reads where trimming entirely removed the mate
        r1_unpaired="outputs/{sample}/left.trimmed.unpaired.fq",
        r2_unpaired="outputs/{sample}/right.trimmed.unpaired.fq"
    log:
        "logs/{sample}/trimmomatic/rule.log"
    params:
        # list of trimmers (see manual)
        trimmer=lambda wildcards: ["ILLUMINACLIP:data/TruSeq3-PE.fa:2:30:10",
                                   "LEADING:3",
                                   "TRAILING:3",
                                   "SLIDINGWINDOW:4:15",
                                   "MINLEN:{0}".format(max(config['samples'][wildcards.sample]['ksizes']))],
        # optional parameters
        extra=""
    threads: 8
    resources:
        mem=8,
        hours=2
    wrapper:
        "0.31.0/bio/trimmomatic/pe"
