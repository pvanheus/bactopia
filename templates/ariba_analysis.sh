#!/bin/bash
set -e
set -u

ariba run !{dataset} !{fq} !{dataset_name} \
        --nucmer_min_id !{params.nucmer_min_id} \
        --nucmer_min_len !{params.nucmer_min_len} \
        --nucmer_breaklen !{params.nucmer_breaklen} \
        --assembly_cov !{params.assembly_cov} \
        --min_scaff_depth !{params.min_scaff_depth} \
        --assembled_threshold !{params.assembled_threshold} \
        --gene_nt_extend !{params.gene_nt_extend} \
        --unique_threshold !{params.unique_threshold} \
        --threads !{task.cpus} \
        --force \
        --noclean \
        --verbose !{spades_options}

ariba summary !{dataset_name}/summary !{dataset_name}/report.tsv \
      --cluster_cols assembled,match,known_var,pct_id,ctg_cov,novel_var \
      --col_filter n --row_filter n
rm -rf ariba.tmp*