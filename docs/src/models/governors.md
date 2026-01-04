# Governors

Governor and prime mover models that control mechanical power input to generators.

## Models

[GAST](#gast) | [HYGOV](#hygov) | [IEEEG1](#ieeeg1) | [IEESGO](#ieesgo) | [TGOV1](#tgov1)

---

## GAST

**Gas turbine governor model**

- **PSS/E Version**: 33
- **Input Lines**: 1
- **Parameters**: 11

### Parameters

| Name | Type | Unit | Description | Default | Range |
|------|------|------|-------------|---------|-------|
| BUS | Int | - | Bus number where generator is connected | - | - |
| ID | String | - | Generator identifier | "1" | - |
| R | Float64 | pu | Speed regulation gain (permanent droop) | 0.05 | [0.0, ∞] |
| T1 | Float64 | seconds | Governor lag time constant | 0.4 | [0.0, ∞] |
| T2 | Float64 | seconds | Governor lead time constant | 0.1 | [0.0, ∞] |
| T3 | Float64 | seconds | Valve positioner time constant | 3.0 | [0.0, ∞] |
| AT | Float64 | pu | Ambient temperature load limit | 1.0 | [0.0, ∞] |
| KT | Float64 | pu | Temperature limiter gain | 2.0 | [0.0, ∞] |
| VMAX | Float64 | pu | Maximum valve position | 1.2 | [0.0, ∞] |
| VMIN | Float64 | pu | Minimum valve position | 0.0 | - |
| Dt | Float64 | pu | Turbine damping coefficient | 0.0 | [0.0, ∞] |


---

## HYGOV

**Hydro turbine governor model**

- **PSS/E Version**: 33
- **Input Lines**: 2
- **Parameters**: 14

### Parameters

| Name | Type | Unit | Description | Default | Range |
|------|------|------|-------------|---------|-------|
| BUS | Int | - | Bus number | - | - |
| ID | String | - | Generator ID | "1" | - |
| R | Float64 | pu | Permanent droop | 0.05 | [0.0, ∞] |
| r | Float64 | pu | Temporary droop | 0.3 | [0.0, ∞] |
| Tr | Float64 | seconds | Dashpot time constant | 5.0 | [0.0, ∞] |
| Tf | Float64 | seconds | Filter time constant | 0.05 | [0.0, ∞] |
| Tg | Float64 | seconds | Gate servo time constant | 0.5 | [0.0, ∞] |
| VELM | Float64 | pu/s | Maximum gate opening velocity | 0.2 | [0.0, ∞] |
| GMAX | Float64 | pu | Maximum gate opening | 1.0 | [0.0, ∞] |
| GMIN | Float64 | pu | Minimum gate opening | 0.0 | - |
| Tw | Float64 | seconds | Water starting time | 1.0 | [0.0, ∞] |
| At | Float64 | pu | Turbine gain | 1.2 | [0.0, ∞] |
| Dturb | Float64 | pu | Turbine damping coefficient | 0.5 | [0.0, ∞] |
| qNL | Float64 | pu | No-load turbine flow | 0.08 | [0.0, ∞] |


---

## IEEEG1

**IEEE Type 1 Speed-Governing Model**

- **PSS/E Version**: 33
- **Input Lines**: 3
- **Parameters**: 22

### Parameters

| Name | Type | Unit | Description | Default | Range |
|------|------|------|-------------|---------|-------|
| BUS | Int | - | Bus number | - | - |
| ID | String | - | Generator ID | "1" | - |
| K | Float64 | pu | Gain (1/R) in machine base | 20.0 | [5.0, 30.0] |
| T1 | Float64 | seconds | Governor lag time constant | 1.0 | [0.0, 5.0] |
| T2 | Float64 | seconds | Governor lead time constant | 1.0 | [0.0, 10.0] |
| T3 | Float64 | seconds | Valve controller time constant | 0.1 | [0.04, 1.0] |
| UO | Float64 | pu/sec | Maximum valve opening rate | 0.1 | [0.01, 0.3] |
| UC | Float64 | pu/sec | Maximum valve closing rate | -0.1 | [-0.3, 0.0] |
| PMAX | Float64 | pu | Maximum turbine power | 5.0 | [0.5, 2.0] |
| PMIN | Float64 | pu | Minimum turbine power | 0.0 | [0.0, 0.5] |
| T4 | Float64 | seconds | Inlet piping/steam bowl time constant | 0.4 | [0.0, 1.0] |
| K1 | Float64 | pu | Fraction of power from HP turbine | 0.5 | [0.0, 1.0] |
| K2 | Float64 | pu | Fraction of power from LP turbine | 0.0 | [0.0, ∞] |
| T5 | Float64 | seconds | Time constant of 2nd boiler pass | 8.0 | [0.0, 10.0] |
| K3 | Float64 | pu | Fraction of HP shaft power after 2nd boiler pass | 0.5 | [0.0, 0.5] |
| K4 | Float64 | pu | Fraction of LP shaft power after 2nd boiler pass | 0.0 | [0.0, ∞] |
| T6 | Float64 | seconds | Time constant of 3rd boiler pass | 0.5 | [0.0, 10.0] |
| K5 | Float64 | pu | Fraction of HP shaft power after 3rd boiler pass | 0.0 | [0.0, 0.35] |
| K6 | Float64 | pu | Fraction of LP shaft power after 3rd boiler pass | 0.0 | [0.0, 0.55] |
| T7 | Float64 | seconds | Time constant of 4th boiler pass | 0.05 | [0.0, 10.0] |
| K7 | Float64 | pu | Fraction of HP shaft power after 4th boiler pass | 0.0 | [0.0, 0.3] |
| K8 | Float64 | pu | Fraction of LP shaft power after 4th boiler pass | 0.0 | [0.0, 0.3] |


---

## IEESGO

**IEEE Standard Governor**

- **PSS/E Version**: 33
- **Input Lines**: 2
- **Parameters**: 13

### Parameters

| Name | Type | Unit | Description | Default | Range |
|------|------|------|-------------|---------|-------|
| BUS | Int | - | Bus number | - | - |
| ID | String | - | Generator ID | "1" | - |
| T1 | Float64 | seconds | Controller lag time constant | 0.02 | [0.0, 100.0] |
| T2 | Float64 | seconds | Lead compensation time constant | 1.0 | [0.0, 10.0] |
| T3 | Float64 | seconds | Governor lag time constant | 1.0 | [0.04, 1.0] |
| T4 | Float64 | seconds | Steam inlet delay | 0.5 | [0.0, 1.0] |
| T5 | Float64 | seconds | Reheater delay | 10.0 | [0.0, 50.0] |
| T6 | Float64 | seconds | Crossover delay | 0.5 | [0.0, 1.0] |
| K1 | Float64 | pu | 1/pu regulation (inverse droop) | 0.02 | [5.0, 30.0] |
| K2 | Float64 | pu | Fraction K2 | 1.0 | [0.0, 3.0] |
| K3 | Float64 | pu | Fraction K3 | 1.0 | [-1.0, 1.0] |
| PMAX | Float64 | pu | Maximum turbine power | 5.0 | [0.5, 1.5] |
| PMIN | Float64 | pu | Minimum turbine power | 0.0 | [0.0, 0.5] |


---

## TGOV1

**Steam turbine governor model**

- **PSS/E Version**: 33
- **Input Lines**: 1
- **Parameters**: 9

### Parameters

| Name | Type | Unit | Description | Default | Range |
|------|------|------|-------------|---------|-------|
| BUS | Int | - | Bus number | - | - |
| ID | String | - | Generator identifier | "1" | - |
| R | Float64 | pu | Permanent droop | - | [0.0, ∞] |
| Dt | Float64 | pu | Turbine damping coefficient | - | [0.0, ∞] |
| Vmax | Float64 | pu | Maximum valve position | - | [0.0, ∞] |
| Vmin | Float64 | pu | Minimum valve position | - | - |
| T1 | Float64 | seconds | Governor time constant | - | [0.0, ∞] |
| T2 | Float64 | seconds | Turbine time constant | - | [0.0, ∞] |
| T3 | Float64 | seconds | Valve positioner time constant | - | [0.0, ∞] |


---
