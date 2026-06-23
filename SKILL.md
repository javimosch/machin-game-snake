---
name: machin-game-snake
description: Build, run, and modify machin-game-snake — a terminal Snake game written in machin (MFL). Use when working on this repo, or as a worked example of real-time terminal input (raw_mode/read_key), ANSI rendering, and the frame-loop pattern in MFL.
---

# machin-game-snake

The classic Snake, written in [machin](https://github.com/javimosch/machin) (MFL) and compiled to one native binary. It is the reference example for **interactive terminal programs** in machin.

> The shared game-dev setup, build-and-verify workflow, and the cross-cutting caveats/gotchas live in the canonical **[machin-gamedev skill](https://github.com/javimosch/machin/blob/main/skills/machin-gamedev/SKILL.md)** (terminal + GUI + audio). This file is Snake's specifics.

## Build & run

```bash
./build.sh                 # machin encode snake.src -> snake.mfl, then machin build -> ./machin-game-snake
./machin-game-snake        # play
```

Requires **machin v0.41.0+** (for the `raw_mode`/`read_key` builtins). `MACHIN=/path/to/machin ./build.sh` to use a specific compiler.

Controls: `w a s d` or `h j k l` to steer, `q` to quit.

## The two builtins this game is built on

machin's `input()` is line-buffered — it blocks until Enter. A game can't use that, so machin v0.41.0 added real terminal input:

- **`raw_mode(on) -> int`** — `raw_mode(1)` puts the tty in cbreak + no-echo mode (keys arrive immediately, nothing is echoed); `raw_mode(0)` restores the saved settings. Always pair them, and restore before exit (this game does it right before printing "game over").
- **`read_key() -> string`** — non-blocking. Returns the next pending key as a 1-character string, or `""` if no key is waiting. Call it once per frame and steer on the result; `""` just means "keep going straight."

These only make sense on a real terminal. Under a pipe or in CI, `read_key()` returns `""` and the snake runs straight into the wall — handy for a smoke test.

## Patterns worth copying

- **ANSI without `\x`.** MFL string literals support `\n \t \r \" \\` but not `\x1b`. Build the ESC byte from hex: `ESC := bytes_str(from_hex("1b"))`, then `ESC + "[2J"` (clear), `ESC + "[H"` (home), `ESC + "[?25l"`/`[?25h"` (hide/show cursor), `ESC + "[" + str(n) + "m"` (color).
- **One print per frame.** Build the entire frame into a single string and `print()` it once, then `flush()`. Printing cell-by-cell flickers.
- **Frame timing.** `sleep(110)` per tick ≈ 9 fps. Lower it to speed the game up.
- **Cells as ints.** Pack `(x, y)` into one `int` (`y*100 + x`) so the snake is a plain `[]int` and membership tests are simple loops.
- **No slice ranges.** MFL has no `s[1:]`; `drop_first` rebuilds the slice with a loop to drop the tail each step.
- **Random.** `rand_bytes(2)` then `% w` / `% h` gives a uniform-ish random cell for food.

## Modifying

- **Board size:** change `w`/`h` in `main` (keep both < 100 for the `y*100+x` packing).
- **Speed:** the `sleep(110)` in the main loop.
- **Arrow keys:** they arrive as a 3-byte sequence (`ESC` `[` `A/B/C/D`). `read_key()` returns one byte per call, so to support them, detect an `ESC` byte and read the next two; WASD/HJKL avoids that.
- After any edit to `snake.src`, re-run `./build.sh` (never hand-edit `snake.mfl` — it is generated).
