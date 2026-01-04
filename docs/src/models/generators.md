# Generators

Synchronous machine models representing rotating generators in power systems.

## Models

[GENCLS](#gencls) | [GENQEC](#genqec) | [GENROU](#genrou) | [GENSAL](#gensal) | [GENTPJ1](#gentpj1)

---

## GENCLS

**Classical generator model (constant voltage behind transient reactance)**

- **PSS/E Version**: 33
- **Input Lines**: 1
- **Parameters**: 4

### Parameters

| Name | Type | Unit | Description | Default | Range |
|------|------|------|-------------|---------|-------|
| BUS | Int | - | Bus number where generator is connected | - | - |
| ID | String | - | Generator identifier (1-2 characters) | "1" | - |
| H | Float64 | MW·s/MVA | Inertia constant (stored as M = 2H internally) | - | [0.0, ∞] |
| D | Float64 | pu | Damping coefficient | 0.0 | [0.0, ∞] |


---

## GENQEC

**PSLF GENQEC Generator Model**

- **PSS/E Version**: 33
- **Input Lines**: 3
- **Parameters**: 22

### Parameters

| Name | Type | Unit | Description | Default | Range |
|------|------|------|-------------|---------|-------|
| BUS | Int | - | Bus number where generator is connected | - | - |
| ID | String | - | Generator identifier (1-2 characters) | "1" | - |
| Td10 | Float64 | seconds | d-axis transient open-circuit time constant | - | [0.0, ∞] |
| Td20 | Float64 | seconds | d-axis subtransient open-circuit time constant | - | [0.0, ∞] |
| Tq10 | Float64 | seconds | q-axis transient open-circuit time constant | - | [0.0, ∞] |
| Tq20 | Float64 | seconds | q-axis subtransient open-circuit time constant | - | [0.0, ∞] |
| H | Float64 | MW·s/MVA | Inertia constant | - | [0.0, ∞] |
| D | Float64 | pu | Damping coefficient | - | [0.0, ∞] |
| Xd | Float64 | pu | d-axis synchronous reactance | - | [0.0, ∞] |
| Xq | Float64 | pu | q-axis synchronous reactance | - | [0.0, ∞] |
| Xd1 | Float64 | pu | d-axis transient reactance | - | [0.0, ∞] |
| Xq1 | Float64 | pu | q-axis transient reactance | - | [0.0, ∞] |
| Xd2 | Float64 | pu | d-axis subtransient reactance | - | [0.0, ∞] |
| Xq2 | Float64 | pu | q-axis subtransient reactance | - | [0.0, ∞] |
| Xl | Float64 | pu | Stator leakage reactance | - | [0.0, ∞] |
| S10 | Float64 | - | Saturation factor at 1.0 pu flux | - | [0.0, ∞] |
| S12 | Float64 | - | Saturation factor at 1.2 pu flux | - | [0.0, ∞] |
| Ra | Float64 | pu | Stator resistance | - | [0.0, ∞] |
| Rcomp | Float64 | pu | Compounding resistance for voltage control | - | [0.0, ∞] |
| Xcomp | Float64 | pu | Compounding reactance for voltage control | - | [0.0, ∞] |
| Kw | Float64 | - | Rotor field current compensation factor | - | [0.0, 1.0] |
| Satflg | Int | - | Saturation type selector | - | [-1.0, ∞] |


---

## GENROU

**Round rotor generator model**

- **PSS/E Version**: 33
- **Input Lines**: 3
- **Parameters**: 16

### Parameters

| Name | Type | Unit | Description | Default | Range |
|------|------|------|-------------|---------|-------|
| BUS | Int | - | Bus number where generator is connected | - | - |
| ID | String | - | Generator identifier (1-2 characters) | "1" | - |
| Td10 | Float64 | seconds | d-axis transient open-circuit time constant | - | [0.0, ∞] |
| Td20 | Float64 | seconds | d-axis subtransient open-circuit time constant | - | [0.0, ∞] |
| Tq10 | Float64 | seconds | q-axis transient open-circuit time constant | - | [0.0, ∞] |
| Tq20 | Float64 | seconds | q-axis subtransient open-circuit time constant | - | [0.0, ∞] |
| H | Float64 | MW·s/MVA | Inertia constant | - | [0.0, ∞] |
| D | Float64 | pu | Damping coefficient | - | [0.0, ∞] |
| Xd | Float64 | pu | d-axis synchronous reactance | - | [0.0, ∞] |
| Xq | Float64 | pu | q-axis synchronous reactance | - | [0.0, ∞] |
| Xd1 | Float64 | pu | d-axis transient reactance | - | [0.0, ∞] |
| Xq1 | Float64 | pu | q-axis transient reactance | - | [0.0, ∞] |
| Xd2 | Float64 | pu | d-axis subtransient reactance | - | [0.0, ∞] |
| Xl | Float64 | pu | Leakage reactance | - | [0.0, ∞] |
| S10 | Float64 | - | Saturation factor at 1.0 pu flux | - | [0.0, ∞] |
| S12 | Float64 | - | Saturation factor at 1.2 pu flux | - | [0.0, ∞] |


---

## GENSAL

**Salient Pole Generator Model (Quadratic Saturation on d-Axis)**

- **PSS/E Version**: 33
- **Input Lines**: 3
- **Parameters**: 14

### Parameters

| Name | Type | Unit | Description | Default | Range |
|------|------|------|-------------|---------|-------|
| BUS | Int | - | Bus number where generator is connected | - | - |
| ID | String | - | Generator identifier (1-2 characters) | "1" | - |
| Td10 | Float64 | seconds | d-axis transient open-circuit time constant | - | [0.0, ∞] |
| Td20 | Float64 | seconds | d-axis subtransient open-circuit time constant | - | [0.0, ∞] |
| Tq20 | Float64 | seconds | q-axis subtransient open-circuit time constant | - | [0.0, ∞] |
| H | Float64 | MW·s/MVA | Inertia constant | - | [0.0, ∞] |
| D | Float64 | pu | Speed damping | - | [0.0, ∞] |
| Xd | Float64 | pu | d-axis synchronous reactance | - | [0.0, ∞] |
| Xq | Float64 | pu | q-axis synchronous reactance | - | [0.0, ∞] |
| Xd1 | Float64 | pu | d-axis transient reactance | - | [0.0, ∞] |
| Xd2 | Float64 | pu | d-axis subtransient reactance | - | [0.0, ∞] |
| Xl | Float64 | pu | Leakage reactance | - | [0.0, ∞] |
| S10 | Float64 | - | Saturation factor at 1.0 pu flux | - | [0.0, ∞] |
| S12 | Float64 | - | Saturation factor at 1.2 pu flux | - | [0.0, ∞] |


---

## GENTPJ1

**Round rotor generator model with quadratic saturation and subtransient q-axis reactance**

- **PSS/E Version**: 33
- **Input Lines**: 3
- **Parameters**: 18

### Parameters

| Name | Type | Unit | Description | Default | Range |
|------|------|------|-------------|---------|-------|
| BUS | Int | - | Bus number where generator is connected | - | - |
| ID | String | - | Generator identifier (1-2 characters) | "1" | - |
| Td10 | Float64 | seconds | d-axis transient open-circuit time constant | - | [0.0, ∞] |
| Td20 | Float64 | seconds | d-axis subtransient open-circuit time constant | - | [0.0, ∞] |
| Tq10 | Float64 | seconds | q-axis transient open-circuit time constant | - | [0.0, ∞] |
| Tq20 | Float64 | seconds | q-axis subtransient open-circuit time constant | - | [0.0, ∞] |
| H | Float64 | MW·s/MVA | Inertia constant | - | [0.0, ∞] |
| D | Float64 | pu | Damping coefficient | - | [0.0, ∞] |
| Xd | Float64 | pu | d-axis synchronous reactance | - | [0.0, ∞] |
| Xq | Float64 | pu | q-axis synchronous reactance | - | [0.0, ∞] |
| Xd1 | Float64 | pu | d-axis transient reactance | - | [0.0, ∞] |
| Xq1 | Float64 | pu | q-axis transient reactance | - | [0.0, ∞] |
| Xd2 | Float64 | pu | d-axis subtransient reactance | - | [0.0, ∞] |
| Xq2 | Float64 | pu | q-axis subtransient reactance | - | [0.0, ∞] |
| Xl | Float64 | pu | Leakage reactance | - | [0.0, ∞] |
| S10 | Float64 | - | Saturation factor at 1.0 pu flux | - | [0.0, ∞] |
| S12 | Float64 | - | Saturation factor at 1.2 pu flux | - | [0.0, ∞] |
| Kis | Float64 | - | Current multiplier for saturation calculation | - | [0.0, 1.0] |


---
