# Renewable Governor

## Models

[WTDTA1](#wtdta1)

---

## WTDTA1

**Wind turbine drive-train model**

- **PSS/E Version**: 33
- **Input Lines**: 1
- **Parameters**: 8

### Parameters

| Name | Type | Unit | Description | Default | Range |
|------|------|------|-------------|---------|-------|
| BUS | Int | - | Bus number | - | - |
| ID | String | - | Renewable exciter ID | "1" | - |
| H | Float64 | MWs/MVA | Total inertia constant | 3.0 | - |
| DAMP | Float64 | pu | Damping coefficient | 0.0 | - |
| Htfrac | Float64 | pu | Turbine inertia fraction (Hturb/H) | 0.5 | [0.0, 1.0] |
| Freq1 | Float64 | pu | First shaft torsional resonant frequency | 1.0 | - |
| Dshaft | Float64 | pu | Shaft damping factor | 1.0 | - |
| w0 | Float64 | pu | Default speed if not using torque model | 1.0 | - |


---
