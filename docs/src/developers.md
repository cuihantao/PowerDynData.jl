# For Developers

## Adding New Models

1. Create a YAML file in the appropriate category folder:
   ```
   metadata/<category>/<MODEL_NAME>.yaml
   ```

2. Follow this structure:
   ```yaml
   model:
     name: MODEL_NAME
     description: "Brief description"
     category: generator  # or exciter, governor, etc.
     version: 33

   parsing:
     model_name_field: 2
     multi_line: false
     line_count: 1
     terminator: "/"
     flexible_fields: false

   fields:
     - name: BUS
       position: 1
       type: Int
       description: "Bus number"
       unit: dimensionless
       required: true

     - name: H
       position: 4
       type: Float64
       description: "Inertia constant"
       unit: "MW·s/MVA"
       required: true
       default: 0.0
       range: [0.0, Inf]
   ```

3. The documentation rebuilds automatically on CI — no code changes needed.

## Adding New Categories

1. Create a new directory under `metadata/`:
   ```
   metadata/new_category/
   ```

2. Add model YAML files to it.

3. (Optional) Add display name mapping in `docs/generate_models.jl`:
   ```julia
   "new_category" => "New Category",
   ```

   If not mapped, the category name is auto-converted to title case.

## Documentation Build

```bash
# Local build
julia --project=docs -e 'using Pkg; Pkg.instantiate()'
julia --project=docs docs/make.jl

# Preview
open docs/build/index.html
```

## Field Metadata Reference

| Field | Type | Description |
|-------|------|-------------|
| `name` | String | Parameter name (e.g., `H`, `Xd`) |
| `position` | Int | 1-indexed position in DYR record |
| `type` | String | `Int`, `Float64`, `String`, or `Bool` |
| `description` | String | Human-readable description |
| `unit` | String | Physical unit or `dimensionless` |
| `required` | Bool | Whether field is mandatory |
| `default` | Any | Default value if not provided |
| `range` | List | `[min, max]` bounds (use `Inf` for unbounded) |
