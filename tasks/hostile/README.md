# Hostile

> Hostile: removes host sequences from short and long read (meta)genomes, consuming single or paired FASTQ from files or stdin

This tool has been written into a custom WDL task to perform read scrubbing on either Illumina or Oxford Nanopore data. FASTQs will need to be concatenated into a single file for ONT or a single pair of files for Illumina. It also imports the custom `version_capture/structs.wdl` to create a struct that captures the Hostile tool version information.

If running workflows on Terra, the `genome_index` files should be stored as a workspace variable and then that passed as input. For Illumina, the value type will be `string_list` and for Oxford Nanopore, it will be `string`.

## Example usage

For sample-level workflows:
```
import "hostile.wdl" as hostile

workflow Illumina {
    input {
        File fastq1
        File fastq2
        Array[File] scrub_genome_index
    }

    call hostile.scrub_reads_hostile as hostile {
        input:
            fastq1 = fastq_1,
            fastq2 = fastq_2,
            genome_index = select_first([scrub_genome_index]),
            seq_method = "ILLUMINA"
    }
}
```

```
import "hostile.wdl" as hostile

workflow ONT {
    input {
        String barcode_dir
        String sample_name
        File scrub_genome_index
    }

    call concatenate_fastqs {
        input:
            sample_name = sample_name,
            fastq_files = barcode_dir
    }

    call hostile.scrub_reads_hostile as hostile {
        input:
            fastq1 = concatenate_fastqs.concatenated_fastq,
            genome_index = select_all([scrub_genome_index]),
            seq_method = "OXFORD_NANOPORE"
    }
}
```