# Version capture

> Version capture: Captures tools version information into a custom WDL struct and outputs a file including all version information for an entire WDL workflow.

## Tools
- [Docker container documentation](https://github.com/CDPHE-bioinformatics/CDPHE-docker-builds/tree/main/cdphe_wdl_version_capture/)

## Example usage

For sample-level workflows:

```
import "version_capture.wdl" as version_capture

workflow Workflow {
    input {
        String sample_name
        String project_name
    }

    String ubuntu_docker = 'ubuntu:jammy-20240627.1'
    String version_capture_docker = 'ariannaesmith/cdphe_wdl_version_capture:latest'
    String workflow_name = 'Workflow'
    String workflow_version = 'v0.1.0'

    call version_capture.workflow_metadata as workflow_metadata { 
        input: 
            docker = ubuntu_docker,
            workflow_name = workflow_name,
            workflow_version = workflow_version
    }

    # Call various tasks
    call bwa {
        ...
    }
    call ivar {
        ...
    }

    VersionInfo bwa_version = bwa.bwa_version
    VersionInfo ivar_version = ivar.ivar_version
    Array[VersionInfo] version_array = [bwa_version, ivar_version]

    call version_capture.capture_versions as version_cap {
        input:
            analysis_date = workflow_metadata.analysis_date,
            docker = version_capture_docker,        
            project_name = project_name,
            version_array = version_array,
            workflow_name = workflow_name,
            workflow_version = workflow_version_und,
            sample_name = sample_name
    }
}
```

For set-level workflows, `sample_name` should be omitted from the workflow input and the `version_capture` task call.