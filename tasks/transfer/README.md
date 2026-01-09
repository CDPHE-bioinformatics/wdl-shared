# Transfer

> Version capture: Transfer WDL task outputs to Google Cloud Storage.

## Example usage

For sample or set-level workflows:

```
import "transfer.wdl" as transfer

workflow Workflow {
    input {
        Boolean overwrite # e.g. false
        String out_dir # e.g. gs://my_bucket/parent_directory
    }

    # Call various tasks
    call bwa {
        ...
    }
    call ivar {
        ...
    }

    SubdirsToFiles subdirs_to_files = object { subdirs_to_files: [
        ("bwa", [bwa.sam]),
        ("ivar", [ivar.bam, ivar.bai])
    ]}

    call transfer_task.transfer {
        input:
            out_dir = out_dir,
            overwrite = overwrite,
            subdirs_to_files = subdirs_to_files
    }
}
```
