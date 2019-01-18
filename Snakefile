configfile: 'config.yaml'


BOINK_VERSION = subprocess.check_output('git ls-remote https://github.com/camillescott/boink.git refs/heads/master | cut -f 1', shell=True)
ANALYSES      = ['node_metrics', 'component_sampling']


def result_name(analysis):
    if analysis == 'node_metrics':
        return 'boink.cdbg.stats.csv'
    elif analysis == 'component_sampling':
        return 'boink.cdbg.components.csv'
    else:
        raise ValueError()


def results(wildcards):
    paths = []
    for sample in config['samples'].keys():
        for ksize in config['samples'][sample]['ksizes']:
            for analysis in ANALYSES:
                paths.append('outputs/{sample}/{analysis}/{ksize}/{name}'.format(
                             sample   = sample,
                             ksize    = ksize,
                             analysis = analysis,
                             name     = result_name(analysis)))
    return paths


rule all:
    input: results


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
        "logs/trimmomatic/{sample}.log"
    params:
        # list of trimmers (see manual)
        trimmer=lambda wildcards: ["ILLUMINACLIP:data/TruSeq3-PE.fa:2:30:10",
                                   "LEADING:3",
                                   "TRAILING:3",
                                   "SLIDINGWINDOW:4:15",
                                   "MINLEN:{0}".format(max(config['samples'][wildcards.sample]['ksizes']))],
        # optional parameters
        extra=""
    threads: 1
    wrapper:
        "0.31.0/bio/trimmomatic/pe"


rule node_metrics:
    input:
        r1='outputs/{sample}/left.trimmed.fq',
        r2='outputs/{sample}/right.trimmed.fq'
    output: 'outputs/{sample}/node_metrics/{ksize}/boink.cdbg.stats.csv'
    log: 'logs/boink-build/{sample}/node_metrics/{ksize}/rule.log'
    version: BOINK_VERSION
    params:
        results_dir     = 'outputs/{sample}/node_metrics/{ksize}/',
        storage_type    = lambda wildcards: config['samples'][wildcards.sample]['storage'],
        fine_interval   = 10000,
        medium_interval = 250000,
        coarse_interval = 1000000,
        ksize           = '{ksize}'
    shell:
        'build-cdbg --storage-type {params.storage_type} -k {params.ksize} --pairing-mode split '
        '--results-dir {params.results_dir} --track-cdbg-stats '
        '--fine-interval {params.fine_interval} --medium-interval {params.medium_interval} --coarse-interval {params.coarse_interval} '
        '-i {input.r1} {input.r2} 2> {log}'


rule component_sampling:
    input:
        r1='outputs/{sample}/left.trimmed.fq',
        r2='outputs/{sample}/right.trimmed.fq'
    output: 'outputs/{sample}/component_sampling/{ksize}/boink.cdbg.components.csv'
    log: 'logs/boink-build/{sample}/component_sampling/{ksize}/rule.log'
    version: BOINK_VERSION
    params:
        results_dir     = 'outputs/{sample}/component_sampling/{ksize}/',
        storage_type    = lambda wildcards: config['samples'][wildcards.sample]['storage'],
        sample_size     = 10000,
        fine_interval   = 100000,
        medium_interval = 250000,
        coarse_interval = 1000000,
        ksize           = '{ksize}'
    shell:
        'build-cdbg --storage-type {params.storage_type} -k {params.ksize} --pairing-mode split '
        '--results-dir {params.results_dir} '
        '--track-cdbg-components '
        '--component-sample-size {params.sample_size}'
        '--fine-interval {params.fine_interval} --medium-interval {params.medium_interval} --coarse-interval {params.coarse_interval} '
        '-i {input.r1} {input.r2} 2> {log}'
