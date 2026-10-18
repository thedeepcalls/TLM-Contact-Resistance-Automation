# TLM Contact Resistance Automation

MATLAB script for automating basic Transfer Length Method (TLM) analysis from CSV measurement data.

I developed this during undergraduate photodetector research in the Advanced Semiconductor Materials and Devices (ASMD) Lab at the University of Texas at Arlington under Dr. Seunghyun Lee.

## Features

- Reads multiple I-V sweeps from a CSV file
- Extracts `V1` and `I1` data
- Plots I-V curves for each contact spacing
- Calculates resistance from the linear region near 0 V
- Plots resistance vs. contact spacing
- Calculates contact resistance using the TLM method
- Calculates R² for the TLM fit
- Gives a basic Ohmic / Schottky-like contact check

## Usage

Open the MATLAB script and set the contact spacings:

```matlab
spacing = [25 50 75 100 125];
```

Then run the script and select the TLM CSV file.

The script currently expects five sweeps and was written for the 4155C CSV format used in the lab.

## Calculation

Resistance is calculated using a linear fit of the I-V data between ±0.5 V:

```text
I = mV + b
R = 1 / |m|
```

The TLM fit uses:

```text
R_total = 2Rc + (Rsh / W)L
```

so the contact resistance is:

```text
Rc = intercept / 2
```

## Output

The script generates:

- I-V curves for each contact spacing
- Resistance vs. contact spacing plot
- TLM linear fit
- R² value
- Contact resistance per contact
- Basic Ohmic / Schottky-like behavior estimate

Example Command Window output:

```text
Resistance Results
25 um   = ...
50 um   = ...
75 um   = ...
100 um  = ...
125 um  = ...

TLM Fit
R = ...
TLM R^2 = ...

Contact Resistance
Rc = ... ohms/contact

Contact Behavior
Likely Ohmic
```

## Notes

The current version assumes:

- Five contact spacings
- `V1` contains voltage
- `I1` contains current
- Voltage is in volts
- Current is in amperes
- The 4155C stores the sweeps in reverse order

The Ohmic / Schottky-like result is only a basic indicator based on I-V linearity.

## Author

Aarush Singh  
Electrical Engineering — University of Texas at Arlington  
ASMD Lab
