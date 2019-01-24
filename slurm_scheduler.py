#!/usr/bin/env python3
"""
Submit this clustering script for sbatch to snakemake with:

    snakemake -j 99 --cluster slurm_scheduler.py
"""

import argparse
import os
import subprocess
import sys
import warnings

from snakemake.utils import read_job_properties


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__,
                                     formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("dependencies", nargs="*",
                        help="{{dependencies}} string given by snakemake\n")
    parser.add_argument("jobscript",
                        help="Snakemake generated shell script with commands to execute snakemake rule\n")
    args = parser.parse_args()

    if args.dependencies:
        dependencies = '-d afterok:' + ':'.join(args.dependencies)
    else:
        dependencies = ''

    job_properties = read_job_properties(args.jobscript)

    cluster_param = {}
    job_resources = job_properties["resources"]

    if not "mem" in job_resources:
        warnings.warn("Rule {rule} has no memory specified, set to default.".format(**job_properties))

    sample  = job_properties['wildcards'].get('sample', '')
    jobname = job_properties['rule']
    if sample:
        jobname = jobname + '-' + sample

    # do something useful with the threads
    cluster_param["threads"] = job_properties.get("threads",1)
    cluster_param['days']    = job_resources.get("days", job_properties["cluster"]['days'])
    cluster_param['hours']   = job_resources.get("hours", job_properties["cluster"]['hours'])
    cluster_param['mem']     = int(job_resources.get("mem", 10)) + 5 #GB + overhead
    cluster_param['name']    = jobname

    cluster_param['account'] = job_properties['cluster']['account']
    cluster_param['email']   = job_properties['cluster']['email']

    sbatch_cmd = "sbatch -A {account} --parsable -c {threads} --export=ALL "\
                 "{dependencies} "\
                 "--time={days:d}-{hours:02d}:00:00 --mem={mem}g "\
                 "--mail-type=FAIL,BEGIN,END --mail-user {email} "\
                 "--job-name={name} {script}".format(script=args.jobscript,
                                                     dependencies=dependencies,
                                                     **cluster_param)

    print(sbatch_cmd, file=sys.stderr)
    popenrv = subprocess.Popen(sbatch_cmd,
                               stdout=subprocess.PIPE,
                               stderr=subprocess.STDOUT,
                               shell=True).communicate()

    # Snakemake expects only id of submitted job on stdout for scheduling
    # with {dependencies}
    try:
        print("%i" % int(popenrv[0].split()[-1]))
    except ValueError:
        print("Not a submitted job: %s" % popenrv[0])
        sys.exit(2)