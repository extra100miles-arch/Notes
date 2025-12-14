# AXI4-Lite Write Transaction – Conceptual Understanding

## 1. Purpose of This Document
This document explains **how an AXI4-Lite write transaction occurs** at a protocol and architectural level.

The focus is on:
- Channel behavior
- Handshake rules
- Ordering constraints
- Timing expectations
- FSM-based interpretation used in real designs

This document avoids RTL or SystemVerilog implementation details.

References are based on:
- ARM® AMBA® AXI and ACE Protocol Specification
- Xilinx® AXI Reference Guide (UG761)
- Intel® FPGA AXI4-Lite Interface Documentation

---

## 2. AXI4-Lite Channel Overview (Write Path)

AXI4-Lite uses **independent unidirectional channels**.  
A write transaction uses **three channels**:

### 2.1 Write Address Channel (AW)
Carries the address and control information for the write.

Signals:
- `AWADDR`  – Write address
- `AWVALID` – Address valid
- `AWREADY` – Slave ready to accept address

---

### 2.2 Write Data Channel (W)
Carries the data to be written.

Signals:
- `WDATA`   – Write data
- `WSTRB`   – Byte lane strobes
- `WVALID`  – Data valid
- `WREADY`  – Slave ready to accept data

---

### 2.3 Write Response Channel (B)
Used by the slave to indicate write completion.

Signals:
- `BRESP`   – Write response (OKAY / SLVERR)
- `BVALID`  – Response valid
- `BREADY`  – Master ready to accept response

---

## 3. VALID / READY Handshake Rules

All AXI4-Lite channels follow the same handshake rule:

- A transfer completes **only when `VALID` and `READY` are high on a rising clock edge**
- `VALID` is asserted by the sender
- `READY` is asserted by the receiver
- Once `VALID` is asserted, it **must remain high until handshake occurs**
- Payload signals must remain **stable while `VALID=1` and `READY=0`**

This rule applies identically to AW, W, and B channels.

---

## 4. Ordering Rules in AXI4-Lite

AXI4-Lite enforces strict ordering to simplify designs:

- No bursts
- No transaction IDs
- One outstanding transaction per channel

Rules:
1. The slave must not issue a write response until **both address and data are accepted**
2. Write responses are returned in the same order as write requests
3. Only one write response is outstanding at a time

These constraints make AXI4-Lite deterministic and bridge-friendly.

---

## 5. Write Transaction Timing (Conceptual Flow)

A typical write transaction proceeds as follows:

1. Master asserts `AWVALID` with a valid address
2. Master asserts `WVALID` with valid data
3. Address accepted when `AWVALID & AWREADY`
4. Data accepted when `WVALID & WREADY`
5. Slave performs the write internally
6. Slave asserts `BVALID` with `BRESP`
7. Master asserts `BREADY`
8. Transaction completes

Address and data acceptance **may occur in different cycles**.

---

## 6. When VALID Can Be Asserted

- `AWVALID`: when a valid write address is available
- `WVALID`: when valid write data is available (independent of AW)
- `BVALID`: only after both address and data have been accepted

---

## 7. When READY Can Be Asserted

- `AWREADY`: when the slave can accept a write address
- `WREADY`: when the slave can accept write data
- `BREADY`: when the master can accept a response (often tied high)

READY may be asserted **before or after VALID**.

---

## 8. Stability Requirements

Once `VALID` is asserted:

- `AWADDR` must remain stable until `AWREADY`
- `WDATA` and `WSTRB` must remain stable until `WREADY`
- `BRESP` must remain stable until `BREADY`

This guarantees correctness under backpressure.

---

## 9. FSM Interpretation (Architectural View)

Although AXI does not mandate an FSM, **real implementations always use one**.

A typical AXI4-Lite write FSM includes the following states:

### IDLE
- No active write transaction
- Waiting for a valid write request from the master

### WAIT_FOR_ADDRESS
- `AWVALID` observed
- Waiting for `AWREADY` handshake

### WAIT_FOR_DATA
- `WVALID` observed
- Waiting for `WREADY` handshake

### WRITE_ACCEPTED
- Both address and data have been accepted
- Internal write operation is triggered (or forwarded to another bus)

### SEND_RESPONSE
- Slave asserts `BVALID`
- Waiting for `BREADY` from the master

### COMPLETE
- Write response accepted
- FSM returns to IDLE

Key insight:
> Each FSM state corresponds to waiting for a VALID/READY handshake to complete.

This approach is directly derived from the AXI protocol rules.

---

## 10. Key Architectural Insight

AXI4-Lite does not describe a step-by-step transaction sequence.

Instead, it defines:
- Independent channels
- Handshake constraints
- Ordering guarantees

Design behavior is derived by identifying **what conditions must be met before progressing**, not by following a scripted flow.

---

## 11. Summary

- AXI4-Lite write uses AW, W, and B channels
- Each channel uses VALID/READY handshaking
- Address and data are independent
- Write response occurs only after both are accepted
- FSM-based control naturally follows from protocol rules

This understanding is sufficient to design, debug, or review AXI4-Lite write interfaces and bridges.
