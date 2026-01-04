# Renewable Energy

Renewable energy source models including wind turbine and solar PV components.

## Models

[REECA1](#reeca1) | [REGCA1](#regca1) | [REPCA1](#repca1) | [WTARA1](#wtara1) | [WTDTA1](#wtdta1) | [WTPTA1](#wtpta1) | [WTTQA1](#wttqa1)

---

## REECA1

**Renewable energy electrical control model**

- **PSS/E Version**: 33
- **Input Lines**: 5
- **Parameters**: 53

### Parameters

| Name | Type | Unit | Description | Default | Range |
|------|------|------|-------------|---------|-------|
| BUS | Int | - | Bus number | - | - |
| ID | String | - | Renewable generator ID | "1" | - |
| VREG | Int | - | Bus number for voltage control; local control if 0 | 0 | - |
| PFFLAG | Int | - | Power factor control flag (1-PF control, 0-Q control) | - | - |
| VFLAG | Int | - | Voltage control flag (1-Q control, 0-V control) | - | - |
| QFLAG | Int | - | Q control flag (1-V or Q control, 0-const PF or Q) | - | - |
| PFLAG | Int | - | P speed-dependency flag (1-has speed dep, 0-no dep) | - | - |
| PQFLAG | Int | - | P/Q priority flag for I limit (0-Q priority, 1-P priority) | - | - |
| Vdip | Float64 | pu | Low V threshold to activate Iqinj logic | 0.8 | - |
| Vup | Float64 | pu | V threshold above which to activate Iqinj logic | 1.2 | - |
| Trv | Float64 | seconds | Voltage filter time constant | 0.02 | - |
| dbd1 | Float64 | pu | Lower bound of voltage deadband | -0.02 | - |
| dbd2 | Float64 | pu | Upper bound of voltage deadband | 0.02 | - |
| Kqv | Float64 | pu | Gain to compute Iqinj from V error | 1.0 | [0.0, 10.0] |
| Iqh1 | Float64 | pu | Upper limit on Iqinj | 999.0 | - |
| Iql1 | Float64 | pu | Lower limit on Iqinj | -999.0 | - |
| Vref0 | Float64 | pu | User defined Vref (if 0, use initial bus V) | 1.0 | - |
| Iqfrz | Float64 | pu | Hold Iqinj value for Thld seconds following Vdip | 0.0 | - |
| Thld | Float64 | seconds | Time for which Iqinj is held | 0.0 | - |
| Thld2 | Float64 | seconds | Time for which IPMAX is held after voltage dip ends | 0.0 | - |
| Tp | Float64 | seconds | Filter time constant for Pe | 0.02 | - |
| QMax | Float64 | pu | Upper limit for reactive power regulator | 999.0 | - |
| QMin | Float64 | pu | Lower limit for reactive power regulator | -999.0 | - |
| VMAX | Float64 | pu | Upper limit for voltage control | 999.0 | - |
| VMIN | Float64 | pu | Lower limit for voltage control | -999.0 | - |
| Kqp | Float64 | pu | Proportional gain for reactive power error | 1.0 | - |
| Kqi | Float64 | pu | Integral gain for reactive power error | 0.1 | - |
| Kvp | Float64 | pu | Proportional gain for voltage error | 1.0 | - |
| Kvi | Float64 | pu | Integral gain for voltage error | 0.1 | - |
| Vref1 | Float64 | pu | Voltage reference if VFLAG=0 | 1.0 | - |
| Tiq | Float64 | seconds | Filter time constant for Iq | 0.02 | - |
| dPmax | Float64 | pu/s | Power reference maximum ramp rate | 999.0 | - |
| dPmin | Float64 | pu/s | Power reference minimum ramp rate | -999.0 | - |
| PMAX | Float64 | pu | Maximum active power limit | 999.0 | - |
| PMIN | Float64 | pu | Minimum active power limit | 0.0 | - |
| Imax | Float64 | pu | Maximum apparent current limit | 999.0 | - |
| Tpord | Float64 | seconds | Filter time constant for power setpoint | 0.02 | - |
| Vq1 | Float64 | pu | Reactive power V-I pair voltage (point 1) | 0.2 | - |
| Iq1 | Float64 | pu | Reactive power V-I pair current (point 1) | 2.0 | - |
| Vq2 | Float64 | pu | Reactive power V-I pair voltage (point 2) | 0.4 | - |
| Iq2 | Float64 | pu | Reactive power V-I pair current (point 2) | 4.0 | - |
| Vq3 | Float64 | pu | Reactive power V-I pair voltage (point 3) | 0.8 | - |
| Iq3 | Float64 | pu | Reactive power V-I pair current (point 3) | 8.0 | - |
| Vq4 | Float64 | pu | Reactive power V-I pair voltage (point 4) | 1.0 | - |
| Iq4 | Float64 | pu | Reactive power V-I pair current (point 4) | 10.0 | - |
| Vp1 | Float64 | pu | Active power V-I pair voltage (point 1) | 0.2 | - |
| Ip1 | Float64 | pu | Active power V-I pair current (point 1) | 2.0 | - |
| Vp2 | Float64 | pu | Active power V-I pair voltage (point 2) | 0.4 | - |
| Ip2 | Float64 | pu | Active power V-I pair current (point 2) | 4.0 | - |
| Vp3 | Float64 | pu | Active power V-I pair voltage (point 3) | 0.8 | - |
| Ip3 | Float64 | pu | Active power V-I pair current (point 3) | 8.0 | - |
| Vp4 | Float64 | pu | Active power V-I pair voltage (point 4) | 1.0 | - |
| Ip4 | Float64 | pu | Active power V-I pair current (point 4) | 12.0 | - |


---

## REGCA1

**Renewable energy generator (converter) model A**

- **PSS/E Version**: 33
- **Input Lines**: nothing
- **Parameters**: 17

### Parameters

| Name | Type | Unit | Description | Default | Range |
|------|------|------|-------------|---------|-------|
| BUS | Int | - | Bus number (interface bus) | - | - |
| ID | String | - | Static generator ID | "1" | - |
| Lvplsw | Float64 | - | Low voltage P logic switch (1-enable, 0-disable) | 1.0 | - |
| Tg | Float64 | seconds | Converter time constant | 0.1 | - |
| Rrpwr | Float64 | pu/s | Low voltage power logic (LVPL) ramp rate limit | 10.0 | - |
| Brkpt | Float64 | pu | LVPL characteristic voltage 2 (breakpoint) | 1.0 | - |
| Zerox | Float64 | pu | LVPL characteristic voltage 1 (zero crossing) | 0.5 | - |
| Lvpl1 | Float64 | pu | LVPL gain at Brkpt | 1.0 | - |
| Volim | Float64 | pu | Voltage limit for high voltage reactive current management | 1.2 | - |
| Lvpnt1 | Float64 | pu | High voltage point for low voltage active current management | 0.8 | - |
| Lvpnt0 | Float64 | pu | Low voltage point for low voltage active current management | 0.4 | - |
| Iolim | Float64 | pu | Lower current limit for high voltage reactive current management | -1.5 | - |
| Tfltr | Float64 | seconds | Voltage filter time constant for low voltage active current management | 0.1 | - |
| Khv | Float64 | pu | Overvoltage compensation gain in high voltage reactive current management | 0.7 | - |
| Iqrmax | Float64 | pu/s | Upper limit on the rate of change for reactive current | 1.0 | - |
| Iqrmin | Float64 | pu/s | Lower limit on the rate of change for reactive current | -1.0 | - |
| Accel | Float64 | pu | Acceleration factor | 0.0 | [0.0, 1.0] |


---

## REPCA1

**Renewable Energy Plant Control model**

- **PSS/E Version**: 33
- **Input Lines**: 3
- **Parameters**: 33

### Parameters

| Name | Type | Unit | Description | Default | Range |
|------|------|------|-------------|---------|-------|
| BUS | Int | - | Bus number | - | - |
| ID | String | - | RenExciter ID | "1" | - |
| VCFlag | Int | - | Droop flag (0-droop with PF ctrl, 1-line drop comp) | - | - |
| RefFlag | Int | - | Q/V select flag (0-Q control, 1-V control) | - | - |
| Fflag | Int | - | Frequency control flag (0-disable, 1-enable) | - | - |
| PLflag | Int | - | Pline control flag (0-disable, 1-enable) | 1 | - |
| Tfltr | Float64 | seconds | V or Q filter time constant | 0.02 | - |
| Kp | Float64 | pu | Q proportional gain | 1.0 | - |
| Ki | Float64 | pu | Q integral gain | 0.1 | - |
| Tft | Float64 | seconds | Lead time constant | 1.0 | - |
| Tfv | Float64 | seconds | Lag time constant | 1.0 | - |
| Vfrz | Float64 | pu | Voltage below which s2 is frozen | 0.8 | - |
| Rc | Float64 | pu | Line drop compensation R | 0.0 | - |
| Xc | Float64 | pu | Line drop compensation X | 0.0 | - |
| Kc | Float64 | pu | Reactive power compensation gain | 0.0 | - |
| emax | Float64 | pu | Upper limit on deadband output | 999.0 | - |
| emin | Float64 | pu | Lower limit on deadband output | -999.0 | - |
| dbd1 | Float64 | pu | Lower threshold for reactive power control deadband | -0.1 | - |
| dbd2 | Float64 | pu | Upper threshold for reactive power control deadband | 0.1 | - |
| Qmax | Float64 | pu | Upper limit on output of V-Q control | 999.0 | - |
| Qmin | Float64 | pu | Lower limit on output of V-Q control | -999.0 | - |
| Kpg | Float64 | pu | Proportional gain for power control | 1.0 | - |
| Kig | Float64 | pu | Integral gain for power control | 0.1 | - |
| Tp | Float64 | seconds | Time constant for P measurement | 0.02 | - |
| fdbd1 | Float64 | pu | Lower threshold for frequency error deadband | -0.0002833 | - |
| fdbd2 | Float64 | pu | Upper threshold for frequency error deadband | 0.0002833 | - |
| femax | Float64 | pu | Upper limit for frequency error | 0.05 | - |
| femin | Float64 | pu | Lower limit for frequency error | -0.05 | - |
| Pmax | Float64 | pu | Upper limit on power error | 999.0 | - |
| Pmin | Float64 | pu | Lower limit on power error | -999.0 | - |
| Tg | Float64 | seconds | Power controller lag time constant | 0.02 | - |
| Ddn | Float64 | pu | Reciprocal of droop for over-frequency conditions | 10.0 | - |
| Dup | Float64 | pu | Reciprocal of droop for under-frequency conditions | 10.0 | - |


---

## WTARA1

**Wind turbine aerodynamics model**

- **PSS/E Version**: 33
- **Input Lines**: 1
- **Parameters**: 4

### Parameters

| Name | Type | Unit | Description | Default | Range |
|------|------|------|-------------|---------|-------|
| BUS | Int | - | Bus number | - | - |
| ID | String | - | Renewable governor ID | "1" | - |
| Ka | Float64 | pu/deg | Aerodynamics gain | 1.0 | - |
| theta0 | Float64 | degrees | Initial pitch angle | 0.0 | - |


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

## WTPTA1

**Wind turbine pitch control model**

- **PSS/E Version**: 33
- **Input Lines**: 2
- **Parameters**: 12

### Parameters

| Name | Type | Unit | Description | Default | Range |
|------|------|------|-------------|---------|-------|
| BUS | Int | - | Bus number | - | - |
| ID | String | - | Renewable aerodynamics model ID | "1" | - |
| Kiw | Float64 | pu | Pitch-control integral gain | 0.1 | - |
| Kpw | Float64 | pu | Pitch-control proportional gain | 0.0 | - |
| Kic | Float64 | pu | Pitch-compensation integral gain | 0.1 | - |
| Kpc | Float64 | pu | Pitch-compensation proportional gain | 0.0 | - |
| Kcc | Float64 | pu | Gain for power difference | 0.0 | - |
| Tp | Float64 | seconds | Blade response time constant | 0.3 | - |
| thmax | Float64 | degrees | Maximum pitch angle | 30.0 | [27.0, 30.0] |
| thmin | Float64 | degrees | Minimum pitch angle | 0.0 | - |
| dthmax | Float64 | degrees/s | Maximum pitch angle rate | 5.0 | [5.0, 10.0] |
| dthmin | Float64 | degrees/s | Minimum pitch angle rate | -5.0 | [-10.0, -5.0] |


---

## WTTQA1

**Wind turbine generator torque (Pref) model**

- **PSS/E Version**: 33
- **Input Lines**: 2
- **Parameters**: 18

### Parameters

| Name | Type | Unit | Description | Default | Range |
|------|------|------|-------------|---------|-------|
| BUS | Int | - | Bus number | - | - |
| ID | String | - | Renewable pitch controller ID | "1" | - |
| Tflag | Int | - | Tflag (1-power error, 0-speed error) | - | - |
| Kip | Float64 | pu | Pref-control integral gain | 0.1 | - |
| Kpp | Float64 | pu | Pref-control proportional gain | 0.0 | - |
| Tp | Float64 | seconds | Pe sensing time constant | 0.05 | - |
| Twref | Float64 | seconds | Speed reference time constant | 30.0 | [30.0, 60.0] |
| Temax | Float64 | pu | Maximum electric torque | 1.2 | [1.1, 1.2] |
| Temin | Float64 | pu | Minimum electric torque | 0.0 | - |
| p1 | Float64 | pu | Active power point 1 | 0.2 | - |
| sp1 | Float64 | pu | Speed at power point 1 | 0.58 | - |
| p2 | Float64 | pu | Active power point 2 | 0.4 | - |
| sp2 | Float64 | pu | Speed at power point 2 | 0.72 | - |
| p3 | Float64 | pu | Active power point 3 | 0.6 | - |
| sp3 | Float64 | pu | Speed at power point 3 | 0.86 | - |
| p4 | Float64 | pu | Active power point 4 | 0.8 | - |
| sp4 | Float64 | pu | Speed at power point 4 | 1.0 | - |
| Tn | Float64 | MVA | Turbine rating | 0.0 | - |


---
