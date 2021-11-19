// Import generic module functions
include { initOptions; saveFiles } from '../../../../lib/nf/functions'

options     = initOptions(params.options ? params.options : [:], 'roary')
publish_dir = params.is_subworkflow ? "${params.outdir}/bactopia-tools/${params.wf}/${params.run_name}" : params.outdir

process ROARY {
    tag "$meta.id"
    label 'process_medium'
    publishDir "${publish_dir}", mode: params.publish_dir_mode, overwrite: params.force,
        saveAs: { filename -> saveFiles(filename:filename, opts:options) }

    conda (params.enable_conda ? "bioconda::roary=3.13.0" : null)
    container "${ workflow.containerEngine == 'singularity' && !params.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/roary:3.13.0--pl526h516909a_0' :
        'quay.io/biocontainers/roary:3.13.0--pl526h516909a_0' }"

    input:
    tuple val(meta), path(gff)

    output:
    tuple val(meta), path("results/*")                , emit: results
    tuple val(meta), path("*.aln")                    , emit: aln
    tuple val(meta), path("gene_presence_absence.csv"), emit: csv
    path "*.{stdout.txt,stderr.txt,log,err}"          , emit: logs, optional: true
    path ".command.*"                                 , emit: nf_logs
    path "versions.yml"                               , emit: versions

    script:
    def prefix = options.suffix ? "${meta.id}${options.suffix}" : "${meta.id}"
    """
    roary \\
        $options.args \\
        -p $task.cpus \\
        -f results/ \\
        $gff

    cp results/gene_presence_absence.csv ./
    cp results/*.aln ./
    gzip results/*.aln

    cat <<-END_VERSIONS > versions.yml
    roary:
        roary: \$( roary --version )
    END_VERSIONS
    """
}
