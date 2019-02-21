configfile: 'config.yaml'

include: 'rules/common.snakefile'
include: 'rules/data.snakefile'
include: 'rules/bcalm.snakefile'
include: 'rules/analyses.snakefile'
include: 'rules/hu_metagenome.snakefile'


rule all:
    input: *result_paths()


rule all_normalized:
    input: *result_paths*(analyses=['boink_normalized_cdbg_stats'])


rule transcriptomes_all:
    input: *result_paths(types=['transcriptome'])


rule transcriptomes_cdbg_stats:
    input: 
        *result_paths(types=['transcriptome'],
                      analyses=['boink_cdbg_stats'])


rule transcriptomes_normalized:
    input: 
        *result_paths(types=['transcriptome'],
                      analyses=['boink_normalized_cdbg_stats'])

rule transcriptomes_bcalm:
    input: 
        *result_paths(types=['transcriptome'],
                      analyses=['bcalm'])


rule genomes_all:
    input: *result_paths(types=['genome'])


rule genomes_normalized:
    input: 
        *result_paths(types=['genome'],
                      analyses=['boink_normalized_cdbg_stats'])


rule genomes_bcalm:
    input: 
        *result_paths(types=['genome'],
                      analyses=['bcalm'])


rule hu_metagenome_all:
    input: 
        expand('outputs/Hu_metagenome/hu-genome{hu_id}/boink.cdbg.components.csv',
               hu_id=list(range(19, 42))),
        expand('outputs/Hu_metagenome/normalized/hu-genome{hu_id}/boink.cdbg.components.csv',
               hu_id=list(range(19, 42))),
        'outputs/Hu_metagenome/hu-merged/boink.cdbg.components.csv'

rule hu_metagenome_normalized:
    input: 
        expand('outputs/Hu_metagenome/normalized/hu-genome{hu_id}/boink.cdbg.components.csv',
               hu_id=list(range(19, 42)))


rule hu_merged_cdbg_stats:
    input: 'outputs/Hu_metagenome/hu-merged/boink.cdbg.components.csv'
