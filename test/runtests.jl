using PowerDynData
using Test

@testset "PowerDynData.jl" begin
    @testset "Metadata loading" begin
        # Test metadata registry loading with bundled metadata
        metadata_dir = pkgdir(PowerDynData, "metadata")
        registry = load_metadata_registry(metadata_dir)

        # Check that registry was created
        @test registry isa MetadataRegistry
        @test length(registry.models) > 0

        # Check that expected models are loaded
        @test haskey(registry.models, "GENROU")
        @test haskey(registry.models, "GENCLS")
        @test haskey(registry.models, "TGOV1")

        # Check GENROU metadata
        genrou = registry.models["GENROU"]
        @test genrou.name == "GENROU"
        @test genrou.category == "generator"
        @test genrou.multi_line == true
        @test genrou.line_count == 3
        @test length(genrou.fields) > 0

        # Check field metadata
        h_field = findfirst(f -> f.name == :H, genrou.fields)
        @test !isnothing(h_field)
        @test genrou.fields[h_field].type == Float64
        @test genrou.fields[h_field].unit == "MW·s/MVA"
    end

    @testset "Type system" begin
        # Test DynamicData construction
        models = Dict{String, DynamicRecords}()
        validation_issues = ValidationIssue[]
        dd = DynamicData(models, nothing, "test.dyr", validation_issues)

        @test dd isa DynamicData
        @test length(dd) == 0
        @test keys(dd) |> collect |> isempty
        @test isempty(dd.validation_issues)
    end

    @testset "Parsing utilities" begin
        # Test model name detection
        line = "1 'GENROU' 1 6.5000 0.60000E-01"
        model_name = PowerDynData.detect_model_name(line)
        @test model_name == "GENROU"

        # Test field parsing
        @test PowerDynData.parse_field(Int, "123") == 123
        @test PowerDynData.parse_field(Float64, "1.5") ≈ 1.5
        @test PowerDynData.parse_field(Float64, "0.60000E-01") ≈ 0.06
        @test PowerDynData.parse_field(String, "'test'") == "test"
        @test PowerDynData.parse_field(String, "test") == "test"
    end

    @testset "DYR file parsing (without metadata)" begin
        testfile = joinpath(@__DIR__, "testfiles", "ieee14.dyr")
        if isfile(testfile)
            # Explicitly disable metadata to test indexed fallback
            dd = parse_dyr(testfile, metadata_dir=nothing)
            @test dd isa DynamicData
            @test length(dd) > 0
            @test haskey(dd, "GENROU")
            @test haskey(dd, "TGOV1")
            @test isnothing(dd.metadata_registry)

            # Check that records were parsed as indexed
            genrou = dd["GENROU"]
            @test genrou isa IndexedDynamicRecords
            @test length(genrou) > 0
        else
            @warn "Test file ieee14.dyr not found, skipping parsing test"
        end
    end

    @testset "DYR file parsing (with metadata)" begin
        testfile = joinpath(@__DIR__, "testfiles", "ieee14.dyr")

        if isfile(testfile)
            # Test with default bundled metadata
            dd = parse_dyr(testfile)
            @test dd isa DynamicData
            @test length(dd) > 0
            @test !isnothing(dd.metadata_registry)

            # Check GENROU parsing
            if haskey(dd, "GENROU")
                genrou = dd["GENROU"]
                @test genrou isa NamedDynamicRecords
                @test length(genrou) == 5  # 5 GENROU units in ieee14

                # Check that fields are named correctly
                field_names = propertynames(genrou.data)
                @test :BUS in field_names
                @test :H in field_names
                @test :Xd in field_names

                # Test DataFrame conversion
                using DataFrames
                df = DataFrame(genrou)
                @test nrow(df) == 5
                @test "BUS" in names(df)
                @test "H" in names(df)

                # Check data types
                @test eltype(df.BUS) == Int
                @test eltype(df.H) == Float64
                @test eltype(df.ID) == String

                # Check specific values
                @test df.BUS[1] == 1
                @test df.H[1] ≈ 4.0
                @test df.ID[1] == "1"
            end

            # Check TGOV1 parsing
            if haskey(dd, "TGOV1")
                tgov1 = dd["TGOV1"]
                @test tgov1 isa NamedDynamicRecords
                @test length(tgov1) == 3  # 3 TGOV1 units in ieee14
            end

            # Check ST2CUT parsing (also has metadata)
            if haskey(dd, "ST2CUT")
                st2cut = dd["ST2CUT"]
                @test st2cut isa NamedDynamicRecords  # Has metadata
                @test length(st2cut) == 2  # 2 ST2CUT units in ieee14
            end

            # Check validation issues were collected (out-of-range values exist in test file)
            @test !isempty(dd.validation_issues)
            @test all(issue -> issue.issue_type in (:out_of_range, :parse_error), dd.validation_issues)

            # Test with explicit custom metadata path (verify override works)
            metadata_dir = joinpath(@__DIR__, "..", "metadata")
            if isdir(metadata_dir)
                dd2 = parse_dyr(testfile, metadata_dir=metadata_dir)
                @test !isnothing(dd2.metadata_registry)
                @test haskey(dd2, "GENROU")
            end
        else
            @warn "Test file not found, skipping parsing test"
        end
    end

    @testset "Field parsing edge cases" begin
        # Scientific notation
        @test PowerDynData.parse_field(Float64, "0.60000E-01") ≈ 0.06
        @test PowerDynData.parse_field(Float64, "1.5e-3") ≈ 0.0015
        @test PowerDynData.parse_field(Float64, "-9999.0") ≈ -9999.0

        # Integer parsing
        @test PowerDynData.parse_field(Int, "  123  ") == 123
        @test PowerDynData.parse_field(Int, "0") == 0

        # String parsing with quotes
        @test PowerDynData.parse_field(String, "'GENROU'") == "GENROU"
        @test PowerDynData.parse_field(String, "  test  ") == "test"
    end

    @testset "ANDES test cases" begin
        # Test all DYR files shipped with ANDES
        test_cases = [
            ("npcc/npcc_full.dyr", "NPCC full dynamics"),
            ("nordic44/N44_BC.dyr", "Nordic44 base case"),
            ("wecc/wecc_gencls.dyr", "WECC with classical generators"),
            ("wecc/wecc_full.dyr", "WECC full dynamics"),
            ("ieee14/ieee14_ieeevc.dyr", "IEEE 14-bus with IEEE voltage controller"),
            ("kundur/kundur_gencls.dyr", "Kundur with classical generators"),
            ("kundur/kundur_full.dyr", "Kundur full dynamics"),
        ]

        for (filename, description) in test_cases
            testfile = joinpath(@__DIR__, "testfiles", filename)

            @testset "$description" begin
                if isfile(testfile)
                    # Test parsing with metadata
                    dd = parse_dyr(testfile)
                    @test dd isa DynamicData
                    @test length(dd) > 0
                    @test !isnothing(dd.metadata_registry)

                    # Verify all models have some records
                    for (model_name, records) in dd.models
                        @test length(records) > 0
                    end

                    # Test that we can convert to DataFrame for models with metadata
                    using DataFrames
                    for (model_name, records) in dd.models
                        if records isa NamedDynamicRecords
                            df = DataFrame(records)
                            @test nrow(df) == length(records)
                        end
                    end
                else
                    @warn "Test file $filename not found, skipping"
                end
            end
        end
    end
end
