# Model Library

PowerDynData.jl supports 36 dynamic models across 6 categories.

## Categories

| Category | Models | Count |
|----------|--------|-------|
| [Generators](generators.md) | GENCLS, GENQEC, GENROU, GENSAL, GENTPJ1 | 5 |
| [Exciters](exciters.md) | AC8B, ESAC1A, ESDC1A, ESDC2A, ESST1A, ESST3A, ESST4B, EXAC1, EXAC2, EXAC4, EXDC2, EXST1, IEEET1, IEEET3, IEEEX1, SEXS | 16 |
| [Governors](governors.md) | GAST, HYGOV, IEEEG1, IEESGO, TGOV1 | 5 |
| [Stabilizers](stabilizers.md) | IEEEST, ST2CUT | 2 |
| [Voltage Compensators](voltage_compensators.md) | IEEEVC | 1 |
| [Renewable Energy](renewable_energy.md) | REECA1, REGCA1, REPCA1, WTARA1, WTDTA1, WTPTA1, WTTQA1 | 7 |

## All Models

| Model | Category | Description |
|-------|----------|-------------|
| [AC8B](exciters.md#ac8b) | Exciters | AC8B exciter model with PID controller |
| [ESAC1A](exciters.md#esac1a) | Exciters | AC exciter with controlled rectifier |
| [ESDC1A](exciters.md#esdc1a) | Exciters | DC exciter model 1A |
| [ESDC2A](exciters.md#esdc2a) | Exciters | DC exciter model 2A |
| [ESST1A](exciters.md#esst1a) | Exciters | Static exciter type 1A |
| [ESST3A](exciters.md#esst3a) | Exciters | Static exciter type 3A |
| [ESST4B](exciters.md#esst4b) | Exciters | Static exciter type 4B |
| [EXAC1](exciters.md#exac1) | Exciters | AC exciter model with controlled rectifier and feedback |
| [EXAC2](exciters.md#exac2) | Exciters | Exciter AC2 model |
| [EXAC4](exciters.md#exac4) | Exciters | Exciter AC4 model |
| [EXDC2](exciters.md#exdc2) | Exciters | DC exciter model with speed input |
| [EXST1](exciters.md#exst1) | Exciters | ST1-type static excitation system |
| [GAST](governors.md#gast) | Governors | Gas turbine governor model |
| [GENCLS](generators.md#gencls) | Generators | Classical generator model (constant voltage behind transient reactance) |
| [GENQEC](generators.md#genqec) | Generators | PSLF GENQEC Generator Model |
| [GENROU](generators.md#genrou) | Generators | Round rotor generator model |
| [GENSAL](generators.md#gensal) | Generators | Salient Pole Generator Model (Quadratic Saturation on d-Axis) |
| [GENTPJ1](generators.md#gentpj1) | Generators | Round rotor generator model with quadratic saturation and subtransient q-axis reactance |
| [HYGOV](governors.md#hygov) | Governors | Hydro turbine governor model |
| [IEEEG1](governors.md#ieeeg1) | Governors | IEEE Type 1 Speed-Governing Model |
| [IEEEST](stabilizers.md#ieeest) | Stabilizers | IEEE Standard Power System Stabilizer |
| [IEEET1](exciters.md#ieeet1) | Exciters | IEEE Type 1 excitation system |
| [IEEET3](exciters.md#ieeet3) | Exciters | IEEE Type 3 excitation system |
| [IEEEVC](voltage_compensators.md#ieeevc) | Voltage Compensators | IEEE Voltage Compensator |
| [IEEEX1](exciters.md#ieeex1) | Exciters | IEEE Type X1 excitation system (same as EXDC2) |
| [IEESGO](governors.md#ieesgo) | Governors | IEEE Standard Governor |
| [REECA1](renewable_energy.md#reeca1) | Renewable Energy | Renewable energy electrical control model |
| [REGCA1](renewable_energy.md#regca1) | Renewable Energy | Renewable energy generator (converter) model A |
| [REPCA1](renewable_energy.md#repca1) | Renewable Energy | Renewable Energy Plant Control model |
| [SEXS](exciters.md#sexs) | Exciters | Simplified Excitation System |
| [ST2CUT](stabilizers.md#st2cut) | Stabilizers | Dual-input Power System Stabilizer |
| [TGOV1](governors.md#tgov1) | Governors | Steam turbine governor model |
| [WTARA1](renewable_energy.md#wtara1) | Renewable Energy | Wind turbine aerodynamics model |
| [WTDTA1](renewable_energy.md#wtdta1) | Renewable Energy | Wind turbine drive-train model |
| [WTPTA1](renewable_energy.md#wtpta1) | Renewable Energy | Wind turbine pitch control model |
| [WTTQA1](renewable_energy.md#wttqa1) | Renewable Energy | Wind turbine generator torque (Pref) model |
