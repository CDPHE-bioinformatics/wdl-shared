version 1.0

import "structs.wdl"

task workflow_metadata {
    meta {
        description: "Capture GitHub repository version of workflow"
        volatile: true
    }    
    
    parameter_meta {
        docker: "Associated version capture docker container"
        workflow_name: "Name of workflow this task is called from"
        workflow_version: "Version of workflow this task is called from"
    }

    input {
        String docker
        String workflow_name
        String workflow_version
    }


    command <<<
        date +"%Y-%m-%d" > TODAY
    >>>

    output {
        String analysis_date = read_string("TODAY")
        VersionInfo version_info = {
            "software": workflow_name,
            "docker": "",
            "version": workflow_version
        }
    }

    runtime {
        docker: docker
    }
}

task capture_versions {
    meta {
        description: "Create file of software versions used in workflow"
        volatile: true
    }

    parameter_meta {
        version_array: "VersionInfoArray struct object"
        analysis_date: "Analysis date in YYYY-MM-DD format"
        docker: "Associated version capture docker container"
        project_name: "Sequencing run name"
        workflow_name: "Name of workflow this task is called from"
        workflow_version: "Version of workflow this task is called from"
        sample_name: "Optional- use if calling from a sample-level workflow"
    }

    input {
        Array[VersionInfo] version_array
        String analysis_date
        String docker
        String project_name
        String workflow_name
        String workflow_version    
        
        String? sample_name
    }

    VersionInfoArray versions = object {versions: version_array}
    String out_fn = ("version_capture_" + 
                    (if defined(sample_name) then "~{sample_name}_" else "") +
                    "~{workflow_name}_~{project_name}_~{sub(workflow_version, "\\.", "_")}.csv")
    String sample_name_flag = if defined(sample_name) then "--sample_name ~{sample_name}" else ""

    command <<<
        cp $APPDIR/* .
        python3 version_capture.py \
        --analysis_date ~{analysis_date} \
        --docker_name $NAME \
        --docker_host $HOST  \
        --docker_version $VERSION  \
        --out_fn ~{out_fn} \
        --project_name ~{project_name} \
        --versions_json ~{write_json(versions)} \
        ~{sample_name_flag}
    >>>

    output {
        File output_file = out_fn
    }

    runtime {
        docker: docker
    }
}