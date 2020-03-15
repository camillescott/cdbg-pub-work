rule do_bcalm:
    input:
        'outputs/{sample}/left.trimmed.fq',
        'outputs/{sample}/right.trimmed.fq'
    output: 'outputs/{sample}/bcalm/{ksize}/unitigs.fa'
        #out_dir = directory('outputs/{sample}/bcalm/{ksize}')
    log: 'logs/{sample}/bcalm/{ksize}/rule.log'
    benchmark: 'benchmarks/{sample}/bcalm/{ksize}/benchmark.tsv'
    params:
        ksize = '{ksize}'
    resources:
        mem   = 16,
        hours = 4
    threads: 4
    wrapper: 'file:wrappers/bcalm'


rule boink_cdbg_stats:
    input:
        r1='outputs/{sample}/left.trimmed.fq',
        r2='outputs/{sample}/right.trimmed.fq'
    output:    'outputs/{sample}/boink_cdbg_stats/{ksize}/boink.cdbg.components.csv'
    log:       'logs/{sample}/boink_cdbg_stats/{ksize}/rule.log'
    benchmark: 'benchmarks/{sample}/boink_cdbg_stats/{ksize}/benchmark.tsv'
    version: BOINK_VERSION
    params:
        results_dir     = 'outputs/{sample}/boink_cdbg_stats/{ksize}/',
        storage_type    = lambda wildcards: config['samples'][wildcards.sample]['storage'],
        sample_size     = 10000,
        fine_interval   = lambda wildcards: config['samples'][wildcards.sample]['intervals']['fine'],
        medium_interval = lambda wildcards: config['samples'][wildcards.sample]['intervals']['medium'],
        coarse_interval = lambda wildcards: config['samples'][wildcards.sample]['intervals']['coarse'],
        ksize           = '{ksize}',
        track_cdbg_components = True,
        track_cdbg_stats      = True,
        track_unitig_bp       = True
    resources:
        mem   = lambda wildcards: config['samples'][wildcards.sample]['resources']['mem'],
        hours = lambda wildcards: config['samples'][wildcards.sample]['resources']['hours']
    threads: 4
    wrapper: 'file:wrappers/build-cdbg'


rule boink_normalized_cdbg_stats:
    input:
        r1='outputs/{sample}/left.trimmed.fq',
        r2='outputs/{sample}/right.trimmed.fq'
    output:    'outputs/{sample}/boink_normalized_cdbg_stats/{ksize}/boink.cdbg.components.csv'
    log:       'logs/{sample}/boink_normalized_cdbg_stats/{ksize}/rule.log'
    benchmark: 'benchmarks/{sample}/boink_normalized_cdbg_stats/{ksize}/benchmark.tsv'
    version: BOINK_VERSION
    params:
        results_dir     = 'outputs/{sample}/boink_normalized_cdbg_stats/{ksize}/',
        storage_type    = lambda wildcards: config['samples'][wildcards.sample]['storage'],
        sample_size     = 10000,
        fine_interval   = lambda wildcards: config['samples'][wildcards.sample]['intervals']['fine'],
        medium_interval = lambda wildcards: config['samples'][wildcards.sample]['intervals']['medium'],
        coarse_interval = lambda wildcards: config['samples'][wildcards.sample]['intervals']['coarse'],
        ksize           = '{ksize}',
        normalize       = True,
        track_cdbg_components = True,
        track_cdbg_stats      = True,
        track_unitig_bp       = True
    resources:
        mem   = lambda wildcards: config['samples'][wildcards.sample]['resources']['mem'],
        hours = lambda wildcards: config['samples'][wildcards.sample]['resources']['hours']
    threads: 4
    wrapper: 'file:wrappers/build-cdbg'
