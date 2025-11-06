# Metadata system for YAML-driven parsing

"""
    $TYPEDEF

Metadata for a single field in a model.

# Fields
$TYPEDFIELDS
"""
struct FieldMetadata
    "Field name"
    name::Symbol
    "Position in DYR record (1-indexed)"
    position::Int
    "Julia type for this field"
    type::Type
    "Human-readable description"
    description::String
    "Physical unit (e.g., 'seconds', 'MW', 'dimensionless')"
    unit::String
    "Whether this field is required"
    required::Bool
    "Default value if not provided"
    default::Union{Nothing, Any}
    "Valid range for numeric fields"
    range::Union{Nothing, Tuple{Float64, Float64}}
end

"""
    $TYPEDEF

Complete metadata for a PSS/E dynamic model.

# Fields
$TYPEDFIELDS
"""
struct ModelMetadata
    "Model name (e.g., 'GENROU')"
    name::String
    "Description of the model"
    description::String
    "Category (e.g., 'generator', 'exciter', 'governor')"
    category::String
    "Position of model name field in DYR record"
    model_name_field::Int
    "Whether record spans multiple lines"
    multi_line::Bool
    "Number of lines (if multi_line)"
    line_count::Union{Nothing, Int}
    "Record terminator character"
    terminator::String
    "Allow variable number of fields"
    flexible_fields::Bool
    "Field metadata for all fields in order"
    fields::Vector{FieldMetadata}
end

"""
    $TYPEDEF

Registry of all loaded model metadata.

# Fields
$TYPEDFIELDS
"""
struct MetadataRegistry
    "Dictionary mapping model name to metadata"
    models::Dict{String, ModelMetadata}
    "Dictionary mapping category to list of model names"
    categories::Dict{String, Vector{String}}
end

"""
    load_metadata_registry(metadata_dir::String) -> MetadataRegistry

Load all YAML metadata files from a directory tree.

Recursively scans `metadata_dir` for .yaml/.yml files and parses them
into ModelMetadata objects. Organizes models by category.

# Arguments
- `metadata_dir`: Path to directory containing YAML metadata files

# Returns
- `MetadataRegistry`: Registry containing all loaded metadata

# Examples
```julia
registry = load_metadata_registry("metadata")
genrou_meta = get_model_metadata(registry, "GENROU")
```
"""
function load_metadata_registry(metadata_dir::String)::MetadataRegistry
    models = Dict{String, ModelMetadata}()
    categories = Dict{String, Vector{String}}()

    @pdebug 1 "Loading metadata from: $metadata_dir"

    # Recursively find all YAML files
    for (root, dirs, files) in walkdir(metadata_dir)
        for file in files
            if endswith(file, ".yaml") || endswith(file, ".yml")
                filepath = joinpath(root, file)
                @pdebug 2 "Parsing metadata file: $filepath"

                try
                    metadata = parse_metadata_file(filepath)
                    models[metadata.name] = metadata

                    # Track by category
                    if !haskey(categories, metadata.category)
                        categories[metadata.category] = String[]
                    end
                    push!(categories[metadata.category], metadata.name)

                    @pdebug 1 "Loaded metadata for model: $(metadata.name)"
                catch e
                    @warn "Failed to parse metadata file: $filepath" exception=e
                end
            end
        end
    end

    @pdebug 1 "Loaded $(length(models)) model schemas in $(length(categories)) categories"

    return MetadataRegistry(models, categories)
end

"""
    parse_metadata_file(filepath::String) -> ModelMetadata

Parse a single YAML metadata file into ModelMetadata.
"""
function parse_metadata_file(filepath::String)::ModelMetadata
    yaml_data = YAML.load_file(filepath)

    # Parse model-level info
    model = yaml_data["model"]
    parsing = yaml_data["parsing"]

    # Parse fields
    fields = FieldMetadata[]
    for field_dict in yaml_data["fields"]
        field_meta = FieldMetadata(
            Symbol(field_dict["name"]),
            field_dict["position"],
            string_to_type(field_dict["type"]),
            get(field_dict, "description", ""),
            get(field_dict, "unit", "dimensionless"),
            get(field_dict, "required", true),
            get(field_dict, "default", nothing),
            parse_range(get(field_dict, "range", nothing))
        )
        push!(fields, field_meta)
    end

    return ModelMetadata(
        model["name"],
        get(model, "description", ""),
        get(model, "category", "unknown"),
        get(parsing, "model_name_field", 2),
        get(parsing, "multi_line", false),
        get(parsing, "line_count", nothing),
        get(parsing, "terminator", "/"),
        get(parsing, "flexible_fields", false),
        fields
    )
end

"""
    string_to_type(s::String) -> Type

Convert type string from YAML to Julia Type.
"""
function string_to_type(s::String)::Type
    if s == "Int" || s == "Int64"
        return Int
    elseif s == "Float64" || s == "Float"
        return Float64
    elseif s == "String"
        return String
    elseif s == "Bool"
        return Bool
    else
        error("Unknown type string: $s")
    end
end

"""
    parse_range(r) -> Union{Nothing, Tuple{Float64, Float64}}

Parse range from YAML (can be array or nothing).
"""
function parse_range(r::Nothing)::Nothing
    return nothing
end

function parse_range(r::Vector)::Tuple{Float64, Float64}
    length(r) == 2 || error("Range must have exactly 2 elements")
    # Handle "Inf" strings
    min_val = r[1] == "Inf" ? Inf : r[1] == "-Inf" ? -Inf : Float64(r[1])
    max_val = r[2] == "Inf" ? Inf : r[2] == "-Inf" ? -Inf : Float64(r[2])
    return (min_val, max_val)
end

"""
    get_model_metadata(registry::MetadataRegistry, model_name::String) -> Union{ModelMetadata, Nothing}

Retrieve metadata for a specific model from the registry.

Returns `nothing` if model is not found.
"""
function get_model_metadata(registry::MetadataRegistry, model_name::String)::Union{ModelMetadata, Nothing}
    return get(registry.models, model_name, nothing)
end

"""
    validate_range(value::Number, range::Tuple{Float64, Float64}, field_name::Symbol)

Validate that a numeric value falls within the specified range.

Throws an error if validation fails.
"""
function validate_range(value::Number, range::Tuple{Float64, Float64}, field_name::Symbol)
    min_val, max_val = range
    if value < min_val || value > max_val
        error("Field $field_name value $value outside valid range [$min_val, $max_val]")
    end
end

# Pretty printing
function Base.show(io::IO, registry::MetadataRegistry)
    n_models = length(registry.models)
    n_cats = length(registry.categories)
    print(io, "MetadataRegistry($n_models models, $n_cats categories)")
end

function Base.show(io::IO, ::MIME"text/plain", registry::MetadataRegistry)
    println(io, "MetadataRegistry:")
    println(io, "  Total models: ", length(registry.models))
    println(io, "  Categories:")
    for (cat, models) in sort(collect(registry.categories))
        println(io, "    $cat: ", join(models, ", "))
    end
end
