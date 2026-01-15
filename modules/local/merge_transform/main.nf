process MERGE_TRANSFORM {
    label 'process_single'
    input:
    path(input_dir)
    val(transform_folder)

    output:
    path( "$transform_folder", emit: transform)

    script:
    def file_list = "'${input_dir.collect{ it.name }.join(',')}'"
    """
    #!/usr/bin/env python

    import os
    from squirrel.library.elastix import load_transform_stack_from_multiple_files
    trans=$file_list
    trans_list=trans.split(',')
    cwd=os.getcwd()
    transform_filepaths=[ os.path.join(cwd,i) for i in trans_list]
    transforms = load_transform_stack_from_multiple_files(transform_filepaths, sequence_stack=False)
    transforms.to_file('${transform_folder}')

    """
    stub:
    """
    mkdir -p $transform_folder
    touch $transform_folder
    """

}
