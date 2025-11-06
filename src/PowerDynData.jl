module PowerDynData

using Parsers
using InlineStrings
using Tables
using YAML
using StructArrays
using DocStringExtensions
using PrecompileTools

# Export main API
export parse_dyr, DynamicData, DynamicRecords
export NamedDynamicRecords, IndexedDynamicRecords
export load_metadata_registry, MetadataRegistry
export ValidationIssue

# Include source files
include("debug.jl")
include("metadata.jl")  # Include metadata first (defines MetadataRegistry)
include("types.jl")     # types.jl references MetadataRegistry
include("parsing.jl")
include("precompile.jl")

end
