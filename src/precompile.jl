# Precompilation workload

@setup_workload begin
    # Get path to test NPCC dyr file for precompilation
    npcc_dyr_path = joinpath(pkgdir(PowerDynData), "test", "testfiles", "npcc", "npcc_full.dyr")
    metadata_path = joinpath(pkgdir(PowerDynData), "metadata")

    @compile_workload begin
        # Precompile parsing operations using NPCC test file
        if isfile(npcc_dyr_path)
            # Parse with metadata (most common usage pattern)
            dd = parse_dyr(npcc_dyr_path, metadata_dir=metadata_path)

            # Precompile common accessor patterns
            if !isempty(dd.models)
                # Get first model type
                first_model = first(values(dd.models))

                # Access model data (precompiles getindex operations)
                if haskey(dd.models, "GENROU")
                    genrou = dd["GENROU"]
                end

                # Precompile iteration
                for (name, model) in dd.models
                    # Common access pattern
                    break  # Just one iteration for precompilation
                end
            end

            # Parse without metadata (fallback mode)
            dd_indexed = parse_dyr(npcc_dyr_path, metadata_dir=nothing)
        end
    end
end
