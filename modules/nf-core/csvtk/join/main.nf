// Import generic module functions
include { get_resources; initOptions; saveFiles } from '../../../../lib/nf/functions'
RESOURCES   = get_resources(workflow.profile, params.max_memory, params.max_cpus)
options     = initOptions(params.containsKey("options") ? params.options : [:], 'csvtk_join')
publish_dir = params.is_subworkflow ? "${params.outdir}/bactopia-tools/${params.wf}/${params.run_name}" : params.outdir
conda_tools = "bioconda::csvtk=0.25.0"
conda_name  = conda_tools.replace("=", "-").replace(":", "-").replace(" ", "-")
conda_env   = file("${params.condadir}/${conda_name}").exists() ? "${params.condadir}/${conda_name}" : conda_tools

process CSVTK_JOIN {
    tag "$meta.id"
    label 'process_low'
    publishDir "${publish_dir}/${meta.id}", mode: params.publish_dir_mode, overwrite: params.force,
        saveAs: { filename -> saveFiles(filename:filename, opts:options) }

    conda (params.enable_conda ? conda_env : null)
    container "${ workflow.containerEngine == 'singularity' && !params.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/csvtk:0.25.0--h9ee0642_0' :
        'quay.io/biocontainers/csvtk:0.25.0--h9ee0642_0' }"

    input:
    tuple val(meta), path(csv1), path(csv2)
    val in_format
    val out_format
    val key

    output:
    tuple val(meta), path("${prefix}.${out_extension}"), emit: csv
    path "*.{log,err}", emit: logs, optional: true
    path ".command.*", emit: nf_logs
    path "versions.yml",emit: versions

    script:
    prefix = options.suffix ? "${options.suffix}" : "${meta.id}"
    def delimiter = in_format == "tsv" ? "--tabs" : (in_format == "csv" ? "" : "--delimiter '${in_format}'")
    def out_delimiter = out_format == "tsv" ? "--out-tabs" : (out_format == "csv" ? "" : "--out-delimiter '${out_format}'")
    out_extension = out_format == "tsv" ? 'tsv' : 'csv'
    """
    csvtk \\
        join \\
        $options.args \\
        --fields $key \\
        --num-cpus $task.cpus \\
        ${delimiter}  \\
        ${out_delimiter} \\
        --out-file ${prefix}.${out_extension} \\
        $csv1 $csv2

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        csvtk: \$(echo \$( csvtk version | sed -e "s/csvtk v//g" ))
    END_VERSIONS
    """
}
