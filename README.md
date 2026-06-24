# machin-game-demo-snake

The classic **Snake**, written in **[machin](https://github.com/javimosch/machin)** (MFL) and compiled to a single native binary. It runs in your terminal — a growing snake, food, score, and a real-time frame loop, in ~190 lines of one-declaration-per-line MFL.

Part of [**awesome-machin**](https://github.com/javimosch/awesome-machin) — the machin ecosystem.

> **Agents:** [`SKILL.md`](SKILL.md) explains the build, the game loop, and the two terminal builtins this game is built on.

```
+------------------------+
|                        |
|           *            |
|                        |
|     oooo@              |
|                        |
+------------------------+
 score 3    wasd/hjkl move | q quit
```

## Why it exists

The machin north star is "build real things, let usage drive features." A terminal game is a sharp dogfood: it needs **per-keypress, non-blocking input** — and machin's `input()` is line-buffered (it blocks for a whole line + Enter), which a game can't use.

So this game surfaced exactly one clean, broadly-useful gap, which became two native builtins in **machin v0.41.0**:

- **`raw_mode(on)`** — put the terminal in cbreak / no-echo mode (`on = 1`), or restore it (`on = 0`).
- **`read_key()`** — non-blocking single-key read; returns the key as a 1-char string, or `""` if nothing is waiting.

Everything else the game needs already existed: ANSI rendering (the ESC byte is built with `bytes_str(from_hex("1b"))` — MFL strings have no `\x` escape), frame timing with `sleep`, and uniform-random food placement with `rand_bytes`. That's the loop working as intended: the tool comes first, exposes the gap, the language fills it once, and every future TUI tool inherits it.

## Build

Needs the `machin` compiler (**v0.41.0+**, for `raw_mode`/`read_key`) and a C compiler.

```bash
./build.sh            # → ./machin-game-demo-snake
```

## Play

```bash
./machin-game-demo-snake
```

Steer with **`w` `a` `s` `d`** or **`h` `j` `k` `l`**; **`q`** quits. Eat the `*` to grow and score; you die on a wall or on yourself. The terminal is restored on exit.

## How it works

- **Board.** A 24×16 interior; each cell is packed as `y*100 + x` so positions are plain `int`s.
- **Snake.** A `[]int` of cells, head at the last index. Each step appends a new head and drops the tail (MFL has no `s[1:]`, so `drop_first` rebuilds the slice).
- **Turns.** Only perpendicular turns are accepted, which also blocks instant 180° suicides.
- **Self-collision.** Legal to move onto the current tail cell when *not* eating — it vacates that frame.
- **Render.** The whole frame is built as one string (cursor-home + border + rows + status) and printed once per tick, then `flush()`ed.

See [`snake.src`](snake.src) — the readable source. `build.sh` runs `machin encode` to produce the canonical `snake.mfl`, then `machin build`.

## License

MIT
