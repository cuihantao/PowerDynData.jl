# Exciters

Excitation system models that control generator field voltage and reactive power output.

## Models

[AC8B](#ac8b) | [ESAC1A](#esac1a) | [ESDC1A](#esdc1a) | [ESDC2A](#esdc2a) | [ESST1A](#esst1a) | [ESST3A](#esst3a) | [ESST4B](#esst4b) | [EXAC1](#exac1) | [EXAC2](#exac2) | [EXAC4](#exac4) | [EXDC2](#exdc2) | [EXST1](#exst1) | [IEEET1](#ieeet1) | [IEEET3](#ieeet3) | [IEEEX1](#ieeex1) | [SEXS](#sexs)

---

## AC8B

**AC8B exciter model with PID controller**

- **PSS/E Version**: 33
- **Input Lines**: 3
- **Parameters**: 23

### Parameters

| Name | Type | Unit | Description | Default | Range |
|------|------|------|-------------|---------|-------|
| BUS | Int | - | Bus number where generator is connected | - | - |
| ID | String | - | Generator identifier (1-2 characters) | "1" | - |
| TR | Float64 | seconds | Sensing time constant | 0.01 | - |
| kP | Float64 | pu | PID proportional coefficient | 10.0 | [10.0, 500.0] |
| kI | Float64 | pu | PID integrative coefficient | 10.0 | [10.0, 500.0] |
| kD | Float64 | pu | PID derivative coefficient | 10.0 | [10.0, 500.0] |
| Td | Float64 | seconds | PID derivative time constant | 0.2 | [0.0, 0.5] |
| VPMAX | Float64 | pu | PID maximum limit | 999.0 | - |
| VPMIN | Float64 | pu | PID minimum limit | -999.0 | - |
| VRMAX | Float64 | pu | Maximum regulator limit | 7.3 | [1.0, 10.0] |
| VRMIN | Float64 | pu | Minimum regulator limit | 1.0 | [-1.0, 1.5] |
| VFEMAX | Float64 | pu | Exciter field current limit | 999.0 | - |
| VEMIN | Float64 | pu | Minimum exciter voltage output | -999.0 | - |
| TA | Float64 | seconds | Lag time constant in anti-windup lag | 0.04 | - |
| KA | Float64 | pu | Gain in anti-windup lag | 40.0 | - |
| TE | Float64 | seconds | Exciter integrator time constant | 0.8 | - |
| KC | Float64 | pu | Rectifier loading factor proportional to commutating reactance | 0.1 | [0.0, 1.0] |
| KD | Float64 | pu | Ifd feedback gain | 0.0 | [0.0, 1.0] |
| KE | Float64 | pu | Gain added to saturation | 1.0 | - |
| E1 | Float64 | pu | First saturation point | 0.0 | - |
| SE1 | Float64 | pu | Value at first saturation point | 0.0 | - |
| E2 | Float64 | pu | Second saturation point | 1.0 | - |
| SE2 | Float64 | pu | Value at second saturation point | 1.0 | - |


---

## ESAC1A

**AC exciter with controlled rectifier**

- **PSS/E Version**: 33
- **Input Lines**: 3
- **Parameters**: 21

### Parameters

| Name | Type | Unit | Description | Default | Range |
|------|------|------|-------------|---------|-------|
| BUS | Int | - | Bus number | - | - |
| ID | String | - | Generator ID | "1" | - |
| TR | Float64 | seconds | Sensing time constant | 0.01 | - |
| TB | Float64 | seconds | Lag time constant in lead-lag | 1.0 | - |
| TC | Float64 | seconds | Lead time constant in lead-lag | 1.0 | - |
| VAMAX | Float64 | pu | Maximum amplifier output | 999.0 | - |
| VAMIN | Float64 | pu | Minimum amplifier output | -999.0 | - |
| KA | Float64 | pu | Regulator gain | 80.0 | - |
| TA | Float64 | seconds | Regulator time constant | 0.04 | - |
| VRMAX | Float64 | pu | Maximum regulator output | 8.0 | - |
| VRMIN | Float64 | pu | Minimum regulator output | 0.0 | - |
| TE | Float64 | seconds | Exciter time constant | 0.8 | - |
| E1 | Float64 | pu | First saturation point | 0.0 | - |
| SE1 | Float64 | pu | Saturation at E1 | 0.0 | - |
| E2 | Float64 | pu | Second saturation point | 1.0 | - |
| SE2 | Float64 | pu | Saturation at E2 | 1.0 | - |
| KC | Float64 | pu | Rectifier loading factor | 0.1 | - |
| KD | Float64 | pu | Demagnetizing factor | 0.0 | - |
| KE | Float64 | pu | Exciter constant | 1.0 | - |
| KF | Float64 | pu | Feedback gain | 0.1 | - |
| TF | Float64 | seconds | Feedback time constant | 1.0 | - |


---

## ESDC1A

**DC exciter model 1A**

- **PSS/E Version**: 33
- **Input Lines**: 3
- **Parameters**: 18

### Parameters

| Name | Type | Unit | Description | Default | Range |
|------|------|------|-------------|---------|-------|
| BUS | Int | - | Bus number | - | - |
| ID | String | - | Generator ID | "1" | - |
| TR | Float64 | seconds | Sensing time constant | 0.01 | - |
| KA | Float64 | pu | Regulator gain | 80.0 | - |
| TA | Float64 | seconds | Regulator time constant | 0.04 | - |
| TB | Float64 | seconds | Lag time constant | 1.0 | - |
| TC | Float64 | seconds | Lead time constant | 1.0 | - |
| VRMAX | Float64 | pu | Maximum regulator output | 8.0 | - |
| VRMIN | Float64 | pu | Minimum regulator output | -8.0 | - |
| KE | Float64 | pu | Exciter constant | 1.0 | - |
| TE | Float64 | seconds | Exciter time constant | 0.8 | - |
| KF | Float64 | pu | Feedback gain | 0.1 | - |
| TF1 | Float64 | seconds | Feedback time constant | 1.0 | - |
| Switch | Float64 | - | Switch parameter | 0.0 | - |
| E1 | Float64 | pu | First saturation point | 0.0 | - |
| SE1 | Float64 | pu | Saturation at E1 | 0.0 | - |
| E2 | Float64 | pu | Second saturation point | 1.0 | - |
| SE2 | Float64 | pu | Saturation at E2 | 1.0 | - |


---

## ESDC2A

**DC exciter model 2A**

- **PSS/E Version**: 33
- **Input Lines**: 3
- **Parameters**: 18

### Parameters

| Name | Type | Unit | Description | Default | Range |
|------|------|------|-------------|---------|-------|
| BUS | Int | - | Bus number | - | - |
| ID | String | - | Generator ID | "1" | - |
| TR | Float64 | seconds | Sensing time constant | 0.01 | - |
| KA | Float64 | pu | Regulator gain | 80.0 | - |
| TA | Float64 | seconds | Regulator time constant | 0.04 | - |
| TB | Float64 | seconds | Lag time constant | 1.0 | - |
| TC | Float64 | seconds | Lead time constant | 1.0 | - |
| VRMAX | Float64 | pu | Maximum regulator output | 8.0 | - |
| VRMIN | Float64 | pu | Minimum regulator output | -8.0 | - |
| KE | Float64 | pu | Exciter constant | 1.0 | - |
| TE | Float64 | seconds | Exciter time constant | 0.8 | - |
| KF | Float64 | pu | Feedback gain | 0.1 | - |
| TF1 | Float64 | seconds | Feedback time constant | 1.0 | - |
| Switch | Float64 | - | Switch parameter | 0.0 | - |
| E1 | Float64 | pu | First saturation point | 0.0 | - |
| SE1 | Float64 | pu | Saturation at E1 | 0.0 | - |
| E2 | Float64 | pu | Second saturation point | 1.0 | - |
| SE2 | Float64 | pu | Saturation at E2 | 1.0 | - |


---

## ESST1A

**Static exciter type 1A**

- **PSS/E Version**: 33
- **Input Lines**: 3
- **Parameters**: 22

### Parameters

| Name | Type | Unit | Description | Default | Range |
|------|------|------|-------------|---------|-------|
| BUS | Int | - | Bus number | - | - |
| ID | String | - | Generator ID | "1" | - |
| UEL | Int | - | Alternate UEL input code (1-3) | 1 | - |
| VOS | Int | - | Alternate stabilizer input code (1-2) | 1 | - |
| TR | Float64 | seconds | Sensing time constant | 0.01 | [0.0, ∞] |
| VIMAX | Float64 | pu | Maximum input voltage | 0.8 | [0.0, ∞] |
| VIMIN | Float64 | pu | Minimum input voltage | -0.1 | - |
| TB | Float64 | seconds | Lag time constant in lead-lag | 1.0 | [0.0, ∞] |
| TC | Float64 | seconds | Lead time constant in lead-lag | 1.0 | [0.0, ∞] |
| TB1 | Float64 | seconds | Lag time constant in lead-lag 1 | 1.0 | [0.0, ∞] |
| TC1 | Float64 | seconds | Lead time constant in lead-lag 1 | 1.0 | [0.0, ∞] |
| VAMAX | Float64 | pu | Maximum amplifier output | 999.0 | [0.0, ∞] |
| VAMIN | Float64 | pu | Minimum amplifier output | -999.0 | - |
| KA | Float64 | pu | Regulator gain | 80.0 | [0.0, ∞] |
| TA | Float64 | seconds | Regulator time constant | 0.04 | [0.0, ∞] |
| ILR | Float64 | pu | Exciter output current limiter reference | 1.0 | [0.0, ∞] |
| KLR | Float64 | pu | Exciter output current limiter gain | 1.0 | [0.0, ∞] |
| VRMAX | Float64 | pu | Maximum regulator output | 7.3 | [0.0, ∞] |
| VRMIN | Float64 | pu | Minimum regulator output | -7.3 | - |
| KF | Float64 | pu | Feedback gain | 0.1 | [0.0, ∞] |
| TF | Float64 | seconds | Feedback time constant | 1.0 | [0.0, ∞] |
| KC | Float64 | pu | Rectifier loading factor | 0.1 | [0.0, 1.0] |


---

## ESST3A

**Static exciter type 3A**

- **PSS/E Version**: 33
- **Input Lines**: 3
- **Parameters**: 23

### Parameters

| Name | Type | Unit | Description | Default | Range |
|------|------|------|-------------|---------|-------|
| BUS | Int | - | Bus number | - | - |
| ID | String | - | Generator ID | "1" | - |
| TR | Float64 | seconds | Sensing time constant | 0.01 | [0.0, ∞] |
| VIMAX | Float64 | pu | Maximum input voltage | 0.8 | [0.0, 1.0] |
| VIMIN | Float64 | pu | Minimum input voltage | -0.1 | [-1.0, 0.0] |
| KM | Float64 | pu | Forward gain constant | 500.0 | [0.0, 1000.0] |
| TC | Float64 | seconds | Lead time constant | 3.0 | [0.0, 20.0] |
| TB | Float64 | seconds | Lag time constant | 15.0 | [0.0, 20.0] |
| KA | Float64 | pu | Regulator gain | 50.0 | [0.0, 200.0] |
| TA | Float64 | seconds | Regulator time constant | 0.1 | [0.0, 1.0] |
| VRMAX | Float64 | pu | Maximum regulator output | 8.0 | [0.5, 10.0] |
| VRMIN | Float64 | pu | Minimum regulator output | 0.0 | [-10.0, 0.5] |
| KG | Float64 | pu | Feedback gain of inner field regulator | 1.0 | [0.0, 1.1] |
| KP | Float64 | pu | Potential circuit gain coefficient | 4.0 | [1.0, 10.0] |
| KI | Float64 | pu | Current circuit gain coefficient | 0.1 | [0.0, 1.1] |
| VBMAX | Float64 | pu | Maximum VB limit | 18.0 | [0.0, 20.0] |
| KC | Float64 | pu | Rectifier loading factor | 0.1 | [0.0, 1.0] |
| XL | Float64 | pu | Potential source reactance | 0.01 | [0.0, 0.5] |
| VGMAX | Float64 | pu | Maximum VG limit | 4.0 | [0.0, 20.0] |
| THETAP | Float64 | degrees | Rectifier firing angle | 0.0 | [0.0, 90.0] |
| TM | Float64 | seconds | Inner field regulator time constant | 0.1 | [0.0, ∞] |
| VMMAX | Float64 | pu | Maximum VM limit | 1.0 | [0.5, 1.5] |
| VMMIN | Float64 | pu | Minimum VM limit | 0.1 | [-1.5, 0.5] |


---

## ESST4B

**Static exciter type 4B**

- **PSS/E Version**: 33
- **Input Lines**: 2
- **Parameters**: 20

### Parameters

| Name | Type | Unit | Description | Default | Range |
|------|------|------|-------------|---------|-------|
| BUS | Int | - | Bus number | - | - |
| ID | String | - | Generator ID | "1" | - |
| TR | Float64 | seconds | Sensing time constant | 0.01 | - |
| KPR | Float64 | pu | Proportional gain for outer PI controller | 1.0 | - |
| KIR | Float64 | pu | Integral gain for outer PI controller | 0.0 | - |
| VRMAX | Float64 | pu | Maximum regulator limit | 8.0 | [0.5, 10.0] |
| VRMIN | Float64 | pu | Minimum regulator limit | 0.0 | [-10.0, 0.5] |
| TA | Float64 | seconds | Lag time constant | 0.1 | [0.0, 1.0] |
| KPM | Float64 | pu | Proportional gain for inner PI controller | 1.0 | - |
| KIM | Float64 | pu | Integral gain for inner PI controller | 0.0 | - |
| VMMAX | Float64 | pu | Maximum inner loop limit | 8.0 | [0.5, 10.0] |
| VMMIN | Float64 | pu | Minimum inner loop limit | 0.0 | [-10.0, 0.5] |
| KG | Float64 | pu | Feedback gain of inner field regulator | 1.0 | [0.0, 1.1] |
| KP | Float64 | pu | Potential circuit gain coefficient | 4.0 | [1.0, 10.0] |
| KI | Float64 | pu | Current circuit gain coefficient | 0.1 | [0.0, 1.1] |
| VBMAX | Float64 | pu | Maximum VB limit | 18.0 | [0.0, 20.0] |
| KC | Float64 | pu | Rectifier loading factor | 0.1 | [0.0, 1.0] |
| XL | Float64 | pu | Potential source reactance | 0.01 | [0.0, 0.5] |
| THETAP | Float64 | degrees | Rectifier firing angle | 0.0 | [0.0, 90.0] |
| VGMAX | Float64 | pu | Maximum VG limit | 20.0 | [0.0, 20.0] |


---

## EXAC1

**AC exciter model with controlled rectifier and feedback**

- **PSS/E Version**: 33
- **Input Lines**: 2
- **Parameters**: 19

### Parameters

| Name | Type | Unit | Description | Default | Range |
|------|------|------|-------------|---------|-------|
| BUS | Int | - | Bus number where generator is connected | - | - |
| ID | String | - | Generator identifier (1-2 characters) | "1" | - |
| TR | Float64 | seconds | Sensing time constant | 0.01 | [0.0, ∞] |
| TB | Float64 | seconds | Lag time constant in lead-lag | 1.0 | [0.0, ∞] |
| TC | Float64 | seconds | Lead time constant in lead-lag | 1.0 | [0.0, ∞] |
| KA | Float64 | pu | Regulator gain | 80.0 | [0.0, ∞] |
| TA | Float64 | seconds | Lag time constant in regulator | 0.04 | [0.0, ∞] |
| VRMAX | Float64 | pu | Maximum regulator output | 8.0 | [0.5, 10.0] |
| VRMIN | Float64 | pu | Minimum regulator output | 0.0 | [-10.0, 0.5] |
| TE | Float64 | seconds | Exciter integrator time constant | 0.8 | [0.0, ∞] |
| KF | Float64 | pu | Feedback gain | 0.1 | [0.0, ∞] |
| TF | Float64 | seconds | Feedback time constant | 1.0 | [0.0, ∞] |
| KC | Float64 | pu | Rectifier loading factor proportional to commutating reactance | 0.1 | [0.0, 1.0] |
| KD | Float64 | pu | Demagnetizing factor (Ifd feedback gain) | 0.0 | [0.0, 1.0] |
| KE | Float64 | pu | Saturation feedback gain | 1.0 | [0.0, ∞] |
| E1 | Float64 | pu | First saturation point | 0.0 | [0.0, ∞] |
| SE1 | Float64 | pu | Saturation value at first point | 0.0 | [0.0, ∞] |
| E2 | Float64 | pu | Second saturation point | 1.0 | [0.0, ∞] |
| SE2 | Float64 | pu | Saturation value at second point | 1.0 | [0.0, ∞] |


---

## EXAC2

**Exciter AC2 model**

- **PSS/E Version**: 33
- **Input Lines**: 3
- **Parameters**: 25

### Parameters

| Name | Type | Unit | Description | Default | Range |
|------|------|------|-------------|---------|-------|
| BUS | Int | - | Bus number | - | - |
| ID | String | - | Generator ID | "1" | - |
| TR | Float64 | seconds | Sensing time constant | 0.01 | - |
| TB | Float64 | seconds | Lag time constant | 1.0 | - |
| TC | Float64 | seconds | Lead time constant | 1.0 | - |
| KA | Float64 | pu | Regulator gain | 80.0 | - |
| TA | Float64 | seconds | Regulator time constant | 0.04 | - |
| VAMAX | Float64 | pu | Maximum amplifier output | 999.0 | - |
| VAMIN | Float64 | pu | Minimum amplifier output | -999.0 | - |
| KB | Float64 | pu | Second stage gain | 1.0 | - |
| VRMAX | Float64 | pu | Maximum regulator output | 8.0 | - |
| VRMIN | Float64 | pu | Minimum regulator output | 0.0 | - |
| TE | Float64 | seconds | Exciter time constant | 0.8 | - |
| KL | Float64 | pu | Exciter field current limiter gain | 1.0 | - |
| KH | Float64 | pu | Exciter field current feedback gain | 1.0 | - |
| KF | Float64 | pu | Feedback gain | 0.1 | - |
| TF | Float64 | seconds | Feedback time constant | 1.0 | - |
| KC | Float64 | pu | Rectifier loading factor | 0.1 | - |
| KD | Float64 | pu | Demagnetizing factor | 0.0 | - |
| KE | Float64 | pu | Exciter constant | 1.0 | - |
| VLR | Float64 | pu | Maximum field current limiter reference | 1.0 | - |
| E1 | Float64 | pu | First saturation point | 0.0 | - |
| SE1 | Float64 | pu | Saturation at E1 | 0.0 | - |
| E2 | Float64 | pu | Second saturation point | 1.0 | - |
| SE2 | Float64 | pu | Saturation at E2 | 1.0 | - |


---

## EXAC4

**Exciter AC4 model**

- **PSS/E Version**: 33
- **Input Lines**: 1
- **Parameters**: 12

### Parameters

| Name | Type | Unit | Description | Default | Range |
|------|------|------|-------------|---------|-------|
| BUS | Int | - | Bus number | - | - |
| ID | String | - | Generator ID | "1" | - |
| TR | Float64 | seconds | Sensing time constant | 0.01 | - |
| VIMAX | Float64 | pu | Maximum input voltage | 10.0 | - |
| VIMIN | Float64 | pu | Minimum input voltage | -10.0 | - |
| TC | Float64 | seconds | Lead time constant | 1.0 | - |
| TB | Float64 | seconds | Lag time constant | 1.0 | - |
| KA | Float64 | pu | Regulator gain | 80.0 | - |
| TA | Float64 | seconds | Regulator time constant | 0.04 | - |
| VRMAX | Float64 | pu | Maximum regulator output | 8.0 | - |
| VRMIN | Float64 | pu | Minimum regulator output | 0.0 | - |
| KC | Float64 | pu | Rectifier loading factor | 0.1 | - |


---

## EXDC2

**DC exciter model with speed input**

- **PSS/E Version**: 33
- **Input Lines**: 3
- **Parameters**: 18

### Parameters

| Name | Type | Unit | Description | Default | Range |
|------|------|------|-------------|---------|-------|
| BUS | Int | - | Bus number | - | - |
| ID | String | - | Generator ID | "1" | - |
| TR | Float64 | seconds | Sensing time constant | 0.01 | [0.0, ∞] |
| KA | Float64 | pu | Regulator gain | 40.0 | [0.0, ∞] |
| TA | Float64 | seconds | Regulator time constant | 0.04 | [0.0, ∞] |
| TB | Float64 | seconds | Lag time constant in lead-lag | 1.0 | [0.0, ∞] |
| TC | Float64 | seconds | Lead time constant in lead-lag | 1.0 | [0.0, ∞] |
| VRMAX | Float64 | pu | Maximum regulator output | 7.3 | [0.0, ∞] |
| VRMIN | Float64 | pu | Minimum regulator output | -7.3 | - |
| KE | Float64 | pu | Exciter constant | 1.0 | [0.0, ∞] |
| TE | Float64 | seconds | Exciter time constant | 0.8 | [0.0, ∞] |
| KF1 | Float64 | pu | Feedback gain | 0.03 | [0.0, ∞] |
| TF1 | Float64 | seconds | Feedback time constant | 1.0 | [0.0, ∞] |
| Switch | Float64 | - | Switch parameter | 0.0 | - |
| E1 | Float64 | pu | First saturation point | 0.0 | [0.0, ∞] |
| SE1 | Float64 | pu | Saturation at E1 | 0.0 | [0.0, ∞] |
| E2 | Float64 | pu | Second saturation point | 1.0 | [0.0, ∞] |
| SE2 | Float64 | pu | Saturation at E2 | 1.0 | [0.0, ∞] |


---

## EXST1

**ST1-type static excitation system**

- **PSS/E Version**: 33
- **Input Lines**: 2
- **Parameters**: 14

### Parameters

| Name | Type | Unit | Description | Default | Range |
|------|------|------|-------------|---------|-------|
| BUS | Int | - | Bus number | - | - |
| ID | String | - | Generator ID | "1" | - |
| TR | Float64 | seconds | Measurement delay | 0.01 | [0.0, ∞] |
| VIMAX | Float64 | pu | Maximum input voltage | 0.2 | [0.0, ∞] |
| VIMIN | Float64 | pu | Minimum input voltage | 0.0 | - |
| TC | Float64 | seconds | Lead-lag lead time constant | 1.0 | [0.0, ∞] |
| TB | Float64 | seconds | Lead-lag lag time constant | 1.0 | [0.0, ∞] |
| KA | Float64 | pu | Regulator gain | 80.0 | [0.0, ∞] |
| TA | Float64 | seconds | Regulator time constant | 0.05 | [0.0, ∞] |
| VRMAX | Float64 | pu | Maximum regulator output | 8.0 | [0.0, ∞] |
| VRMIN | Float64 | pu | Minimum regulator output | -3.0 | - |
| KC | Float64 | pu | Rectifier loading factor for Ifd | 0.2 | [0.0, ∞] |
| KF | Float64 | pu | Feedback gain | 0.1 | [0.0, ∞] |
| TF | Float64 | seconds | Feedback time constant | 1.0 | [0.0, ∞] |


---

## IEEET1

**IEEE Type 1 excitation system**

- **PSS/E Version**: 33
- **Input Lines**: 2
- **Parameters**: 16

### Parameters

| Name | Type | Unit | Description | Default | Range |
|------|------|------|-------------|---------|-------|
| BUS | Int | - | Bus number where generator is connected | - | - |
| ID | String | - | Generator identifier (1-2 characters) | "1" | - |
| TR | Float64 | seconds | Sensing time constant | 0.02 | - |
| KA | Float64 | pu | Regulator gain | 5.0 | - |
| TA | Float64 | seconds | Lag time constant in anti-windup lag | 0.04 | - |
| VRMAX | Float64 | pu | Maximum excitation limit | 7.3 | - |
| VRMIN | Float64 | pu | Minimum excitation limit | -7.3 | - |
| KE | Float64 | pu | Gain added to saturation | 1.0 | - |
| TE | Float64 | seconds | Exciter integrator time constant | 0.8 | - |
| KF | Float64 | pu | Feedback gain | 0.1 | - |
| TF | Float64 | seconds | Feedback time constant | 1.0 | [0.0, ∞] |
| Switch | Float64 | - | Switch parameter (unused in PSS/E) | 0.0 | - |
| E1 | Float64 | pu | First saturation point | 0.0 | - |
| SE1 | Float64 | pu | Saturation value at first point | 0.0 | - |
| E2 | Float64 | pu | Second saturation point | 1.0 | - |
| SE2 | Float64 | pu | Saturation value at second point | 1.0 | - |


---

## IEEET3

**IEEE Type 3 excitation system**

- **PSS/E Version**: 33
- **Input Lines**: 2
- **Parameters**: 14

### Parameters

| Name | Type | Unit | Description | Default | Range |
|------|------|------|-------------|---------|-------|
| BUS | Int | - | Bus number | - | - |
| ID | String | - | Generator ID | "1" | - |
| TR | Float64 | seconds | Sensing time constant | 0.02 | - |
| KA | Float64 | pu | Regulator gain | 5.0 | - |
| TA | Float64 | seconds | Regulator time constant | 0.04 | - |
| VRMAX | Float64 | pu | Maximum regulator output | 7.3 | - |
| VRMIN | Float64 | pu | Minimum regulator output | -7.3 | - |
| VBMAX | Float64 | pu | Maximum field voltage | 99.0 | - |
| KE | Float64 | pu | Exciter constant | 1.0 | - |
| TE | Float64 | seconds | Exciter time constant | 0.8 | - |
| KF | Float64 | pu | Feedback gain | 0.1 | - |
| TF | Float64 | seconds | Feedback time constant | 1.0 | - |
| KP | Float64 | pu | Potential circuit gain | 4.37 | - |
| KI | Float64 | pu | Current circuit gain | 0.1 | - |


---

## IEEEX1

**IEEE Type X1 excitation system (same as EXDC2)**

- **PSS/E Version**: 33
- **Input Lines**: 3
- **Parameters**: 18

### Parameters

| Name | Type | Unit | Description | Default | Range |
|------|------|------|-------------|---------|-------|
| BUS | Int | - | Bus number | - | - |
| ID | String | - | Generator ID | "1" | - |
| TR | Float64 | seconds | Sensing time constant | 0.01 | [0.0, ∞] |
| KA | Float64 | pu | Regulator gain | 40.0 | [0.0, ∞] |
| TA | Float64 | seconds | Regulator time constant | 0.04 | [0.0, ∞] |
| TB | Float64 | seconds | Lag time constant in lead-lag | 1.0 | [0.0, ∞] |
| TC | Float64 | seconds | Lead time constant in lead-lag | 1.0 | [0.0, ∞] |
| VRMAX | Float64 | pu | Maximum regulator output | 7.3 | [0.0, ∞] |
| VRMIN | Float64 | pu | Minimum regulator output | -7.3 | - |
| KE | Float64 | pu | Exciter constant | 1.0 | [0.0, ∞] |
| TE | Float64 | seconds | Exciter time constant | 0.8 | [0.0, ∞] |
| KF1 | Float64 | pu | Feedback gain | 0.03 | [0.0, ∞] |
| TF1 | Float64 | seconds | Feedback time constant | 1.0 | [0.0, ∞] |
| Switch | Float64 | - | Switch parameter | 0.0 | - |
| E1 | Float64 | pu | First saturation point | 0.0 | [0.0, ∞] |
| SE1 | Float64 | pu | Saturation at E1 | 0.0 | [0.0, ∞] |
| E2 | Float64 | pu | Second saturation point | 1.0 | [0.0, ∞] |
| SE2 | Float64 | pu | Saturation at E2 | 1.0 | [0.0, ∞] |


---

## SEXS

**Simplified Excitation System**

- **PSS/E Version**: 33
- **Input Lines**: 1
- **Parameters**: 8

### Parameters

| Name | Type | Unit | Description | Default | Range |
|------|------|------|-------------|---------|-------|
| BUS | Int | - | Bus number where generator is connected | - | - |
| ID | String | - | Generator identifier (1-2 characters) | "1" | - |
| TATB | Float64 | - | Time constant TA/TB | 0.4 | [0.05, 1.0] |
| TB | Float64 | seconds | Time constant TB in lead-lag | 5.0 | [5.0, 20.0] |
| K | Float64 | pu | Gain | 20.0 | [20.0, 100.0] |
| TE | Float64 | seconds | Anti-windup lag time constant | 1.0 | [0.0, 0.5] |
| EMIN | Float64 | pu | Lower excitation limit | -99.0 | - |
| EMAX | Float64 | pu | Upper excitation limit | 99.0 | [3.0, 6.0] |


---
