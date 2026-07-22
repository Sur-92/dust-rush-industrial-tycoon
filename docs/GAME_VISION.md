# Dust Rush: Industrial Tycoon — game vision

## The game in one sentence

Build a dust-collection company as far as you can in ten minutes by making quick, readable engineering and business decisions, then watching each industrial system come alive—or fail—because of what you chose.

## Product promise

Dust Rush should deliver the satisfaction of a classic management game without the homework of a modern simulation. The player should feel competent almost immediately, see the factory react to every decision, and want to restart as soon as the clock reaches zero.

The game is not trying to reproduce dust-collection engineering perfectly. It turns the shape of real industrial work into a clear arcade-management experience:

> See the problem → make a few meaningful decisions → watch the installation → discover the result → improve the company → take the next job.

The first minute is easy to understand. The final minutes force hard tradeoffs. A run always lasts ten minutes.

## Player fantasy

The player owns a small industrial systems company. Customers call with dusty, inefficient, or unsafe plants. The player inspects each shop, chooses an approach, commits time and money, and watches the company fabricate and install the solution automatically.

The player is the decision-maker, not the CAD operator, welder, forklift driver, or bookkeeper. The fun comes from judgment:

- Which job is worth taking?
- Is the inexpensive collector good enough?
- Is a fast duct route too inefficient?
- Should this system leave capacity for expansion?
- Is there time to correct a weak installation?
- Should the company spend its cash now or save for a better opportunity?

The emotional payoff is a factory visibly becoming cleaner and more productive because the player designed a good system.

## Design pillars

### 1. Fun begins immediately

The player reaches a meaningful choice within 30 seconds. There is no long tutorial, empty land purchase, character creator, technology tree, or hour of setup before the first result.

### 2. Depth without cognitive weight

Every visible number should help make a decision. The game may model capacity, restriction, cost, installation time, energy, safety, and future growth, but it should reveal those ideas gradually and summarize them clearly.

The primary view uses plain-language conclusions. An optional **Show the math** layer reveals the source airflow, duct-size changes, velocity, pressure losses, critical path, and collector operating point for players who want to understand or audit the engineering logic. The detail is available without becoming homework for everyone.

### 3. Decisions, not fiddly construction

The player chooses machines, collectors, priorities, and route approaches. The game creates elbows, reducers, branches, hangers, and installation detail automatically. Freehand duct drafting is not part of the initial game.

### 4. Every decision becomes visible

Fans spin, filters pulse, dust moves, leaks appear, workers install, gauges change, and the shop clears. A result should not exist only as a spreadsheet or score popup.

### 5. Ten minutes creates the pressure

Perfection is usually slower than good judgment. The player should often choose between one beautiful system and several good-enough systems. The clock creates urgency without requiring twitch controls.

### 6. Restarting is part of the fun

A finished run teaches the player something and offers an immediate retry. Restart should take less than five seconds. Early versions have high scores and personal improvement, not a large permanent progression grind.

## The complete ten-minute run

### Opening: 10:00–8:00

The company begins with limited cash, basic collector choices, and one installation slot. The first woodworking customer is simple and teaches the complete interaction without a separate tutorial.

The player should finish or meaningfully attempt the first system within roughly 60–90 seconds.

### Growth: 8:00–4:00

New customers introduce one complication at a time: greater airflow demand, longer routes, tighter budgets, production downtime, expansion requests, sparks, noise, or limited floor space.

Completed work provides cash and reputation. The player chooses a small number of upgrades that change decisions immediately, such as faster installation, better estimating information, or access to a stronger collector.

### Pressure: 4:00–1:00

Jobs overlap with harder tradeoffs. A quick small job may be safer than a lucrative plant that could consume the rest of the run. A weak earlier system may request service. The player cannot solve everything.

### Finish: 1:00–0:00

The clock becomes prominent. The player may rush a final installation, repair a poor startup, or bank the current result. Work completed before zero counts; unfinished commitments cost time or money but should not erase an otherwise successful run.

At 00:00 the simulation pauses, the factory settles, and the final score explains the run in a few readable categories. **Play Again** is the primary action.

## Core job loop

Each customer follows the same learnable rhythm:

1. **Customer arrives** — A compact card describes the industry, budget, urgency, and main problem.
2. **Inspect** — The fixed-isometric shop shows the machines, dust sources, obstacles, and existing conditions.
3. **Choose a collector** — Initially the choice is cheap, balanced, or powerful. Each has obvious tradeoffs.
4. **Choose routes** — Each machine receives a few legible route options rather than unrestricted drawing.
5. **Review** — A single panel summarizes expected capacity, restriction, cost, time, energy, safety, and expansion room.
6. **Commit** — The quote consumes company time and cash. Fabrication and installation happen automatically in a short, satisfying sequence.
7. **Start system** — Airflow, dust, equipment, and gauges animate. Strengths and mistakes become visible.
8. **Resolve** — The player accepts the result, spends limited resources correcting it, or abandons it and moves on.
9. **Reward** — Payment, reputation, job score, and the next opportunity appear without leaving the main flow for long.

## First customer: the cabinet shop

The first playable customer is one small woodworking shop viewed from a fixed isometric angle.

The floor contains three dust-producing machines:

- a table saw;
- a planer; and
- a wide-belt sander.

For the proof of concept, the main decision remains summarized in clear game language. Behind it, an optional source-backed engineering receipt uses scenario-specific CFM, duct geometry, velocity, and pressure-loss calculations. Machine requirements are identified as customer/OEM scenario inputs rather than universal values, and the game never claims to produce a code-compliant real-world design. `docs/ENGINEERING_MODEL.md` owns this boundary and the verified calculation method.

The three collector approaches are:

- **Budget** — cheap and quick, but short on capacity;
- **Balanced** — enough capacity when routed sensibly;
- **Powerful** — forgiving and expansion-ready, but expensive and slower to install.

Each machine offers two or three route choices. A short route may cross an obstacle or create a sharp restriction. A longer route may cost more but preserve airflow or future expansion. The game previews the direction of each tradeoff without revealing a guaranteed result.

When requested, **Show the math** explains where branch CFM combines, why the duct steps up or down, how velocity and velocity pressure are derived, which fittings create loss, which route is critical, and how that resistance changes the collector's expected operating point.

When the player starts the system:

- a good design pulls visible dust into the ducts and clears the room;
- a marginal design leaves intermittent dust near the weakest branch;
- a poor design leaks or fails to clear one or more machines;
- the result panel explains the main reason in plain language.

The first customer is successful when a new player can make a choice, see the installation, understand the result, and restart without explanation from the developer.

## Scoring

The score rewards productive judgment rather than perfection. The exact balance will change through playtesting, but the categories remain stable:

- **Jobs completed** — the strongest base reward;
- **Profit** — revenue minus equipment, installation, repairs, and penalties;
- **Air quality** — how much dust the completed systems remove;
- **Customer satisfaction** — performance, budget, downtime, and expansion fit;
- **Safety** — avoidance of clearly communicated hazards;
- **Efficiency** — useful collection relative to energy and restriction;
- **Reputation** — a run-level summary that affects which jobs appear.

Three good systems completed quickly may beat one perfect system. Safety mistakes should hurt, but early runs should teach rather than end instantly.

## Failure and recovery

There is no conventional death and no early game-over screen. Failure costs scarce run resources:

- a poor startup consumes time;
- replacement equipment consumes cash;
- a dissatisfied customer reduces reputation;
- an unsafe choice creates a major score penalty or forces correction;
- an abandoned job loses its commitment cost.

The player may recover, improvise, or move on. The run ends only when the timer reaches zero.

## Difficulty progression

New complexity arrives one concept at a time:

1. capacity and route restriction;
2. budget and installation time;
3. energy and noise;
4. future expansion;
5. production downtime;
6. sparks, fumes, or material-specific hazards;
7. existing equipment and retrofit constraints;
8. multiple attractive jobs competing for the same time and cash.

Early customers are woodworking shops. Later candidates may include furniture, food, metalworking, recycling, grain, mining, and battery production, but no industry is added until its mechanic creates a better ten-minute decision.

## Screen and control model

The game is mouse-first and understandable without memorized hotkeys.

The primary run screen contains:

- the fixed-isometric factory as the visual focus;
- the ten-minute clock;
- current cash, reputation, and installation availability;
- a compact customer/job panel;
- contextual collector and route choices;
- an optional **Show the math** engineering receipt;
- one clear commit or **Start System** action;
- a small result summary after startup.

The camera does not rotate. The proof of concept does not require free camera movement, first-person mode, character control, or precision placement. Optional keyboard shortcuts may duplicate common actions later.

The minimum screen flow is:

1. title/start;
2. ten-minute run;
3. final results;
4. immediate replay.

## Visual direction

Dust Rush uses clean, slightly exaggerated 2D isometric art: more classic management game than realistic CAD.

The visual priorities are:

- crisp silhouettes and clear machine identity;
- a consistent isometric angle and scale;
- cool steel and factory colors with warm safety and action accents;
- readable ducts and airflow paths;
- restrained interface panels that do not cover the factory;
- animation that makes the industrial process feel alive;
- visible dust, airflow, leaks, pulses, fans, trucks, cranes, and installation steps where they communicate state.

The game should feel inviting and a little playful, not dirty, grim, photorealistic, or corporate. Placeholder geometry and original temporary art are acceptable while proving the loop. Decorative polish must not block interaction testing.

## Audio direction

Audio should reinforce state: fans spin up, filters pulse, tools install, ducts clank, dust clears, and successful startup lands with a satisfying industrial rhythm. Music should support urgency without becoming stressful. Audio is polish after the first playable loop and is not required for the initial proof.

## Technical shape

- Godot 4.7.1, standard build
- Fixed-isometric Godot 2D presentation
- Typed GDScript
- Data-driven jobs, machines, collectors, and results
- Source-backed engineering scenario data and deterministic calculations governed by `docs/ENGINEERING_MODEL.md`
- Gameplay state separated from scene presentation
- No network service, account, telemetry, purchase, or external dependency in the proof of concept

`docs/ARCHITECTURE.md` owns the detailed code boundaries. `docs/SECURITY_BASELINE.md` owns dependency and data guardrails.

## Milestones

### Milestone 0 — secure scaffold

Complete. The project loads and runs, the ten-minute timer works, documentation exists, and protected automated checks guard the repository.

### Milestone 1 — one-customer toy

One cabinet shop, three machines, three collector approaches, route choices, installation feedback, startup outcome, a small score, and instant restart. A player can complete the interaction in 60–90 seconds.

### Milestone 2 — first ten-minute run

At least three sequential customers, cash and reputation, one or two immediate upgrades, increasing difficulty, final scoring, and replay.

### Milestone 3 — prove replayability

Balance choices so there is no single automatic answer. Add enough job variation that a tester willingly plays three consecutive runs. Improve feedback, animation, and sound where confusion or flatness remains.

### Milestone 4 — production direction

Only after the toy is demonstrably fun: choose the broader customer set, content pipeline, original art production plan, save/high-score approach, distribution targets, and release scope.

## Explicit non-goals

Until separately approved, Dust Rush does not include:

- freehand CAD-style duct drafting;
- physically accurate fluid simulation;
- construction-ready, code-compliant, stamped, or commissioning-grade system design;
- manual welding, driving, lifting, or worker control;
- a rotatable 3D factory or first-person mode;
- deep employee scheduling, fabrication inventory, shipping, or accounting;
- a huge catalog of real manufacturer parts;
- combat, politics, or intentional injury spectacle;
- multiplayer, accounts, cloud saves, leaderboards, telemetry, ads, or purchases;
- user-generated scripts, arbitrary mods, or unreviewed addons;
- a permanent progression system that overwhelms the ten-minute run.

## Definition of “fun enough to continue”

The proof of concept earns further development when playtesting shows most of the following:

- A new player understands the goal within 20 seconds.
- The first meaningful choice happens within 30 seconds.
- The first system starts within 90 seconds.
- The player can explain why the result succeeded or failed.
- Watching startup is satisfying even with placeholder art.
- At least two collector/route strategies feel defensible.
- Restart takes less than five seconds.
- Testers voluntarily replay and try a different approach.
- The clock creates urgency without making the interface frustrating.

If those signals are absent, add no tycoon layers. Improve or replace the core interaction first.

## Decision filter

Before adding any feature, ask:

1. Does it create a clearer or more interesting decision inside ten minutes?
2. Will the consequence be visible in the factory?
3. Can a new player understand it without studying a manual?
4. Can it be introduced without weakening the first minute?
5. Is it worth the implementation and maintenance cost now?

If the answer is mostly no, the feature does not belong in the current game.
