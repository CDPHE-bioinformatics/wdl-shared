version 1.0

struct VersionInfo {
    String software
    String docker
    String version

    meta {
        description: "Custom struct of docker software tool versions. Can be used multiple times in a single task"
    }

    parameter_meta {
        software: "Name of software used"
        docker: "Docker container used in task runtime section"
        version: "Version of software"
    }
}

# workaround cromwell bug with read_json of Array
# https://github.com/openwdl/wdl/issues/409
struct VersionInfoArray {
    Array[VersionInfo] versions

    meta {
        description: "Array of VersionInfo struct objects"
    }
}