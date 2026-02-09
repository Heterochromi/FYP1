#!/usr/bin/env python3
r"""
check_margins.py
Verify that the LaTeX geometry margins match the FYP Handbook requirements.

Usage:
    1. Generate a .log file with geometry info:
       export PATH="$HOME/.TinyTeX/bin/x86_64-linux:$PATH"
       cat > /tmp/check_margins.tex << 'EOF'
       \documentclass[a4paper,12pt,oneside]{report}
       \usepackage[a4paper,left=38mm,right=28mm,top=28mm,bottom=28mm,footskip=15mm]{geometry}
       \begin{document}
       \typeout{=== MARGIN CHECK ===}
       \typeout{textwidth = \the\textwidth}
       \typeout{textheight = \the\textheight}
       \typeout{oddsidemargin = \the\oddsidemargin}
       \typeout{topmargin = \the\topmargin}
       \typeout{headheight = \the\headheight}
       \typeout{headsep = \the\headsep}
       \typeout{paperwidth = \the\paperwidth}
       \typeout{paperheight = \the\paperheight}
       \typeout{footskip = \the\footskip}
       \typeout{=== END CHECK ===}
       Hello
       \end{document}
       EOF
       cd /tmp && xelatex -interaction=batchmode check_margins.tex

    2. Run this script:
       python3 check_margins.py /tmp/check_margins.log

    Or run without arguments to use hardcoded values from a known-good build.
"""

import sys
import re
import os


# LaTeX internal constants
INCH_IN_PT = 72.27   # 1 inch in TeX points
MM_IN_PT = 2.8346    # 1mm in TeX points

# Handbook required margins (in mm)
REQUIRED = {
    "Left":   38,
    "Right":  28,
    "Top":    28,
    "Bottom": 28,
}

# Expected paper size (A4)
EXPECTED_PAPER_W_MM = 210
EXPECTED_PAPER_H_MM = 297

# Tolerance for margin checks (mm)
TOLERANCE_MM = 1.0


def parse_log_file(log_path):
    """Parse a LaTeX log file for geometry values."""
    values = {}
    pattern = re.compile(r"^(\w+)\s*=\s*([-\d.]+)pt\s*$")

    with open(log_path, "r") as f:
        in_section = False
        for line in f:
            line = line.strip()
            if line == "=== MARGIN CHECK ===":
                in_section = True
                continue
            if line == "=== END CHECK ===":
                break
            if in_section:
                m = pattern.match(line)
                if m:
                    values[m.group(1)] = float(m.group(2))

    return values


def get_default_values():
    """Hardcoded values from a known-good XeLaTeX build with the FYP geometry."""
    return {
        "textwidth":      409.7197,
        "textheight":     685.71143,
        "oddsidemargin":  35.85048,
        "topmargin":      -29.60228,
        "headheight":     12.0,
        "headsep":        25.0,
        "paperwidth":     597.50787,
        "paperheight":    845.04684,
        "footskip":       42.67912,
    }


def compute_margins(v):
    """Compute actual margins in mm from LaTeX internal values in pt."""
    # LaTeX adds 1 inch to oddsidemargin for the actual left margin
    left_pt = v["oddsidemargin"] + INCH_IN_PT
    left_mm = left_pt / MM_IN_PT

    # Right margin = paperwidth - left - textwidth
    right_pt = v["paperwidth"] - left_pt - v["textwidth"]
    right_mm = right_pt / MM_IN_PT

    # Top: the distance from page top to text area top
    # = topmargin + 1in + headheight + headsep
    top_pt = v["topmargin"] + INCH_IN_PT + v["headheight"] + v["headsep"]
    top_mm = top_pt / MM_IN_PT

    # Bottom margin = paperheight - top - textheight
    bottom_pt = v["paperheight"] - top_pt - v["textheight"]
    bottom_mm = bottom_pt / MM_IN_PT

    return {
        "Left":   left_mm,
        "Right":  right_mm,
        "Top":    top_mm,
        "Bottom": bottom_mm,
    }


def main():
    # Determine source of values
    if len(sys.argv) > 1:
        log_path = sys.argv[1]
        if not os.path.isfile(log_path):
            print(f"Error: file not found: {log_path}")
            sys.exit(1)
        print(f"Reading values from: {log_path}")
        v = parse_log_file(log_path)
        if not v:
            print("Error: could not find MARGIN CHECK section in log file.")
            print("Make sure your .tex file includes the \\typeout commands.")
            sys.exit(1)
    else:
        print("No log file specified. Using hardcoded default values.")
        print("(Run with:  python3 check_margins.py /tmp/check_margins.log)")
        v = get_default_values()

    print()

    # Show raw values
    print("Raw LaTeX geometry values (pt):")
    print("-" * 40)
    for key in ["textwidth", "textheight", "oddsidemargin", "topmargin",
                 "headheight", "headsep", "paperwidth", "paperheight", "footskip"]:
        if key in v:
            print(f"  {key:<18} = {v[key]:>12.5f} pt")
    print()

    # Compute margins
    margins = compute_margins(v)

    # Print results table
    sep = "=" * 62
    print(sep)
    print(f"{'Margin':<12} {'Actual (mm)':<16} {'Required (mm)':<16} {'Result'}")
    print(sep)

    all_pass = True
    for name in ["Left", "Right", "Top", "Bottom"]:
        actual = margins[name]
        required = REQUIRED[name]
        diff = abs(actual - required)
        ok = diff < TOLERANCE_MM
        status = "PASS" if ok else "FAIL"
        if not ok:
            all_pass = False
        print(f"  {name:<10} {actual:<16.2f} {required:<16} {status}  (diff: {diff:.2f}mm)")

    print(sep)
    print()

    # Derived dimensions
    tw_mm = v["textwidth"] / MM_IN_PT
    th_mm = v["textheight"] / MM_IN_PT
    pw_mm = v["paperwidth"] / MM_IN_PT
    ph_mm = v["paperheight"] / MM_IN_PT
    expected_tw = EXPECTED_PAPER_W_MM - REQUIRED["Left"] - REQUIRED["Right"]
    expected_th = EXPECTED_PAPER_H_MM - REQUIRED["Top"] - REQUIRED["Bottom"]

    print("Derived dimensions:")
    print(f"  Text width:   {tw_mm:.2f}mm  (expected ~{expected_tw}mm)")
    print(f"  Text height:  {th_mm:.2f}mm  (expected ~{expected_th}mm)")
    print(f"  Paper size:   {pw_mm:.1f}mm x {ph_mm:.1f}mm  (A4 = {EXPECTED_PAPER_W_MM}x{EXPECTED_PAPER_H_MM}mm)")
    print()

    # Overall verdict
    if all_pass:
        print("RESULT: ALL MARGIN CHECKS PASSED")
        sys.exit(0)
    else:
        print("RESULT: SOME MARGIN CHECKS FAILED")
        print(f"  (tolerance: {TOLERANCE_MM}mm)")
        sys.exit(1)


if __name__ == "__main__":
    main()
