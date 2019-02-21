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
        ksize           = '{ksize}'
    resources:
        mem   = lambda wildcards: config['samples'][wildcards.sample]['resources']['mem'],
        hours = lambda wildcards: config['samples'][wildcards.sample]['resources']['hours']
    threads: 4
    shell:
        'build-cdbg --storage-type {params.storage_type} -k {params.ksize} --pairing-mode split '
        '--results-dir {params.results_dir} '
        '--track-cdbg-components '
        '--track-cdbg-stats '
        '--component-sample-size {params.sample_size} '
        '--fine-interval {params.fine_interval} --medium-interval {params.medium_interval} --coarse-interval {params.coarse_interval} '
        '-i {input.r1} {input.r2} > {log} 2>&1'


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
        normalize       = True
    resources:
        mem   = lambda wildcards: config['samples'][wildcards.sample]['resources']['mem'],
        hours = lambda wildcards: config['samples'][wildcards.sample]['resources']['hours']
    threads: 4
    shell:
        'build-cdbg --storage-type {params.storage_type} -k {params.ksize} --pairing-mode split '
        '--results-dir {params.results_dir} '
        '--track-cdbg-components '
        '--track-cdbg-stats '
        '--component-sample-size {params.sample_size} '
        '--fine-interval {params.fine_interval} --medium-interval {params.medium_interval} --coarse-interval {params.coarse_interval} '
        '-i {input.r1} {input.r2} > {log} 2>&1'
