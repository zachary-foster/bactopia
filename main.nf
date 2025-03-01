#!/usr/bin/env nextflow
nextflow.enable.dsl = 2
include { is_available_workflow } from './lib/nf/functions'

if (is_available_workflow(params.wf)) {
    if (params.workflows[params.wf].containsKey('is_workflow')) {
        if (params.wf == "staphopia") {
            include { STAPHOPIA } from './workflows/staphopia'
        } else {
            include { BACTOPIA } from './workflows/bactopia'
        }
    } else {
        include { BACTOPIATOOLS } from './workflows/bactopia-tools'
    }
} else {
    log.error "${params.wf} is not an available workflow or Bactopia Tool. Use --list_wfs to see full list"
    exit 1
}

/*
========================================================================================
    RUN WORKFLOWS
========================================================================================
*/

workflow {
    if (params.workflows[params.wf].containsKey('is_workflow')) {
        if (params.wf == "staphopia") {
            STAPHOPIA()
        } else {
            BACTOPIA()
        }
    } else {
        BACTOPIATOOLS()
    }
}

/*
========================================================================================
    THE END
========================================================================================
*/
