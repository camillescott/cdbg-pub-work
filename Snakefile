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


def results(type_filter=None):
    paths = []
    for sample in config['samples'].keys():
        if type_filter is not None:
            if config['samples'][sample]['type'] != type_filter:
                continue
        for ksize in config['samples'][sample]['ksizes']:
            for analysis in ANALYSES:
                if config['samples'][sample]['type'] == 'genome' and analysis == 'node_metrics':
                    continue
                else:
                    paths.append('outputs/{sample}/{analysis}/{ksize}/{name}'.format(
                                 sample   = sample,
                                 ksize    = ksize,
                                 analysis = analysis,
                                 name     = result_name(analysis)))
    return paths


rule all:
    input: *results()


rule transcriptomes:
    input: *results(type_filter='transcriptome')


rule genomes:
    input: *results(type_filter='genome')


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
    threads: 1
    wrapper:
        "0.31.0/bio/trimmomatic/pe"


rule node_metrics:
    input:
        r1='outputs/{sample}/left.trimmed.fq',
        r2='outputs/{sample}/right.trimmed.fq'
    output:    'outputs/{sample}/node_metrics/{ksize}/boink.cdbg.stats.csv'
    log:       'logs/{sample}/node_metrics/{ksize}/rule.log'
    benchmark: 'benchmarks/{sample}/node_metrics/{ksize}/benchmark.tsv'
    version: BOINK_VERSION
    params:
        results_dir     = 'outputs/{sample}/node_metrics/{ksize}/',
        storage_type    = lambda wildcards: config['samples'][wildcards.sample]['storage'],
        fine_interval   = lambda wildcards: config['samples'][wildcards.sample]['intervals']['fine'],
        medium_interval = lambda wildcards: config['samples'][wildcards.sample]['intervals']['medium'],
        coarse_interval = lambda wildcards: config['samples'][wildcards.sample]['intervals']['coarse'],
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
    output:    'outputs/{sample}/component_sampling/{ksize}/boink.cdbg.components.csv'
    log:       'logs/{sample}/component_sampling/{ksize}/rule.log'
    benchmark: 'benchmarks/{sample}/component_sampling/{ksize}/benchmark.tsv'
    version: BOINK_VERSION
    params:
        results_dir     = 'outputs/{sample}/component_sampling/{ksize}/',
        storage_type    = lambda wildcards: config['samples'][wildcards.sample]['storage'],
        sample_size     = 10000,
        fine_interval   = lambda wildcards: config['samples'][wildcards.sample]['intervals']['fine'],
        medium_interval = lambda wildcards: config['samples'][wildcards.sample]['intervals']['medium'],
        coarse_interval = lambda wildcards: config['samples'][wildcards.sample]['intervals']['coarse'],
        ksize           = '{ksize}'
    shell:
        'build-cdbg --storage-type {params.storage_type} -k {params.ksize} --pairing-mode split '
        '--results-dir {params.results_dir} '
        '--track-cdbg-components '
        '--track-cdbg-stats '
        '--component-sample-size {params.sample_size} '
        '--fine-interval {params.fine_interval} --medium-interval {params.medium_interval} --coarse-interval {params.coarse_interval} '
        '-i {input.r1} {input.r2} 2> {log}'
