# Stabilizers

Power system stabilizer models that provide supplementary damping control.

## Models

[IEEEST](#ieeest) | [ST2CUT](#st2cut)

---

## IEEEST

**IEEE Standard Power System Stabilizer**

- **PSS/E Version**: 33
- **Input Lines**: 2
- **Parameters**: 20

### Parameters

| Name | Type | Unit | Description | Default | Range |
|------|------|------|-------------|---------|-------|
| BUS | Int | - | Bus number | - | - |
| ID | String | - | Generator ID | "1" | - |
| MODE | Int | - | Input signal mode (1-6) | - | - |
| A1 | Float64 | seconds | Filter time constant (pole) | 1.0 | - |
| A2 | Float64 | seconds | Filter time constant (pole) | 1.0 | - |
| A3 | Float64 | seconds | Filter time constant (pole) | 1.0 | - |
| A4 | Float64 | seconds | Filter time constant (pole) | 1.0 | - |
| A5 | Float64 | seconds | Filter time constant (zero) | 1.0 | - |
| A6 | Float64 | seconds | Filter time constant (zero) | 1.0 | - |
| T1 | Float64 | seconds | First leadlag time constant (zero) | 1.0 | [0.0, 10.0] |
| T2 | Float64 | seconds | First leadlag time constant (pole) | 1.0 | [0.0, 10.0] |
| T3 | Float64 | seconds | Second leadlag time constant (pole) | 1.0 | [0.0, 10.0] |
| T4 | Float64 | seconds | Second leadlag time constant (pole) | 1.0 | [0.0, 10.0] |
| T5 | Float64 | seconds | Washout time constant (zero) | 1.0 | [0.0, 10.0] |
| T6 | Float64 | seconds | Washout time constant (pole) | 1.0 | [0.04, 2.0] |
| KS | Float64 | pu | Gain before washout | 1.0 | - |
| LSMAX | Float64 | pu | Maximum output limit | 0.3 | [0.0, 0.3] |
| LSMIN | Float64 | pu | Minimum output limit | -0.3 | [-0.3, 0.0] |
| VCU | Float64 | pu | Upper enabling bus voltage | 999.0 | [1.0, 1.2] |
| VCL | Float64 | pu | Lower enabling bus voltage | -999.0 | [0.0, 1.0] |


---

## ST2CUT

**Dual-input Power System Stabilizer**

- **PSS/E Version**: 33
- **Input Lines**: 2
- **Parameters**: 20

### Parameters

| Name | Type | Unit | Description | Default | Range |
|------|------|------|-------------|---------|-------|
| BUS | Int | - | Bus number | - | - |
| ID | String | - | Generator ID | "1" | - |
| MODE | Int | - | Input signal 1 mode (0-6) | - | - |
| MODE2 | Int | - | Input signal 2 mode (0-6) | 0 | - |
| K1 | Float64 | pu | Transducer 1 gain | 1.0 | [0.0, 10.0] |
| K2 | Float64 | pu | Transducer 2 gain | 1.0 | [0.0, 10.0] |
| T1 | Float64 | seconds | Transducer 1 time constant | 1.0 | [0.0, 10.0] |
| T2 | Float64 | seconds | Transducer 2 time constant | 1.0 | [0.0, 10.0] |
| T3 | Float64 | seconds | Washout integrator time constant | 1.0 | [0.0, 10.0] |
| T4 | Float64 | seconds | Washout delay time constant | 0.2 | [0.05, 10.0] |
| T5 | Float64 | seconds | Leadlag 1 time constant (zero) | 1.0 | [0.0, 10.0] |
| T6 | Float64 | seconds | Leadlag 1 time constant (pole) | 0.5 | [0.0, 2.0] |
| T7 | Float64 | seconds | Leadlag 2 time constant (zero) | 1.0 | [0.0, 10.0] |
| T8 | Float64 | seconds | Leadlag 2 time constant (pole) | 1.0 | [0.0, 10.0] |
| T9 | Float64 | seconds | Leadlag 3 time constant (zero) | 1.0 | [0.0, 2.0] |
| T10 | Float64 | seconds | Leadlag 3 time constant (pole) | 0.2 | [0.0, 2.0] |
| LSMAX | Float64 | pu | Maximum output limit | 0.3 | [0.0, 0.3] |
| LSMIN | Float64 | pu | Minimum output limit | -0.3 | [-0.3, 0.0] |
| VCU | Float64 | pu | Upper enabling bus voltage | 999.0 | [1.0, 1.2] |
| VCL | Float64 | pu | Lower enabling bus voltage | -999.0 | [-0.1, 1.0] |


---
