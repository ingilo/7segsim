# 7-Segment Logic Lab

A browser-based simulator for learning how to drive a 7-segment display with logic gates
(AND, NAND, OR, NOR, XOR, XNOR, NOT) from a controller with a limited number of outputs.

## Run it

Open `index.html` in any modern browser (double-click it). There's nothing to install and it needs no internet connection.

### Windows app (.exe)

`dist\7-Segment Logic Lab.exe` is a single standalone file (about 90 KB) with the simulator built in.
Copy it anywhere, e.g. a USB stick, OneDrive or Teams, and double-click it. It opens in its own app window using
Microsoft Edge (or Chrome), which every Windows 10/11 PC has. Autosave, Save/Open and Image all work.

After changing `index.html`, rebuild the exe:

```
powershell -ExecutionPolicy Bypass -File app\build.ps1
```

The build uses the C# compiler that comes with Windows, so nothing extra needs to be installed. The exe is not
code-signed, so Windows SmartScreen may show "Windows protected your PC" the first time; click
*More info → Run anyway*.

## Features

- **Controller** with 1–8 outputs (bits). A is the most significant bit.
- **1–4 displays** for bigger numbers (e.g. 0–15 in decimal or 00–FF in hex), with blank or visible leading zeros.
- **Gates** with 2–4 inputs, constants, and text notes. Drag and drop, then wire pin to pin.
- **Realistic LED display** with inputs a–g, as a common cathode or common anode display.
- **Tasks**: a warm-up, 0–3, 0–7, a BCD decoder, a hex decoder, common anode, and NAND-only / NOR-only challenges.
- **Check panel**:
  - Truth table: each segment is marked green or red, with a mini preview of what your circuit shows for every input.
  - Karnaugh map per segment (1–4 bits), with don't-cares and minterm lists.
  - Expressions: the Boolean formula your wiring actually computes, with overbars for NOT.
  - 💡 Solution: minimal expressions per segment (Quine–McCluskey, using don't-cares), revealed one segment at a
    time. The Karnaugh map highlights the group each term covers, and one button builds the whole circuit on the
    board. NAND-only / NOR-only tasks get NAND–NAND / NOR–NOR circuits.
  - Add `?nosolution` to the link (e.g. `https://…netlify.app/?nosolution`) to hide all solutions, e.g. for tests.
- **Learning aids**:
  - Click a gate to see its truth table (with the current row marked), its live values and the formula its output computes.
  - The display marks mistakes: a dashed segment should be lit, and a yellow segment should be off.
  - "Jump to a wrong digit" takes you to the next incorrect input. Hovering a part highlights its wires, and wire tooltips show where each wire goes.
  - The truth table has a *Code* column with the segment byte (e.g. `0x3F` for 0), the value a microcontroller would output to drive the display directly.
- **Editing**:
  - Wire by dragging, or by clicking one pin and then the other; the pins you can connect to light up.
  - Multi-select (Shift+drag), copy/paste, duplicate, undo/redo, and zoom/pan.
  - Keys A–F toggle the controller inputs.
- **Saving**: autosave in the browser, save/open `.json` files, and export a PNG picture of the circuit to hand in.
