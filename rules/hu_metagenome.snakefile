
rule hu_metagenome_shuffle:
    input:  'data/Hu_metagenome/hu-genome{hu_id}.fa.cdbg_ids.reads.fa'
    output: 'data/Hu_metagenome/hu-genome{hu_id}.fa.cdbg_ids.reads.shuffled.fa'
    threads: 1
    resources:
        mem = 2,
        hours = 1
    shell: 'cat {input} | ./scripts/seq-shuf > {output}'


rule hu_metagenome_merge:
    input: glob.glob('data/Hu_metagenome/hu-genome*.reads.fa')
    output: 'data/Hu_metagenome/merged.reads.fa'
    threads: 1
    resources:
        mem = 2,
        hours = 1
    shell: 'cat {input} | ./scripts/seq-shuf > {output}'


def get_hu_count(hu_id):
    return int(open('data/Hu_metagenome/hu-genome{0}.fa.cdbg_ids.reads.fa.count'.format(hu_id)).read().strip())


rule hu_metagenome_cdbg:
    input:  'data/Hu_metagenome/hu-genome{hu_id}.fa.cdbg_ids.reads.shuffled.fa'
    output: 'outputs/Hu_metagenome/hu-genome{hu_id}/boink.cdbg.components.csv'
    log:    'logs/Hu_metagenome/hu-genome{hu_id}/rule.log'
    version: BOINK_VERSION
    params:
        results_dir           = 'outputs/Hu_metagenome/hu-genome{hu_id}/',
        storage_type          = lambda wildcards: config['hu_metagenome']['storage'],
        fine_interval         = lambda wildcards: round(get_hu_count(wildcards.hu_id) // 100, -2),
        medium_interval       = lambda wildcards: round(get_hu_count(wildcards.hu_id) // 25, -2),
        coarse_interval       = lambda wildcards: round(get_hu_count(wildcards.hu_id) // 10, -2),
        ksize                 = 31,
        track_cdbg_components = True,
        track_cdbg_stats      = True,
        track_unitig_bp       = True
    resources:
        mem   = lambda wildcards: config['hu_metagenome']['resources']['mem'],
        hours = lambda wildcards: (get_hu_count(wildcards.hu_id) // 2000000) + 1
    threads: 4
    wrapper: 'file:wrappers/build-cdbg'


rule hu_metagenome_normalized_cdbg:
    input:  'data/Hu_metagenome/hu-genome{hu_id}.fa.cdbg_ids.reads.shuffled.fa'
    output: 'outputs/Hu_metagenome/normalized/hu-genome{hu_id}/boink.cdbg.components.csv'
    log:    'logs/Hu_metagenome/normalized/hu-genome{hu_id}/rule.log'
    version: BOINK_VERSION
    params:
        results_dir           = 'outputs/Hu_metagenome/normalized/hu-genome{hu_id}/',
        storage_type          = lambda wildcards: config['hu_metagenome']['storage'],
        fine_interval         = lambda wildcards: round(get_hu_count(wildcards.hu_id) // 100, -2),
        medium_interval       = lambda wildcards: round(get_hu_count(wildcards.hu_id) // 25, -2),
        coarse_interval       = lambda wildcards: round(get_hu_count(wildcards.hu_id) // 10, -2),
        ksize                 = 31,
        track_cdbg_components = True,
        track_cdbg_stats      = True,
        track_unitig_bp       = True,
        normalize             = True
    resources:
        mem   = lambda wildcards: config['hu_metagenome']['resources']['mem'],
        hours = lambda wildcards: (get_hu_count(wildcards.hu_id) // 2000000) + 1
    threads: 4
    wrapper: 'file:wrappers/build-cdbg'


rule hu_metagenome_merged_cdbg:
    input:  'data/Hu_metagenome/merged.reads.fa'
    output: 'outputs/Hu_metagenome/hu-merged/boink.cdbg.components.csv'
    log:    'logs/Hu_metagenome/hu-merged/rule.log'
    version: BOINK_VERSION
    params:
        results_dir           = 'outputs/Hu_metagenome/hu-merged/',
        fine_interval         = 10000,
        medium_interval       = 250000,
        coarse_interval       = 1000000,
        ksize                 = 31,
        track_cdbg_components = True,
        track_cdbg_stats      = True
    resources:
        mem   = 16,
        hours = 8
    threads: 4
    wrapper: 'file:wrappers/build-cdbg'

