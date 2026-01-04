# Voltage Compensators

Voltage compensation models for generator reactive power control.

## Models

[IEEEVC](#ieeevc)

---

## IEEEVC

**IEEE Voltage Compensator**

- **PSS/E Version**: 33
- **Input Lines**: 1
- **Parameters**: 4

### Parameters

| Name | Type | Unit | Description | Default | Range |
|------|------|------|-------------|---------|-------|
| BUS | Int | - | Bus number | - | - |
| ID | String | - | Exciter ID | "1" | - |
| rc | Float64 | pu | Active compensation degree | 0.0 | - |
| xc | Float64 | pu | Reactive compensation degree | 0.0 | - |


---
