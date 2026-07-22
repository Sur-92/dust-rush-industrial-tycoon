# Verified engineering layer

## Purpose

Dust Rush keeps the primary game fast and readable, but a player may open **Show the math** to understand why a route behaves the way it does. This layer teaches the shape of real local-exhaust-ventilation work: source airflow, duct velocity, diameter changes, pressure losses, the critical path, and fan performance.

The engineering layer is educational game content, not design software. It must never present a fictional scenario as a code-compliant installation, substitute for a qualified engineer, or imply that one airflow value applies to every machine of a type.

## Source policy

Every engineering value must be classified as one of:

- **Scenario input** — a requirement supplied by the fictional customer or machine OEM;
- **Derived value** — calculated from displayed inputs with a documented formula;
- **Reference value** — a coefficient or design criterion tied to a named authoritative source;
- **Gameplay simplification** — an intentional approximation, visibly labeled and excluded from real-world claims.

Prefer current primary sources in this order:

1. applicable law, OSHA material, and other government technical publications;
2. NIOSH research and engineering-control publications;
3. current consensus standards such as ACGIH industrial ventilation guidance and NFPA 660;
4. the exact machine manufacturer's current manual or data sheet;
5. a reviewed gameplay assumption when no suitable public value exists.

Record the source URL and access date with any reference value added to the repository. Never copy a commercial table wholesale. If sources disagree or depend on conditions the game does not model, expose the uncertainty instead of manufacturing precision.

## What CFM means

CFM is volumetric airflow, not a score created by the route.

- The required CFM at a machine is a design input based on its hood, process, dust, operating condition, and manufacturer or engineering guidance.
- The airflow carried by a main duct is the sum of the active branch airflows joining it in the simplified first-customer model.
- Measured or calculated airflow is:

```text
Q = V × A

Q = airflow, cubic feet per minute (CFM)
V = average duct velocity, feet per minute (FPM)
A = internal duct area, square feet
```

- For a round duct:

```text
A = π × D² ÷ 4

D = internal diameter in feet
```

- The collector does not deliver its free-air rating everywhere. Actual airflow depends on the system resistance and the fan curve at the operating point.

These relationships are described in the [NIOSH industrial-hygiene measurement material](https://stacks.cdc.gov/view/cdc/214722/cdc_214722_DS1.pdf), the [OSHA Technical Manual ventilation chapter](https://www.osha.gov/otm/section-3-health-hazards/chapter-3), and the [EPA industrial-ventilation inspection manual](https://nepis.epa.gov/Exe/ZyPURL.cgi?Dockey=94005VFE.txt).

## Why ducts step up and down

As branches merge on the way to the collector, airflow increases. The main duct normally steps up in diameter so velocity remains suitable for conveying the material without creating avoidable pressure loss. Looking from the collector back toward individual machines, the same fittings appear as step-downs.

A larger diameter at unchanged CFM lowers velocity. A smaller diameter raises velocity and velocity pressure, but usually increases system resistance and energy demand. A diameter is therefore not automatically "better" because it is larger or smaller.

The first-customer model should show each transition as a sentence and a calculation:

```text
400 CFM branch + 600 CFM branch = 1,000 CFM in the main
7-inch main area = 0.267 ft²
1,000 ÷ 0.267 = about 3,742 FPM
Step 5 inches → 7 inches: airflow increased at this junction
```

Minimum transport velocity depends on the particulate, loading, air density, duct orientation, and other conditions. OSHA defines it as the minimum velocity that transports particles with little settling; it is not one universal number for every dust.

## Pressure-loss ledger

For standard air near sea level, velocity pressure may be shown as:

```text
VP = (V ÷ 4005)²

VP = velocity pressure, inches water gauge
V = duct velocity, FPM
```

Fitting and hood losses use a source-backed coefficient:

```text
fitting loss = K × VP
```

Straight-duct loss uses a reviewed friction rate for the displayed airflow, diameter, material, and duct condition:

```text
straight loss = friction rate × length ÷ 100
```

The route receipt totals the hood entry, straight duct, elbows, wyes, transitions, air cleaner, and other modeled components along each path. The highest-resistance active path is the **critical path**. The fan/collector must be evaluated at the required system airflow and static pressure, not only by a headline CFM number.

OSHA describes hood-entry loss, static pressure, friction loss, transport velocity, and the need to know both air volume and fan static pressure. The EPA inspection manual documents the velocity-pressure method and fitting-loss factors. Exact coefficients must live in sourced data rather than UI code.

## Cabinet-shop scenario inputs

The first customer uses fictional machines with model-specific scenario requirements informed by representative current manufacturer data. These are not universal requirements for every table saw, planer, or sander.

| Machine | Scenario airflow | Pickup | Public design basis |
| --- | ---: | --- | --- |
| Table Saw | 400 CFM | one 4-inch pickup | SawStop specifies at least 400 CFM at the 4-inch port for a representative industrial cabinet saw. |
| Planer | 600 CFM | one 5-inch pickup | Grizzly specifies at least 600 CFM through a 5-inch port for representative 20-inch planers. |
| Wide-Belt Sander | 800 CFM | two 4-inch pickups | Stiles lists 800 CFM through dual 4-inch outlets for a representative single-head Ironwood wide-belt sander. |

Sources:

- [SawStop Industrial Cabinet Saw manual](https://www.sawstop.com/wp-content/uploads/2026/04/Industrial-Cabinet-Saw-Owners-Manual.pdf), accessed 2026-07-22
- [Grizzly G0454Z/G0454ZX planer guidance](https://support.grizzly.com/hc/en-us/articles/35556746739095-FAQ-G0454Z-G0454ZX-20-Planers), accessed 2026-07-22
- [Stiles Ironwood S114K data sheet](https://stilesmachinery.com/wp-content/uploads/2022/09/MSS_S114K.pdf), accessed 2026-07-22

The resulting simplified active airflow is 1,800 CFM. The wide-belt sander's two 400 CFM pickups merge into its branch before the shop main. Duct sizes, fitting geometry, friction rates, and collector fan curves must be approved in a coding ticket before they become game data.

## Player-facing engineering receipt

The normal route card remains concise. **Show the math** opens a compact, optional receipt with:

1. **Design basis** — machine airflow and its source classification;
2. **Flow math** — CFM added at each junction;
3. **Duct steps** — before/after diameter, area, and velocity;
4. **Loss ledger** — straight duct and each fitting's pressure loss;
5. **Critical path** — the branch that sets required static pressure;
6. **Collector check** — expected fan operating point and remaining margin;
7. **Plain-language consequence** — settling risk, excess restriction, energy cost, or expansion room.

The receipt explains the decision; it does not turn the main screen into a spreadsheet. A new player can ignore it, while an engineer or salesperson can audit where the conclusion came from.

## Safety boundary

Wood dust can create health, fire, and deflagration hazards. Hood design, combustible-dust analysis, explosion protection, collector location, discharge, make-up air, and code compliance are outside the proof-of-concept calculation. Real systems require the applicable authority having jurisdiction and qualified professionals.

Relevant starting references include:

- [NIOSH table-saw wood-dust control research](https://stacks.cdc.gov/view/cdc/209709/cdc_209709_DS1.pdf)
- [NIOSH horizontal-belt-sander wood-dust control research](https://stacks.cdc.gov/view/cdc/209707/cdc_209707_DS1.pdf)
- [OSHA ventilation requirements and design tables](https://www.osha.gov/laws-regs/regulations/standardnumber/1910/1910.94)
- [NFPA 660, Standard for Combustible Dusts and Particulate Solids](https://link.nfpa.org/all-publications/660/2025)

## Implementation guardrails

- Keep formulas in deterministic typed GDScript, not scene labels.
- Keep scenario inputs and coefficients in typed resources with source metadata.
- Test units, junction sums, diameter/area conversions, velocity pressure, loss totals, and critical-path selection.
- Round only for display; calculations retain full precision.
- Never mix inches and feet implicitly.
- Do not call an estimate "verified" merely because the formula is correct; its inputs and coefficients must also have provenance.
- Any future change to a formula, source, or safety statement requires review against the current authoritative publication.
