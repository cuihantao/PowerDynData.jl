using PowerDynData
using Test
using TOML

@testset "PowerDynData.jl" begin
    @testset "Metadata loading (YAML)" begin
        # Test metadata registry loading with YAML metadata (default)
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

    @testset "TOML Parsing" begin
        @testset "TOML parsing with metadata" begin
            toml_file = joinpath(@__DIR__, "testfiles", "ieee14.toml")
            if isfile(toml_file)
                dd = parse_toml(toml_file)

                @test dd isa DynamicData
                @test haskey(dd, "GENROU")
                @test haskey(dd, "TGOV1")
                @test length(dd["GENROU"]) == 5
                @test length(dd["TGOV1"]) == 3

                genrou = dd["GENROU"]
                @test genrou isa NamedDynamicRecords
                @test genrou.data.BUS[1] == 1
                @test genrou.data.H[1] ≈ 4.0

                # Test DataFrame conversion
                using DataFrames
                df = DataFrame(genrou)
                @test nrow(df) == 5
                @test df.BUS[1] == 1
            else
                @warn "Test file ieee14.toml not found, skipping"
            end
        end

        @testset "TOML parsing without metadata" begin
            toml_file = joinpath(@__DIR__, "testfiles", "ieee14.toml")
            if isfile(toml_file)
                dd = parse_toml(toml_file; metadata_dir=nothing)

                @test haskey(dd, "GENROU")
                @test dd["GENROU"] isa IndexedDynamicRecords
            else
                @warn "Test file ieee14.toml not found, skipping"
            end
        end

        @testset "TOML type conversion" begin
            # Test convert_toml_value function
            @test PowerDynData.convert_toml_value(Float64, 1) === 1.0  # Int → Float64
            @test PowerDynData.convert_toml_value(Float64, 1.5) === 1.5
            @test PowerDynData.convert_toml_value(Int, 5.0) === 5  # Float64 → Int (whole number)
            @test PowerDynData.convert_toml_value(String, 123) == "123"
        end

        @testset "TOML validation issues" begin
            # Test with out-of-range value
            test_toml = """
            [[GENROU]]
            BUS = 1
            ID = "1"
            Td10 = 6.5
            Td20 = 0.06
            Tq10 = 0.2
            Tq20 = 0.05
            H = -5.0
            D = 0.0
            Xd = 1.8
            Xq = 1.75
            Xd1 = 0.6
            Xq1 = 0.8
            Xd2 = 0.23
            Xl = 0.15
            S10 = 0.09
            S12 = 0.38
            """

            dd = parse_toml(IOBuffer(test_toml))
            @test haskey(dd, "GENROU")
            @test !isempty(dd.validation_issues)

            # Find the H field validation issue
            h_issue = findfirst(i -> i.field_name == :H, dd.validation_issues)
            @test !isnothing(h_issue)
            @test dd.validation_issues[h_issue].issue_type == :out_of_range
        end

        @testset "Malformed TOML input (HIGH #5)" begin
            # Test 1: Invalid TOML syntax - should throw TOML parse error
            invalid_toml = """
            [[GENROU]
            BUS = 1
            """
            @test_throws TOML.ParserError parse_toml(IOBuffer(invalid_toml))

            # Test 2: Missing closing bracket
            invalid_toml2 = """
            [[GENROU
            BUS = 1
            """
            @test_throws TOML.ParserError parse_toml(IOBuffer(invalid_toml2))

            # Test 3: Invalid value type - string where number expected
            # This should record a parse error, not throw
            invalid_value_toml = """
            [[GENROU]]
            BUS = "not_a_number"
            ID = "1"
            Td10 = 6.5
            Td20 = 0.06
            Tq10 = 0.2
            Tq20 = 0.05
            H = 4.0
            D = 0.0
            Xd = 1.8
            Xq = 1.75
            Xd1 = 0.6
            Xq1 = 0.8
            Xd2 = 0.23
            Xl = 0.15
            S10 = 0.09
            S12 = 0.38
            """
            dd = parse_toml(IOBuffer(invalid_value_toml))
            @test haskey(dd, "GENROU")
            # Should have a parse error for BUS field
            bus_issue = findfirst(i -> i.field_name == :BUS && i.issue_type == :parse_error, dd.validation_issues)
            @test !isnothing(bus_issue)

            # Test 4: Empty TOML - should work with empty models
            empty_toml = ""
            dd = parse_toml(IOBuffer(empty_toml))
            @test dd isa DynamicData
            @test length(dd) == 0

            # Test 5: Non-array entry (single table instead of array) - should be skipped
            single_table_toml = """
            [METADATA]
            version = "1.0"

            [[GENROU]]
            BUS = 1
            ID = "1"
            Td10 = 6.5
            Td20 = 0.06
            Tq10 = 0.2
            Tq20 = 0.05
            H = 4.0
            D = 0.0
            Xd = 1.8
            Xq = 1.75
            Xd1 = 0.6
            Xq1 = 0.8
            Xd2 = 0.23
            Xl = 0.15
            S10 = 0.09
            S12 = 0.38
            """
            dd = parse_toml(IOBuffer(single_table_toml))
            @test !haskey(dd, "METADATA")  # Single table should be skipped
            @test haskey(dd, "GENROU")     # Array table should be parsed
        end

        @testset "Required field validation (HIGH #6)" begin
            # Test 1: Missing required field BUS (has no default)
            missing_required_toml = """
            [[GENROU]]
            ID = "1"
            Td10 = 6.5
            Td20 = 0.06
            Tq10 = 0.2
            Tq20 = 0.05
            H = 4.0
            D = 0.0
            Xd = 1.8
            Xq = 1.75
            Xd1 = 0.6
            Xq1 = 0.8
            Xd2 = 0.23
            Xl = 0.15
            S10 = 0.09
            S12 = 0.38
            """
            dd = parse_toml(IOBuffer(missing_required_toml))
            @test haskey(dd, "GENROU")

            # Should have a validation issue for missing BUS
            bus_issue = findfirst(i -> i.field_name == :BUS, dd.validation_issues)
            @test !isnothing(bus_issue)
            @test dd.validation_issues[bus_issue].issue_type in (:missing_required, :missing_field)

            # Test 2: Missing ID field (has default "1")
            missing_id_toml = """
            [[TGOV1]]
            BUS = 1
            R = 0.05
            Dt = 0.05
            Vmax = 1.05
            Vmin = 0.3
            T1 = 1.0
            T2 = 2.1
            T3 = 0.0
            """
            dd = parse_toml(IOBuffer(missing_id_toml))
            @test haskey(dd, "TGOV1")
            @test length(dd["TGOV1"]) == 1

            # ID should use default value "1"
            @test dd["TGOV1"].data.ID[1] == "1"

            # Test 3: Multiple missing required fields
            minimal_toml = """
            [[GENROU]]
            BUS = 1
            ID = "1"
            """
            dd = parse_toml(IOBuffer(minimal_toml))
            @test haskey(dd, "GENROU")

            # Should have multiple validation issues for missing fields
            @test length(dd.validation_issues) > 0
            missing_issues = filter(i -> i.issue_type in (:missing_required, :missing_field), dd.validation_issues)
            @test length(missing_issues) > 0
        end

        @testset "Unknown fields warning (TOML)" begin
            # Test that unknown fields generate warnings but parsing continues
            unknown_field_toml = """
            [[GENROU]]
            BUS = 1
            ID = "1"
            UNKNOWN_FIELD = 999
            Td10 = 6.5
            Td20 = 0.06
            Tq10 = 0.2
            Tq20 = 0.05
            H = 4.0
            D = 0.0
            Xd = 1.8
            Xq = 1.75
            Xd1 = 0.6
            Xq1 = 0.8
            Xd2 = 0.23
            Xl = 0.15
            S10 = 0.09
            S12 = 0.38
            """
            # This should not throw, just warn
            dd = parse_toml(IOBuffer(unknown_field_toml))
            @test haskey(dd, "GENROU")
            @test dd["GENROU"].data.BUS[1] == 1
        end

        @testset "Type conversion edge cases (TOML)" begin
            # Test self-contained convert_toml_value function
            # Float from string
            @test PowerDynData.convert_toml_value(Float64, "1.5") ≈ 1.5
            @test PowerDynData.convert_toml_value(Float64, "0.60000E-01") ≈ 0.06

            # Int from string
            @test PowerDynData.convert_toml_value(Int, "123") === 123

            # Bool conversions
            @test PowerDynData.convert_toml_value(Bool, "true") === true
            @test PowerDynData.convert_toml_value(Bool, "false") === false
            @test PowerDynData.convert_toml_value(Bool, "1") === true
            @test PowerDynData.convert_toml_value(Bool, "0") === false
            @test PowerDynData.convert_toml_value(Bool, 1) === true
            @test PowerDynData.convert_toml_value(Bool, 0) === false

            # Invalid conversion should throw
            @test_throws ArgumentError PowerDynData.convert_toml_value(Bool, "invalid")
            @test_throws ArgumentError PowerDynData.convert_toml_value(Int, [1, 2, 3])
        end
    end

    @testset "DYR to TOML Conversion" begin
        @testset "Basic conversion" begin
            dyr_file = joinpath(@__DIR__, "testfiles", "ieee14.dyr")
            if isfile(dyr_file)
                # Convert to TOML string
                io = IOBuffer()
                dyr_to_toml(dyr_file, io)
                toml_str = String(take!(io))

                # Verify TOML is valid and contains expected models
                @test contains(toml_str, "[[GENROU]]")
                @test contains(toml_str, "[[TGOV1]]")
                @test contains(toml_str, "BUS = ")
                @test contains(toml_str, "H = ")
            else
                @warn "Test file ieee14.dyr not found, skipping"
            end
        end

        @testset "Round-trip: DYR → TOML → parse" begin
            dyr_file = joinpath(@__DIR__, "testfiles", "ieee14.dyr")
            if isfile(dyr_file)
                dd_original = parse_dyr(dyr_file)

                # Convert to TOML string
                io = IOBuffer()
                dyr_to_toml(dyr_file, io)
                toml_str = String(take!(io))

                # Parse TOML
                dd_converted = parse_toml(IOBuffer(toml_str))

                # Compare GENROU data
                @test haskey(dd_converted, "GENROU")
                @test length(dd_converted["GENROU"]) == length(dd_original["GENROU"])

                # Values should match
                @test dd_original["GENROU"].data.H == dd_converted["GENROU"].data.H
                @test dd_original["GENROU"].data.BUS == dd_converted["GENROU"].data.BUS

                # Compare TGOV1 data
                if haskey(dd_original, "TGOV1") && haskey(dd_converted, "TGOV1")
                    @test length(dd_converted["TGOV1"]) == length(dd_original["TGOV1"])
                end
            else
                @warn "Test file ieee14.dyr not found, skipping"
            end
        end

        @testset "File-based conversion" begin
            dyr_file = joinpath(@__DIR__, "testfiles", "ieee14.dyr")
            if isfile(dyr_file)
                toml_file = tempname() * ".toml"
                try
                    # Convert to file
                    dyr_to_toml(dyr_file, toml_file)
                    @test isfile(toml_file)

                    # Parse and verify
                    dd = parse_toml(toml_file)
                    @test haskey(dd, "GENROU")
                finally
                    rm(toml_file; force=true)
                end
            else
                @warn "Test file ieee14.dyr not found, skipping"
            end
        end
    end

    @testset "Coverage: Tables.jl interface" begin
        testfile = joinpath(@__DIR__, "testfiles", "ieee14.dyr")
        if isfile(testfile)
            dd = parse_dyr(testfile)
            genrou = dd["GENROU"]

            # Test Tables.jl trait methods explicitly with the type
            # These are type-level methods that need to be called with Type{<:NamedDynamicRecords}
            T = typeof(genrou)
            @test Tables.istable(T) == true
            @test Tables.columnaccess(T) == true

            # Test Tables.jl interface functions on instances
            @test Tables.columns(genrou) === genrou.data
            @test Tables.columnnames(genrou) == propertynames(genrou.data)

            # Test getcolumn with Int index
            @test Tables.getcolumn(genrou, 1) == getfield(genrou.data, 1)

            # Test getcolumn with Symbol
            @test Tables.getcolumn(genrou, :BUS) == genrou.data.BUS

            # Also verify Tables integration by using Tables.columns
            cols = Tables.columns(genrou)
            @test :BUS in propertynames(cols)
        end
    end

    @testset "Coverage: Pretty printing" begin
        testfile = joinpath(@__DIR__, "testfiles", "ieee14.dyr")
        if isfile(testfile)
            # Test DynamicData show methods
            dd = parse_dyr(testfile)

            # Compact show
            io = IOBuffer()
            show(io, dd)
            compact_str = String(take!(io))
            @test contains(compact_str, "DynamicData")
            @test contains(compact_str, "models")
            @test contains(compact_str, "records")
            @test contains(compact_str, "with metadata")

            # Detailed show (MIME"text/plain")
            io = IOBuffer()
            show(io, MIME"text/plain"(), dd)
            detailed_str = String(take!(io))
            @test contains(detailed_str, "DynamicData from:")
            @test contains(detailed_str, "Models:")
            @test contains(detailed_str, "Metadata: loaded")
            @test contains(detailed_str, "Validation issues:")

            # NamedDynamicRecords show
            genrou = dd["GENROU"]
            io = IOBuffer()
            show(io, genrou)
            genrou_str = String(take!(io))
            @test contains(genrou_str, "NamedDynamicRecords")
            @test contains(genrou_str, "GENROU")
            @test contains(genrou_str, "records")

            # IndexedDynamicRecords show
            dd_no_meta = parse_dyr(testfile; metadata_dir=nothing)
            indexed = dd_no_meta["GENROU"]
            io = IOBuffer()
            show(io, indexed)
            indexed_str = String(take!(io))
            @test contains(indexed_str, "IndexedDynamicRecords")
            @test contains(indexed_str, "GENROU")

            # DynamicData without metadata
            io = IOBuffer()
            show(io, MIME"text/plain"(), dd_no_meta)
            no_meta_str = String(take!(io))
            @test contains(no_meta_str, "Metadata: not loaded")
        end
    end

    @testset "Coverage: MetadataRegistry show" begin
        metadata_dir = pkgdir(PowerDynData, "metadata")
        registry = load_metadata_registry(metadata_dir)

        # Compact show
        io = IOBuffer()
        show(io, registry)
        compact_str = String(take!(io))
        @test contains(compact_str, "MetadataRegistry")
        @test contains(compact_str, "models")
        @test contains(compact_str, "categories")

        # Detailed show (MIME"text/plain")
        io = IOBuffer()
        show(io, MIME"text/plain"(), registry)
        detailed_str = String(take!(io))
        @test contains(detailed_str, "MetadataRegistry:")
        @test contains(detailed_str, "Total models:")
        @test contains(detailed_str, "Categories:")
    end

    @testset "Coverage: Bool parsing" begin
        # Test parse_field for Bool type
        @test PowerDynData.parse_field(Bool, "1") == true
        @test PowerDynData.parse_field(Bool, "true") == true
        @test PowerDynData.parse_field(Bool, "t") == true
        @test PowerDynData.parse_field(Bool, "TRUE") == true

        @test PowerDynData.parse_field(Bool, "0") == false
        @test PowerDynData.parse_field(Bool, "false") == false
        @test PowerDynData.parse_field(Bool, "f") == false
        @test PowerDynData.parse_field(Bool, "FALSE") == false

        # Test error for invalid bool
        @test_throws ErrorException PowerDynData.parse_field(Bool, "invalid")
    end

    @testset "Coverage: string_to_type" begin
        # Test Bool type conversion
        @test PowerDynData.string_to_type("Bool") == Bool

        # Test error for unknown type
        @test_throws ErrorException PowerDynData.string_to_type("UnknownType")
    end

    @testset "Coverage: validate_range" begin
        # Test validate_range throws error for out of range
        @test_throws ErrorException PowerDynData.validate_range(10.0, (0.0, 5.0), :TestField)
        @test_throws ErrorException PowerDynData.validate_range(-1.0, (0.0, 5.0), :TestField)

        # Test validate_range passes for in-range values (no error thrown)
        @test isnothing(PowerDynData.validate_range(3.0, (0.0, 5.0), :TestField))
    end

    @testset "Coverage: Debug macro" begin
        # Test the @pdebug macro with debug enabled
        old_level = PowerDynData.DEBUG_LEVEL[]
        try
            # Enable debug level
            PowerDynData.DEBUG_LEVEL[] = 2
            @test PowerDynData.DEBUG_LEVEL[] == 2

            # Parse a file with debug enabled to trigger debug output
            # This exercises the debug print path in the @pdebug macro
            testfile = joinpath(@__DIR__, "testfiles", "ieee14.dyr")
            if isfile(testfile)
                dd = parse_dyr(testfile)
                @test dd isa DynamicData
            end
        finally
            PowerDynData.DEBUG_LEVEL[] = old_level
        end
    end

    @testset "Coverage: skip_whitespace_and_comments (SubString)" begin
        # Test the skip_whitespace_and_comments function for SubString
        lines = split("@! comment\n\ndata line\n// another comment", '\n')
        result = PowerDynData.skip_whitespace_and_comments(lines, 1)
        @test result == 3  # Should skip to "data line"

        # Test when starting past comments
        result2 = PowerDynData.skip_whitespace_and_comments(lines, 3)
        @test result2 == 3  # Should stay at "data line"

        # Test when all lines are comments/empty
        all_comments = split("@! comment\n// comment\n\n", '\n')
        result3 = PowerDynData.skip_whitespace_and_comments(all_comments, 1)
        @test result3 > length(all_comments)  # Should return index past end
    end

    @testset "Coverage: Metadata parse failure handling" begin
        # Test that invalid YAML files are handled gracefully
        # Create a temporary directory with an invalid YAML file
        mktempdir() do tmpdir
            invalid_yaml = joinpath(tmpdir, "invalid.yaml")
            write(invalid_yaml, "invalid: yaml: syntax [")

            # Loading should not throw, but warn
            registry = load_metadata_registry(tmpdir)
            @test registry isa MetadataRegistry
            @test isempty(registry.models)  # Invalid file should not add any models
        end
    end

    @testset "Coverage: DynamicData validation issues display" begin
        # Test show when there are only parse errors (no out-of-range)
        toml_with_parse_error = """
        [[GENROU]]
        BUS = "not_an_int"
        ID = "1"
        Td10 = 6.5
        Td20 = 0.06
        Tq10 = 0.2
        Tq20 = 0.05
        H = 4.0
        D = 0.0
        Xd = 1.8
        Xq = 1.75
        Xd1 = 0.6
        Xq1 = 0.8
        Xd2 = 0.23
        Xl = 0.15
        S10 = 0.09
        S12 = 0.38
        """
        dd = parse_toml(IOBuffer(toml_with_parse_error))

        io = IOBuffer()
        show(io, MIME"text/plain"(), dd)
        output = String(take!(io))
        @test contains(output, "parse errors")
    end

    @testset "Coverage: DynamicData without validation issues" begin
        # Create a minimal DynamicData without any validation issues
        using StructArrays
        data = StructArray(BUS=[1], ID=["1"])
        records = NamedDynamicRecords("TEST", "test", data)
        models = Dict{String, DynamicRecords}("TEST" => records)
        dd = DynamicData(models, nothing, "test.dyr", ValidationIssue[])

        io = IOBuffer()
        show(io, MIME"text/plain"(), dd)
        output = String(take!(io))
        @test !contains(output, "Validation issues")
    end

    @testset "Coverage: DYR with comment lines" begin
        # Test parsing DYR content with comment lines to cover skip_whitespace_and_comments_vec
        dyr_with_comments = """
        @! This is a comment
        // Another comment style

        1 'GENCLS' 1 5.0 0.0 /
        """
        dd = parse_dyr(IOBuffer(dyr_with_comments))
        @test haskey(dd, "GENCLS")
        @test length(dd["GENCLS"]) == 1
    end

    @testset "Coverage: DYR missing field position" begin
        # Test when a field position in metadata exceeds the number of fields in the DYR record
        # This tests line 341 in parsing.jl (return FieldValue() for missing position)

        # Create a custom metadata directory with a model that has more fields than the DYR record provides
        mktempdir() do tmpdir
            # Create YAML metadata file with more fields than we'll provide in the DYR
            metadata_yaml = """
model:
  name: TESTMODEL
  description: Test model with many fields
  category: test

parsing:
  model_name_field: 2
  multi_line: false
  terminator: "/"

fields:
  - name: BUS
    position: 1
    type: Int

  - name: ID
    position: 3
    type: String
    default: "1"

  - name: EXTRA_FIELD
    position: 10
    type: Float64
    default: 0.0
            """
            write(joinpath(tmpdir, "testmodel.yaml"), metadata_yaml)

            # DYR record with only 4 fields (position 10 doesn't exist)
            dyr_content = """
            1 'TESTMODEL' '1' 5.0 /
            """
            dd = parse_dyr(IOBuffer(dyr_content); metadata_dir=tmpdir)
            @test haskey(dd, "TESTMODEL")

            # The EXTRA_FIELD at position 10 should use its default value
            @test dd["TESTMODEL"].data.EXTRA_FIELD[1] == 0.0
        end
    end
end
