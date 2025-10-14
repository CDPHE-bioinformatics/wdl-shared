version 1.0

struct VersionInfo {
  String software
  String docker
  String version
}

# workaround cromwell bug with read_json of Array
# https://github.com/openwdl/wdl/issues/409
struct VersionInfoArray {
  Array[VersionInfo] versions
}

task workflow_metadata {
    input {
        String docker
        String workflow_name
        String workflow_version
    }
    meta {
        description: "capture GitHub repository version"
        volatile: true
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
        volatile: true
    }

    input {
        Array[VersionInfo] version_array
        String workflow_name
        String workflow_version
        String project_name
        String analysis_date
        String docker
        String? sample_name
    }

    VersionInfoArray versions = object {versions: version_array}
    String sample_name_flag = if defined(sample_name) then "--sample_name ~{sample_name}" else ""

    command <<<
        cp $APPDIR/* .
        python3 version_capture.py \
        --versions_json ~{write_json(versions)} \
        --workflow_name ~{workflow_name} \
        --workflow_version ~{workflow_version} \
        --project_name ~{project_name} \
        --analysis_date ~{analysis_date} \
        --docker_name $NAME \
        --docker_host $HOST  \
        --docker_version $VERSION  \
        ~{sample_name_flag}
    >>>

    output {
        File output_file = glob("version_capture_*.csv")[0]
    }

    runtime {
        docker: docker
    }
}