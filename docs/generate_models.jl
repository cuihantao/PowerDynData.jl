# Model documentation generator
# Generates markdown files from YAML metadata

using PowerDynData

# Display names for categories (fallback to title case if not defined)
const CATEGORY_DISPLAY_NAMES = Dict(
    "generator" => "Generators",
    "exciter" => "Exciters",
    "governor" => "Governors",
    "stabilizer" => "Stabilizers",
    "voltage_compensator" => "Voltage Compensators",
    # Renewable subcategories all map to "Renewable Energy"
    "renewable_converter" => "Renewable Energy",
    "renewable_electrical" => "Renewable Energy",
    "renewable_plant" => "Renewable Energy",
    "renewable_drive_train" => "Renewable Energy",
    "renewable_pitch" => "Renewable Energy",
    "renewable_torque" => "Renewable Energy",
    "renewable_aero" => "Renewable Energy",
    "renewable_aerodynamics" => "Renewable Energy",
    "renewable_governor" => "Renewable Energy",
)

# Category descriptions
const CATEGORY_DESCRIPTIONS = Dict(
    "Generators" => "Synchronous machine models representing rotating generators in power systems.",
    "Exciters" => "Excitation system models that control generator field voltage and reactive power output.",
    "Governors" => "Governor and prime mover models that control mechanical power input to generators.",
    "Stabilizers" => "Power system stabilizer models that provide supplementary damping control.",
    "Voltage Compensators" => "Voltage compensation models for generator reactive power control.",
    "Renewable Energy" => "Renewable energy source models including wind turbine and solar PV components.",
)

# Order for sidebar navigation
const CATEGORY_ORDER = [
    "Generators",
    "Exciters",
    "Governors",
    "Stabilizers",
    "Voltage Compensators",
    "Renewable Energy",
]

# Default PSS/E version for documentation (all bundled models are version 33)
const DEFAULT_PSSE_VERSION = 33

# GitHub repository for issue reporting
const GITHUB_REPO = "cuihantao/PowerDynData.jl"

#=============================================================================
# Helper functions for consistent sorting
=============================================================================#

"""
    sorted_models(models) -> Vector{ModelMetadata}

Sort models alphabetically by name.
"""
sorted_models(models) = sort(collect(models), by=m -> m.name)

"""
    sorted_model_names(models) -> Vector{String}

Get sorted list of model names.
"""
sorted_model_names(models) = [m.name for m in sorted_models(models)]

"""
    uri_encode(s::String) -> String

Simple URI encoding for issue URL parameters.
"""
function uri_encode(s::String)::String
    s = replace(s, "%" => "%25")  # Must be first
    s = replace(s, " " => "%20")
    s = replace(s, "\n" => "%0A")
    s = replace(s, "#" => "%23")
    s = replace(s, "&" => "%26")
    s = replace(s, "=" => "%3D")
    s = replace(s, "?" => "%3F")
    s = replace(s, "[" => "%5B")
    s = replace(s, "]" => "%5D")
    return s
end

"""
    generate_issue_url(model_name::String) -> String

Generate GitHub issue URL with prefilled model name and template.
"""
function generate_issue_url(model_name::String)::String
    title = uri_encode("[Model] $model_name: ")
    body = uri_encode("""
**Model**: $model_name

## Issue Description
<!-- Describe the issue with this model's metadata -->

## Expected Behavior
<!-- What should happen? -->

## Additional Context
<!-- Any relevant details, PSS/E version, references, etc. -->
""")
    return "https://github.com/$GITHUB_REPO/issues/new?title=$title&body=$body&labels=model-metadata"
end

"""
    get_display_category(category::String) -> String

Get the display name for a category.
"""
function get_display_category(category::String)::String
    return get(CATEGORY_DISPLAY_NAMES, category, titlecase(replace(category, "_" => " ")))
end

"""
    format_type(t::Type) -> String

Format a Julia type for display.
"""
function format_type(t::Type)::String
    if t == Int
        return "Int"
    elseif t == Float64
        return "Float64"
    elseif t == String
        return "String"
    elseif t == Bool
        return "Bool"
    else
        return string(t)
    end
end

"""
    format_default(default) -> String

Format a default value for display in table.
"""
function format_default(default)::String
    if isnothing(default)
        return "-"
    elseif default isa String
        return "\"$default\""
    else
        return string(default)
    end
end

"""
    format_range(range) -> String

Format a range tuple for display.
"""
function format_range(range)::String
    if isnothing(range)
        return "-"
    end
    min_val, max_val = range
    min_str = isinf(min_val) ? (min_val < 0 ? "-∞" : "∞") : string(min_val)
    max_str = isinf(max_val) ? (max_val < 0 ? "-∞" : "∞") : string(max_val)
    return "[$min_str, $max_str]"
end

"""
    format_unit(unit::String) -> String

Format unit for display (handle dimensionless).
"""
function format_unit(unit::String)::String
    if unit == "dimensionless" || isempty(unit)
        return "-"
    end
    return unit
end

"""
    escape_markdown(s::String) -> String

Escape special markdown characters in a string.
"""
function escape_markdown(s::String)::String
    # Escape pipe characters which break tables
    s = replace(s, "|" => "\\|")
    return s
end

"""
    generate_parameter_table(model::PowerDynData.ModelMetadata) -> String

Generate markdown parameter table for a model.
"""
function generate_parameter_table(model::PowerDynData.ModelMetadata)::String
    lines = String[]

    # Table header
    push!(lines, "| # | Name | Type | Unit | Description | Default | Range |")
    push!(lines, "|---|------|------|------|-------------|---------|-------|")

    # Sort fields by position for consistent ordering
    sorted_fields = sort(model.fields, by=f -> f.position)

    for (i, field) in enumerate(sorted_fields)
        name = string(field.name)
        type_str = format_type(field.type)
        unit = format_unit(field.unit)
        desc = escape_markdown(field.description)
        default = format_default(field.default)
        range = format_range(field.range)

        push!(lines, "| $i | $name | $type_str | $unit | $desc | $default | $range |")
    end

    return join(lines, "\n")
end

"""
    generate_model_section(model::PowerDynData.ModelMetadata) -> String

Generate markdown section for a single model.
"""
function generate_model_section(model::PowerDynData.ModelMetadata)::String
    lines = String[]

    # Model header with anchor
    push!(lines, "## $(model.name)")
    push!(lines, "")
    push!(lines, "**$(model.description)**")
    push!(lines, "")

    # Model info
    push!(lines, "- **PSS/E Version**: $(DEFAULT_PSSE_VERSION)")
    if model.multi_line
        push!(lines, "- **Input Lines**: $(model.line_count)")
    else
        push!(lines, "- **Input Lines**: 1")
    end
    push!(lines, "- **Parameters**: $(length(model.fields))")
    push!(lines, "- [Report an issue]($(generate_issue_url(model.name)))")
    push!(lines, "")

    # Parameter table
    push!(lines, "### Parameters")
    push!(lines, "")
    push!(lines, generate_parameter_table(model))
    push!(lines, "")

    # Placeholder for future content
    push!(lines, "")

    return join(lines, "\n")
end

"""
    generate_category_page(display_category::String, models::Vector{PowerDynData.ModelMetadata}) -> String

Generate markdown content for a category page.
"""
function generate_category_page(display_category::String, models::Vector{PowerDynData.ModelMetadata})::String
    lines = String[]

    # Page title
    push!(lines, "# $display_category")
    push!(lines, "")

    # Category description
    desc = get(CATEGORY_DESCRIPTIONS, display_category, "")
    if !isempty(desc)
        push!(lines, desc)
        push!(lines, "")
    end

    # Quick navigation
    push!(lines, "## Models")
    push!(lines, "")
    model_links = ["[$(m.name)](#$(lowercase(m.name)))" for m in sorted_models(models)]
    push!(lines, join(model_links, " | "))
    push!(lines, "")
    push!(lines, "---")
    push!(lines, "")

    # Generate section for each model
    for model in sorted_models(models)
        push!(lines, generate_model_section(model))
        push!(lines, "---")
        push!(lines, "")
    end

    return join(lines, "\n")
end

"""
    generate_overview_page(registry::PowerDynData.MetadataRegistry, category_map::Dict{String, Vector{PowerDynData.ModelMetadata}}) -> String

Generate the model library overview page.
"""
function generate_overview_page(registry::PowerDynData.MetadataRegistry, category_map::Dict{String, Vector{PowerDynData.ModelMetadata}})::String
    lines = String[]

    push!(lines, "# Model Library")
    push!(lines, "")
    push!(lines, "PowerDynData.jl supports $(length(registry.models)) dynamic models across $(length(category_map)) categories.")
    push!(lines, "")

    # Category summary
    push!(lines, "## Categories")
    push!(lines, "")
    push!(lines, "| Category | Models | Count |")
    push!(lines, "|----------|--------|-------|")

    for display_cat in CATEGORY_ORDER
        if haskey(category_map, display_cat)
            models = category_map[display_cat]
            model_names = join(sorted_model_names(models), ", ")
            filename = category_to_filename(display_cat)
            push!(lines, "| [$display_cat]($filename) | $model_names | $(length(models)) |")
        end
    end

    # Handle any categories not in CATEGORY_ORDER
    for display_cat in sort(collect(keys(category_map)))
        if !(display_cat in CATEGORY_ORDER)
            models = category_map[display_cat]
            model_names = join(sorted_model_names(models), ", ")
            filename = category_to_filename(display_cat)
            push!(lines, "| [$display_cat]($filename) | $model_names | $(length(models)) |")
        end
    end

    push!(lines, "")

    # Alphabetical model list
    push!(lines, "## All Models")
    push!(lines, "")
    push!(lines, "| Model | Category | Description |")
    push!(lines, "|-------|----------|-------------|")

    for model in sorted_models(values(registry.models))
        display_cat = get_display_category(model.category)
        filename = category_to_filename(display_cat)
        anchor = lowercase(model.name)
        desc = escape_markdown(model.description)
        push!(lines, "| [$(model.name)]($filename#$anchor) | $display_cat | $desc |")
    end

    push!(lines, "")

    return join(lines, "\n")
end

"""
    category_to_filename(display_category::String) -> String

Convert display category name to markdown filename.
"""
function category_to_filename(display_category::String)::String
    return lowercase(replace(display_category, " " => "_")) * ".md"
end

"""
    generate_model_docs(output_dir::String)

Generate all model documentation files.
"""
function generate_model_docs(output_dir::String)
    # Load metadata from package directory
    metadata_dir = pkgdir(PowerDynData, "metadata")
    registry = PowerDynData.load_metadata_registry(metadata_dir)

    # Validate registry has models
    if isempty(registry.models)
        error("No models found in metadata directory: $metadata_dir")
    end

    # Create output directory
    mkpath(output_dir)

    # Group models by display category
    category_map = Dict{String, Vector{PowerDynData.ModelMetadata}}()
    for model in values(registry.models)
        display_cat = get_display_category(model.category)
        if !haskey(category_map, display_cat)
            category_map[display_cat] = PowerDynData.ModelMetadata[]
        end
        push!(category_map[display_cat], model)
    end

    # Generate overview page
    overview_content = generate_overview_page(registry, category_map)
    write(joinpath(output_dir, "index.md"), overview_content)
    println("Generated: models/index.md ($(length(registry.models)) models)")

    # Generate category pages
    generated_pages = String[]
    for display_cat in sort(collect(keys(category_map)))
        models = category_map[display_cat]
        content = generate_category_page(display_cat, models)
        filename = category_to_filename(display_cat)
        filepath = joinpath(output_dir, filename)
        write(filepath, content)
        println("Generated: models/$filename ($(length(models)) models)")
        push!(generated_pages, filename)
    end

    return generated_pages
end

# Run if called directly
if abspath(PROGRAM_FILE) == @__FILE__
    output_dir = joinpath(@__DIR__, "src", "models")
    generate_model_docs(output_dir)
end
