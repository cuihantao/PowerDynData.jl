module PowerDynData

using Parsers
using InlineStrings
using Tables
using YAML
using TOML
using StructArrays
using DocStringExtensions
using PrecompileTools

# Export main API
export parse_dyr, parse_toml, DynamicData, DynamicRecords
export NamedDynamicRecords, IndexedDynamicRecords
export load_metadata_registry, MetadataRegistry
export ValidationIssue
export dyr_to_toml

# Include source files
include("debug.jl")
include("metadata.jl")  # Include metadata first (defines MetadataRegistry)
include("types.jl")     # types.jl references MetadataRegistry
include("record_creation.jl")  # Shared record creation logic (before parsers)
include("parsing.jl")
include("toml_parsing.jl")
include("converter.jl")
include("precompile.jl")

end
