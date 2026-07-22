# Dust Rush: Industrial Tycoon — proof-of-concept design

## Product promise

Dust Rush is a fast industrial-management game: get as far as possible in ten minutes by solving increasingly difficult dust-collection jobs.

The player should understand the first decision immediately. Depth comes from quick tradeoffs, visible consequences, and replayable scoring—not from a large catalog or a complicated editor.

## First playable slice

The first slice is deliberately smaller than the full ten-minute run:

1. Open one woodworking shop.
2. Start a short countdown.
3. Choose one of three collector approaches.
4. Connect three machines using simple route choices.
5. Start the system.
6. Show whether dust clears or escapes.
7. Award a score and allow an instant restart.

## Ten-minute loop

Each completed job pays the company and unlocks a harder customer. A run ends at 00:00 and scores:

- jobs completed;
- profit;
- air quality improved;
- customer satisfaction;
- safety; and
- system efficiency.

The guiding rule is: easy decisions in the first minute, hard tradeoffs by minute eight.

## Explicitly out of scope for the scaffold

- freehand duct engineering;
- fabrication, shipping, crews, or employee management;
- networking, accounts, leaderboards, telemetry, or purchases;
- realistic fluid dynamics;
- user-generated content or mod loading;
- third-party art, audio, or plugins.

These require separate, approved tickets after the core interaction is proven fun.
