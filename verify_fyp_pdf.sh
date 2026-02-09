#!/usr/bin/env bash
#
# verify_fyp_pdf.sh
# Comprehensive verification of an MMU FCI FYP report PDF against
# the FYP Handbook (Revised APR 2025) requirements.
#
# Usage:
#   chmod +x verify_fyp_pdf.sh
#   ./verify_fyp_pdf.sh paper.pdf
#   ./verify_fyp_pdf.sh paper.pdf fypStandard.cls paper.tex
#
# Dependencies: pdfinfo, pdffonts, pdftotext (from poppler-utils), python3
#

set -euo pipefail

# ============================================================================
# CONFIGURATION
# ============================================================================

# Handbook-mandated values
REQUIRED_LEFT_MM=38
REQUIRED_RIGHT_MM=28
REQUIRED_TOP_MM=28
REQUIRED_BOTTOM_MM=28
MARGIN_TOLERANCE_MM=1.5

REQUIRED_BODY_FONT_PT=12
REQUIRED_CHAPTER_FONT_PT=14
REQUIRED_SECTION_FONT_PT=12

REQUIRED_FONT_FAMILY="Arial"
UNWANTED_FONTS_REGEX="[Tt]imes|CMR|cmr|LMR|lmr|[Ll]atin.[Mm]odern|[Cc]omputer.[Mm]odern"

REQUIRED_PAPER="A4"
A4_WIDTH_PT=595
A4_HEIGHT_PT=841
PAPER_TOLERANCE_PT=2

# Handbook page order (content fingerprints for the first line of each page type)
declare -a EXPECTED_PAGE_ORDER=(
    "COVER:FINAL YEAR PROJECT"
    "TITLE:FYP"
    "COPYRIGHT:Universiti Telekom"
    "DECLARATION:DECLARATION"
    "ACKNOWLEDGEMENTS:ACKNOWLEDGEMENTS"
    "ABSTRACT:ABSTRACT"
    "TOC:TABLE OF CONTENTS"
)

# Required cover page elements
declare -a COVER_ELEMENTS=(
    "FINAL YEAR PROJECT"
    "REPORT"
)

# Required title page elements
declare -a TITLE_ELEMENTS=(
    "BY"
    "PARTIAL FULFILMENT"
    "REQUIREMENT FOR THE DEGREE"
    "Faculty of Computing and Informatics"
    "MULTIMEDIA UNIVERSITY"
    "MALAYSIA"
)

# Required copyright page elements
declare -a COPYRIGHT_ELEMENTS=(
    "Universiti Telekom Sdn"
    "ALL RIGHTS RESERVED"
    "Regulation 7.2"
    "Intellectual Property"
    "Commercialisation Policy"
)

# Required declaration page elements
declare -a DECLARATION_ELEMENTS=(
    "DECLARATION"
    "hereby declare"
    "Faculty of Computing"
    "Multimedia University"
)

# ============================================================================
# COLOUR OUTPUT
# ============================================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

pass_count=0
fail_count=0
warn_count=0
note_count=0

pass_msg() {
    pass_count=$((pass_count + 1))
    printf "  ${GREEN}PASS${NC}  %s\n" "$1"
}

fail_msg() {
    fail_count=$((fail_count + 1))
    printf "  ${RED}FAIL${NC}  %s\n" "$1"
}

warn_msg() {
    warn_count=$((warn_count + 1))
    printf "  ${YELLOW}WARN${NC}  %s\n" "$1"
}

note_msg() {
    note_count=$((note_count + 1))
    printf "  ${CYAN}NOTE${NC}  %s\n" "$1"
}

section_header() {
    echo ""
    printf "${BOLD}${BLUE}══════════════════════════════════════════════════════════════${NC}\n"
    printf "${BOLD}${BLUE}  %s${NC}\n" "$1"
    printf "${BOLD}${BLUE}══════════════════════════════════════════════════════════════${NC}\n"
}

subsection_header() {
    printf "\n  ${BOLD}── %s ──${NC}\n" "$1"
}

# ============================================================================
# ARGUMENT PARSING
# ============================================================================

PDF_FILE="${1:-}"
CLS_FILE="${2:-}"
TEX_FILE="${3:-}"

if [ -z "$PDF_FILE" ]; then
    echo "Usage: $0 <paper.pdf> [fypStandard.cls] [paper.tex]"
    echo ""
    echo "Arguments:"
    echo "  paper.pdf          The rendered PDF to verify (required)"
    echo "  fypStandard.cls    The LaTeX class file (optional, for deeper checks)"
    echo "  paper.tex          The intermediate .tex file (optional, for deeper checks)"
    exit 1
fi

if [ ! -f "$PDF_FILE" ]; then
    echo "Error: PDF file not found: $PDF_FILE"
    exit 1
fi

HAS_CLS=false
HAS_TEX=false
if [ -n "$CLS_FILE" ] && [ -f "$CLS_FILE" ]; then
    HAS_CLS=true
fi
if [ -n "$TEX_FILE" ] && [ -f "$TEX_FILE" ]; then
    HAS_TEX=true
fi

# ============================================================================
# DEPENDENCY CHECK
# ============================================================================

section_header "DEPENDENCY CHECK"

missing_deps=0
for cmd in pdfinfo pdffonts pdftotext python3; do
    if command -v "$cmd" >/dev/null 2>&1; then
        pass_msg "$cmd found: $(command -v "$cmd")"
    else
        fail_msg "$cmd not found — install poppler-utils and python3"
        missing_deps=1
    fi
done

if [ "$missing_deps" -eq 1 ]; then
    echo ""
    echo "Install missing dependencies:"
    echo "  sudo apt install poppler-utils python3"
    exit 1
fi

# ============================================================================
# 1. BASIC PDF INFO
# ============================================================================

section_header "1. BASIC PDF INFORMATION"

pdf_info=$(pdfinfo "$PDF_FILE" 2>/dev/null)
total_pages=$(echo "$pdf_info" | grep "^Pages:" | awk '{print $2}')
page_size=$(echo "$pdf_info" | grep "^Page size:" | sed 's/Page size: *//')
creator=$(echo "$pdf_info" | grep "^Creator:" | sed 's/Creator: *//')
producer=$(echo "$pdf_info" | grep "^Producer:" | sed 's/Producer: *//')

echo "  File:     $PDF_FILE"
echo "  Pages:    $total_pages"
echo "  Size:     $page_size"
echo "  Creator:  $creator"
echo "  Producer: $producer"

# Check page count is reasonable (handbook says ~40 pages for interim)
if [ "$total_pages" -ge 5 ]; then
    pass_msg "Page count ($total_pages) is reasonable"
else
    warn_msg "Page count ($total_pages) seems very low — handbook suggests ~40 pages for interim"
fi

# Check paper size is A4
# page_size looks like: "595.28 x 841.89 pts (A4)"
page_w=$(echo "$page_size" | awk '{print $1}')
page_h=$(echo "$page_size" | awk '{print $3}')
page_w_int=$(printf "%.0f" "$page_w")
page_h_int=$(printf "%.0f" "$page_h")

w_diff=$((page_w_int - A4_WIDTH_PT))
h_diff=$((page_h_int - A4_HEIGHT_PT))
w_diff=${w_diff#-}
h_diff=${h_diff#-}

if [ "$w_diff" -le "$PAPER_TOLERANCE_PT" ] && [ "$h_diff" -le "$PAPER_TOLERANCE_PT" ]; then
    pass_msg "Paper size is A4 (${page_w} x ${page_h} pts)"
else
    fail_msg "Paper size (${page_w} x ${page_h} pts) does not match A4 (${A4_WIDTH_PT} x ${A4_HEIGHT_PT} pts)"
fi

# ============================================================================
# 2. FONT VERIFICATION
# ============================================================================

section_header "2. FONT VERIFICATION"

font_output=$(pdffonts "$PDF_FILE" 2>/dev/null)
echo "$font_output" | head -3
echo "$font_output" | tail -n +3

subsection_header "Required font: $REQUIRED_FONT_FAMILY"

arial_count=$(echo "$font_output" | grep -ci "arial" || true)
if [ "$arial_count" -gt 0 ]; then
    pass_msg "Arial font found ($arial_count variant(s))"
    # Show which variants
    echo "$font_output" | grep -i "arial" | while read -r line; do
        printf "        %s\n" "$line"
    done
else
    helvetica_count=$(echo "$font_output" | grep -ci "helvetica\|heros" || true)
    if [ "$helvetica_count" -gt 0 ]; then
        warn_msg "Arial not found, but Helvetica/TeX Gyre Heros used as fallback ($helvetica_count variant(s))"
    else
        fail_msg "Neither Arial nor Helvetica/TeX Gyre Heros found in the PDF"
    fi
fi

subsection_header "Checking for unwanted fonts"

unwanted=$(echo "$font_output" | grep -iE "$UNWANTED_FONTS_REGEX" || true)
if [ -z "$unwanted" ]; then
    pass_msg "No unwanted serif fonts (Times, Computer Modern, Latin Modern)"
else
    fail_msg "Unwanted fonts detected:"
    echo "$unwanted" | while read -r line; do
        printf "        ${RED}%s${NC}\n" "$line"
    done
fi

subsection_header "Font embedding check"

not_embedded=$(echo "$font_output" | tail -n +3 | awk '$4 == "no"' || true)
if [ -z "$not_embedded" ]; then
    pass_msg "All fonts are embedded"
else
    warn_msg "Some fonts are NOT embedded (may cause display issues):"
    echo "$not_embedded" | while read -r line; do
        printf "        %s\n" "$line"
    done
fi

# ============================================================================
# 3. PAGE ORDER VERIFICATION
# ============================================================================

section_header "3. PAGE ORDER VERIFICATION"

echo "  Extracting first line of each page..."
echo ""

declare -a actual_first_lines
for i in $(seq 1 "$total_pages"); do
    first_line=$(pdftotext -f "$i" -l "$i" "$PDF_FILE" - 2>/dev/null | grep -v '^[[:space:]]*$' | head -1 | sed 's/^[[:space:]]*//' | head -c 70)
    actual_first_lines[$i]="$first_line"
done

printf "  ${BOLD}%-6s %-35s %s${NC}\n" "Page" "Expected (Handbook)" "Actual First Line"
printf "  %-6s %-35s %s\n" "------" "-----------------------------------" "----------------------------------------"

# Check each expected page
page_idx=1
all_order_ok=true

for expected_entry in "${EXPECTED_PAGE_ORDER[@]}"; do
    label="${expected_entry%%:*}"
    fingerprint="${expected_entry##*:}"

    if [ "$page_idx" -le "$total_pages" ]; then
        actual="${actual_first_lines[$page_idx]}"
        if echo "$actual" | grep -qi "$fingerprint"; then
            printf "  ${GREEN}%-6s${NC} %-35s %.50s\n" "$page_idx" "$label" "$actual"
        else
            printf "  ${RED}%-6s${NC} %-35s %.50s\n" "$page_idx" "$label" "$actual"
            all_order_ok=false
        fi
    else
        printf "  ${RED}%-6s${NC} %-35s %s\n" "$page_idx" "$label" "(MISSING — PDF has only $total_pages pages)"
        all_order_ok=false
    fi
    page_idx=$((page_idx + 1))
done

# Show remaining pages
if [ "$page_idx" -le "$total_pages" ]; then
    echo ""
    echo "  Remaining pages:"
    for i in $(seq "$page_idx" "$total_pages"); do
        actual="${actual_first_lines[$i]}"
        printf "  %-6s %-35s %.50s\n" "$i" "" "$actual"
    done
fi

echo ""
if $all_order_ok; then
    pass_msg "Preliminary page order matches handbook requirements"
else
    fail_msg "Page order does not match handbook — review above"
fi

# ============================================================================
# 4. PAGE NUMBERING VERIFICATION
# ============================================================================

section_header "4. PAGE NUMBERING VERIFICATION"

echo "  Handbook requires:"
echo "    - Cover/Title pages: NO visible page number"
echo "    - Preliminary pages: lowercase Roman numerals (ii, iii, iv...)"
echo "    - Main text (from Chapter 1): Arabic numerals (1, 2, 3...)"
echo ""

printf "  ${BOLD}%-6s %-30s %-10s %s${NC}\n" "Page" "Content" "PageNum" "Expected"
printf "  %-6s %-30s %-10s %s\n" "------" "------------------------------" "----------" "----------"

for i in $(seq 1 "$total_pages"); do
    # Extract the page number from the bottom of the page using -layout mode
    page_text=$(pdftotext -layout -f "$i" -l "$i" "$PDF_FILE" - 2>/dev/null)
    # Get last non-empty line
    bottom_text=$(echo "$page_text" | grep -v '^[[:space:]]*$' | tail -1 | sed 's/^[[:space:]]*//' | sed 's/[[:space:]]*$//')
    # Try to extract just the page number (roman or arabic) from the bottom
    page_num=$(echo "$bottom_text" | grep -oE '^[ivxlc]+$|^[0-9]+$' || true)

    content=$(echo "${actual_first_lines[$i]:-}" | head -c 28)

    # Determine what we expect
    if [ "$i" -le 2 ]; then
        expected="(none)"
    elif echo "${actual_first_lines[$i]:-}" | grep -qiE "^CHAPTER [0-9]|^[0-9]+ Introduction"; then
        expected="Arabic 1+"
        # From this page forward, we expect Arabic
        arabic_start=$i
    elif [ "${arabic_start:-0}" -gt 0 ] && [ "$i" -ge "${arabic_start:-999}" ]; then
        expected="Arabic"
    else
        expected="Roman"
    fi

    printf "  %-6s %-30s %-10s %s\n" "$i" "$content" "${page_num:-(n/a)}" "$expected"
done

echo ""
note_msg "Page numbers at the very bottom of a page may not always be"
note_msg "extracted by pdftotext. Visually verify in the PDF viewer."

# ============================================================================
# 5. COVER PAGE CONTENT
# ============================================================================

section_header "5. COVER PAGE CONTENT CHECK"

cover_text=$(pdftotext -f 1 -l 1 "$PDF_FILE" - 2>/dev/null)

for element in "${COVER_ELEMENTS[@]}"; do
    if echo "$cover_text" | grep -qi "$element"; then
        pass_msg "Cover page contains: \"$element\""
    else
        fail_msg "Cover page MISSING: \"$element\""
    fi
done

# Check all text is uppercase (excluding minor words)
upper_lines=$(echo "$cover_text" | grep -v '^[[:space:]]*$' | grep -v '^[[:space:]]*$')
has_lowercase=false
while IFS= read -r line; do
    clean=$(echo "$line" | sed 's/[[:space:]]//g')
    if [ -n "$clean" ]; then
        upper=$(echo "$clean" | tr '[:lower:]' '[:upper:]')
        if [ "$clean" != "$upper" ]; then
            has_lowercase=true
            break
        fi
    fi
done <<< "$upper_lines"

if $has_lowercase; then
    note_msg "Cover page has some mixed-case text (handbook shows all capitals)"
else
    pass_msg "Cover page text is in uppercase as required"
fi

# ============================================================================
# 6. TITLE PAGE CONTENT
# ============================================================================

section_header "6. TITLE PAGE CONTENT CHECK"

title_text=$(pdftotext -f 2 -l 2 "$PDF_FILE" - 2>/dev/null)

for element in "${TITLE_ELEMENTS[@]}"; do
    if echo "$title_text" | grep -qi "$element"; then
        pass_msg "Title page contains: \"$element\""
    else
        fail_msg "Title page MISSING: \"$element\""
    fi
done

# ============================================================================
# 7. COPYRIGHT PAGE CONTENT
# ============================================================================

section_header "7. COPYRIGHT PAGE CONTENT CHECK"

copyright_text=$(pdftotext -f 3 -l 3 "$PDF_FILE" - 2>/dev/null)

for element in "${COPYRIGHT_ELEMENTS[@]}"; do
    if echo "$copyright_text" | grep -qi "$element"; then
        pass_msg "Copyright page contains: \"$element\""
    else
        fail_msg "Copyright page MISSING: \"$element\""
    fi
done

# Check copyright year
current_year=$(date +%Y)
if echo "$copyright_text" | grep -q "$current_year"; then
    pass_msg "Copyright year ($current_year) is current"
else
    warn_msg "Copyright year $current_year not found — verify it matches submission year"
fi

# ============================================================================
# 8. DECLARATION PAGE CONTENT
# ============================================================================

section_header "8. DECLARATION PAGE CONTENT CHECK"

declaration_text=$(pdftotext -f 4 -l 4 "$PDF_FILE" - 2>/dev/null)

for element in "${DECLARATION_ELEMENTS[@]}"; do
    if echo "$declaration_text" | grep -qi "$element"; then
        pass_msg "Declaration page contains: \"$element\""
    else
        fail_msg "Declaration page MISSING: \"$element\""
    fi
done

# ============================================================================
# 9. CHAPTER STRUCTURE CHECK
# ============================================================================

section_header "9. CHAPTER STRUCTURE CHECK"

echo "  Scanning for chapters in the PDF..."
echo ""

chapter_pages=""
for i in $(seq 1 "$total_pages"); do
    first="${actual_first_lines[$i]:-}"
    if echo "$first" | grep -qE "^CHAPTER [0-9]"; then
        chap_num=$(echo "$first" | grep -oE '[0-9]+' | head -1)
        printf "  Found: CHAPTER %s on PDF page %s\n" "$chap_num" "$i"
        chapter_pages="$chapter_pages $i"
    fi
done

chapter_count=$(echo "$chapter_pages" | wc -w)
echo ""

if [ "$chapter_count" -ge 6 ]; then
    pass_msg "Found $chapter_count chapters (handbook suggests 6 for interim)"
elif [ "$chapter_count" -ge 4 ]; then
    warn_msg "Found $chapter_count chapters (handbook suggests 6 for interim)"
elif [ "$chapter_count" -gt 0 ]; then
    fail_msg "Only $chapter_count chapter(s) found (handbook suggests 6 for interim)"
else
    fail_msg "No chapters detected — headings may not be using \\chapter"
fi

# ============================================================================
# 10. REFERENCES CHECK
# ============================================================================

section_header "10. REFERENCES CHECK"

ref_found=false
for i in $(seq 1 "$total_pages"); do
    first="${actual_first_lines[$i]:-}"
    if echo "$first" | grep -qi "^References"; then
        ref_found=true
        ref_page=$i
        ref_text=$(pdftotext -f "$i" -l "$i" "$PDF_FILE" - 2>/dev/null)

        pass_msg "References section found on page $i"

        # Check for APA-style formatting indicators
        # APA uses: Author, A. B. (Year). Title. Journal, Vol(Issue), pp.
        if echo "$ref_text" | grep -qE '\([0-9]{4}\)'; then
            pass_msg "References appear to use year-in-parentheses (APA style)"
        else
            warn_msg "Could not confirm APA year format (Year) in references"
        fi

        # Count references
        ref_count=$(echo "$ref_text" | grep -cE '\([0-9]{4}[a-z]?\)' || true)
        if [ "$ref_count" -gt 0 ]; then
            note_msg "Approximately $ref_count reference(s) detected"
        fi

        break
    fi
done

if ! $ref_found; then
    fail_msg "No References section found in the PDF"
fi

# ============================================================================
# 11. APPENDICES CHECK
# ============================================================================

section_header "11. APPENDICES CHECK"

appendix_keywords=("Gantt Chart" "Meeting Log" "Turnitin")
appendix_found_count=0

for keyword in "${appendix_keywords[@]}"; do
    found=false
    for i in $(seq 1 "$total_pages"); do
        first="${actual_first_lines[$i]:-}"
        if echo "$first" | grep -qi "$keyword"; then
            pass_msg "Appendix found: \"$keyword\" on page $i"
            found=true
            appendix_found_count=$((appendix_found_count + 1))
            break
        fi
    done
    if ! $found; then
        warn_msg "Appendix not found for: \"$keyword\""
    fi
done

echo ""
if [ "$appendix_found_count" -ge 3 ]; then
    pass_msg "All 3 expected appendices found"
elif [ "$appendix_found_count" -ge 1 ]; then
    warn_msg "Only $appendix_found_count of 3 expected appendices found"
else
    fail_msg "No appendices found"
fi

# ============================================================================
# 12. CLS FILE CHECKS (if provided)
# ============================================================================

if $HAS_CLS; then
    section_header "12. CLASS FILE ANALYSIS ($CLS_FILE)"

    subsection_header "Margins"
    for margin_check in "left=38mm" "right=28mm" "top=28mm" "bottom=28mm"; do
        if grep -q "$margin_check" "$CLS_FILE"; then
            pass_msg "CLS specifies: $margin_check"
        else
            fail_msg "CLS missing margin spec: $margin_check"
        fi
    done

    subsection_header "Font sizes"
    if grep -q 'fontsize{14}' "$CLS_FILE"; then
        pass_msg "Chapter heading: 14pt found"
    else
        fail_msg "Chapter heading 14pt not found in CLS"
    fi

    if grep -q 'fontsize{12}' "$CLS_FILE"; then
        pass_msg "Section heading: 12pt found"
    else
        fail_msg "Section heading 12pt not found in CLS"
    fi

    if grep -q 'bfseries' "$CLS_FILE"; then
        pass_msg "Bold headings (bfseries) configured"
    else
        fail_msg "Bold headings (bfseries) not found"
    fi

    subsection_header "Line spacing"
    if grep -q 'onehalfspacing' "$CLS_FILE"; then
        pass_msg "1.5 line spacing (onehalfspacing) set"
    else
        fail_msg "onehalfspacing not found"
    fi

    if grep -q 'singlespacing' "$CLS_FILE" && grep -q 'tabular' "$CLS_FILE"; then
        pass_msg "Single spacing for tables configured"
    else
        warn_msg "Single spacing for tables not clearly configured"
    fi

    subsection_header "Paragraph indent"
    if grep -q '12.7mm' "$CLS_FILE"; then
        pass_msg "Paragraph indent 12.7mm specified"
    else
        fail_msg "Paragraph indent 12.7mm not found"
    fi

    subsection_header "Page numbering"
    if grep -q 'pagenumbering{roman}' "$CLS_FILE"; then
        pass_msg "Roman numeral page numbering for preliminaries"
    else
        fail_msg "Roman numeral preliminary page numbering not found"
    fi

    if grep -q 'pagenumbering{arabic}' "$CLS_FILE"; then
        pass_msg "Arabic numeral page numbering for main matter"
    else
        fail_msg "Arabic numeral main matter page numbering not found"
    fi

    subsection_header "Figure/Table numbering"
    if grep -q 'counterwithin{figure}{chapter}' "$CLS_FILE"; then
        pass_msg "Figure numbering: chapter.sequential"
    else
        fail_msg "Figure chapter-based numbering not configured"
    fi

    if grep -q 'counterwithin{table}{chapter}' "$CLS_FILE"; then
        pass_msg "Table numbering: chapter.sequential"
    else
        fail_msg "Table chapter-based numbering not configured"
    fi

    subsection_header "Caption formatting"
    if grep -q 'labelsep=colon' "$CLS_FILE"; then
        pass_msg "Caption separator: colon"
    else
        warn_msg "Caption colon separator not found"
    fi

    subsection_header "TOC formatting"
    if grep -q 'cftdotfill' "$CLS_FILE"; then
        pass_msg "TOC dot leaders configured"
    else
        warn_msg "TOC dot leaders not configured"
    fi

    subsection_header "Required pages"
    for cmd in "makecoverpage" "maketitlepage" "makecopyrightpage" "makedeclarationpage"; do
        if grep -q "$cmd" "$CLS_FILE"; then
            pass_msg "Command \\$cmd defined"
        else
            fail_msg "Command \\$cmd NOT defined"
        fi
    done

    for env in "acknowledgements" "abstract" "listofabbreviations" "listofappendices"; do
        if grep -q "$env" "$CLS_FILE"; then
            pass_msg "Environment {$env} defined"
        else
            fail_msg "Environment {$env} NOT defined"
        fi
    done

    subsection_header "Pandoc/Quarto override protection"
    if grep -q 'AddToHook{begindocument' "$CLS_FILE" || grep -q 'AtBeginDocument' "$CLS_FILE"; then
        pass_msg "Post-Pandoc override hooks present"
    else
        warn_msg "No AtBeginDocument/AddToHook hooks found — Pandoc may override settings"
    fi

    if grep -q 'parindent.*12.7mm' "$CLS_FILE"; then
        pass_msg "Paragraph indent restored after Pandoc"
    else
        warn_msg "Paragraph indent may be overridden by Pandoc's parskip package"
    fi

    if grep -q 'colorlinks=false' "$CLS_FILE"; then
        pass_msg "Hyperlink colours disabled for formal report"
    else
        warn_msg "colorlinks=false not found — links may appear coloured"
    fi

    if grep -qiE 'Arial|Helvetica|TeX Gyre Heros' "$CLS_FILE"; then
        pass_msg "Font restoration after Pandoc's lmodern configured"
    else
        warn_msg "Font restoration not found — lmodern may override Arial"
    fi
else
    section_header "12. CLASS FILE ANALYSIS"
    note_msg "No CLS file provided — skipping class file checks"
    note_msg "Run: $0 $PDF_FILE fypStandard.cls [paper.tex]"
fi

# ============================================================================
# 13. TEX FILE CHECKS (if provided)
# ============================================================================

if $HAS_TEX; then
    section_header "13. TEX FILE ANALYSIS ($TEX_FILE)"

    subsection_header "Heading level mapping"
    chap_in_tex=$(grep -c '\\chapter{' "$TEX_FILE" || true)
    sec_in_tex=$(grep -c '\\section{' "$TEX_FILE" || true)

    if [ "$chap_in_tex" -gt 0 ]; then
        pass_msg "\\chapter commands found ($chap_in_tex instances) — H1 maps to chapter"
    else
        fail_msg "No \\chapter commands — H1 headings may map to \\section instead"
        note_msg "Add 'top-level-division: chapter' to your Quarto YAML"
    fi

    if [ "$sec_in_tex" -gt 0 ]; then
        pass_msg "\\section commands found ($sec_in_tex instances) — H2 maps to section"
    fi

    subsection_header "TOC placement"
    # Check if TOC appears before or after mainmatter switch
    toc_line=$(grep -n 'tableofcontents' "$TEX_FILE" | head -1 | cut -d: -f1)
    main_line=$(grep -n 'mainmatteraliased\|pagenumbering{arabic}' "$TEX_FILE" | head -1 | cut -d: -f1)

    if [ -n "$toc_line" ] && [ -n "$main_line" ]; then
        if [ "$toc_line" -lt "$main_line" ]; then
            pass_msg "TOC (line $toc_line) appears BEFORE main matter switch (line $main_line) — Roman numbering"
        else
            fail_msg "TOC (line $toc_line) appears AFTER main matter switch (line $main_line) — gets Arabic numbering"
            note_msg "TOC should be in preliminary pages with Roman numerals"
        fi
    elif [ -n "$toc_line" ]; then
        warn_msg "TOC found but no mainmatter switch detected"
    else
        warn_msg "No \\tableofcontents found in .tex file"
    fi

    subsection_header "Pandoc overrides to watch"
    if grep -q 'usepackage{parskip}' "$TEX_FILE"; then
        warn_msg "Pandoc loaded parskip (zeroes \\parindent) — CLS must restore it"
    fi
    if grep -q 'usepackage{lmodern}' "$TEX_FILE"; then
        warn_msg "Pandoc loaded lmodern (overrides font) — CLS must restore Arial"
    fi
    if grep -q 'colorlinks=true' "$TEX_FILE"; then
        warn_msg "Pandoc set colorlinks=true — CLS must override to false"
    fi

else
    section_header "13. TEX FILE ANALYSIS"
    note_msg "No TEX file provided — skipping .tex analysis"
    note_msg "Run: $0 $PDF_FILE fypStandard.cls paper.tex"
fi

# ============================================================================
# 14. MARGIN VERIFICATION (using Python)
# ============================================================================

section_header "14. MARGIN CALCULATION"

if $HAS_CLS; then
    python3 - "$CLS_FILE" "$REQUIRED_LEFT_MM" "$REQUIRED_RIGHT_MM" "$REQUIRED_TOP_MM" "$REQUIRED_BOTTOM_MM" "$MARGIN_TOLERANCE_MM" << 'PYEOF'
import sys
import re

cls_file = sys.argv[1]
req_left = float(sys.argv[2])
req_right = float(sys.argv[3])
req_top = float(sys.argv[4])
req_bottom = float(sys.argv[5])
tolerance = float(sys.argv[6])

GREEN = "\033[0;32m"
RED = "\033[0;31m"
NC = "\033[0m"

# Parse geometry values from CLS file
with open(cls_file, "r") as f:
    content = f.read()

# Find geometry package options
geo_match = re.search(r'\\RequirePackage\[(.*?)\]\{geometry\}', content, re.DOTALL)
if not geo_match:
    print(f"  {RED}FAIL{NC}  Could not find geometry package in CLS file")
    sys.exit(0)

geo_text = geo_match.group(1)

def extract_mm(text, key):
    m = re.search(rf'{key}\s*=\s*(\d+(?:\.\d+)?)\s*mm', text)
    return float(m.group(1)) if m else None

margins = {
    "Left":   (extract_mm(geo_text, "left"),   req_left),
    "Right":  (extract_mm(geo_text, "right"),  req_right),
    "Top":    (extract_mm(geo_text, "top"),     req_top),
    "Bottom": (extract_mm(geo_text, "bottom"),  req_bottom),
}

all_pass = True
for name, (actual, required) in margins.items():
    if actual is None:
        print(f"  {RED}FAIL{NC}  {name} margin: not specified in geometry")
        all_pass = False
    else:
        diff = abs(actual - required)
        if diff <= tolerance:
            print(f"  {GREEN}PASS{NC}  {name} margin: {actual}mm (required: {required}mm, diff: {diff:.1f}mm)")
        else:
            print(f"  {RED}FAIL{NC}  {name} margin: {actual}mm (required: {required}mm, diff: {diff:.1f}mm)")
            all_pass = False

# Compute text area
left = margins["Left"][0] or req_left
right = margins["Right"][0] or req_right
top = margins["Top"][0] or req_top
bottom = margins["Bottom"][0] or req_bottom

text_w = 210 - left - right
text_h = 297 - top - bottom

print()
print(f"  Derived text area: {text_w:.1f}mm x {text_h:.1f}mm")
print(f"  Expected:          {210-req_left-req_right:.1f}mm x {297-req_top-req_bottom:.1f}mm")

if all_pass:
    print(f"\n  {GREEN}PASS{NC}  All margin checks passed (tolerance: {tolerance}mm)")
PYEOF
else
    note_msg "Provide the CLS file to verify margin geometry values"
    note_msg "Run: $0 $PDF_FILE fypStandard.cls"
fi

# ============================================================================
# 15. FULL TEXT DUMP (optional — for manual review)
# ============================================================================

section_header "15. QUICK CONTENT SCAN"

subsection_header "Preliminary pages summary"

prelim_names=("Cover" "Title" "Copyright" "Declaration" "Acknowledgements" "Abstract")
for i in $(seq 1 6); do
    if [ "$i" -le "$total_pages" ]; then
        first="${actual_first_lines[$i]:-}"
        word_count=$(pdftotext -f "$i" -l "$i" "$PDF_FILE" - 2>/dev/null | wc -w)
        printf "  Page %d (%s): %d words | %s\n" "$i" "${prelim_names[$((i-1))]}" "$word_count" "$first"
    fi
done

subsection_header "Chapter pages word count"

for i in $(seq 1 "$total_pages"); do
    first="${actual_first_lines[$i]:-}"
    if echo "$first" | grep -qE "^CHAPTER [0-9]"; then
        word_count=$(pdftotext -f "$i" -l "$i" "$PDF_FILE" - 2>/dev/null | wc -w)
        printf "  Page %d: %d words | %s\n" "$i" "$word_count" "$first"
    fi
done

# ============================================================================
# FINAL SUMMARY
# ============================================================================

section_header "VERIFICATION SUMMARY"

echo ""
printf "  ${GREEN}PASSED:${NC}   %d\n" "$pass_count"
printf "  ${RED}FAILED:${NC}   %d\n" "$fail_count"
printf "  ${YELLOW}WARNINGS:${NC} %d\n" "$warn_count"
printf "  ${CYAN}NOTES:${NC}    %d\n" "$note_count"
echo ""

total_checks=$((pass_count + fail_count))
if [ "$total_checks" -gt 0 ]; then
    pass_pct=$((pass_count * 100 / total_checks))
    printf "  Score: %d/%d checks passed (%d%%)\n" "$pass_count" "$total_checks" "$pass_pct"
fi
echo ""

if [ "$fail_count" -eq 0 ]; then
    printf "  ${GREEN}${BOLD}RESULT: ALL CHECKS PASSED${NC}\n"
    echo ""
    echo "  Your PDF appears to comply with the FYP Handbook formatting requirements."
    echo "  However, always do a final visual inspection in a PDF viewer for:"
    echo "    - Page number positions (bottom centre, 15-20mm from edge)"
    echo "    - Proper paragraph indentation (12.7mm)"
    echo "    - Justified text alignment"
    echo "    - Figure/table caption placement (below figures, above tables)"
    echo "    - Line spacing (1.5 for body, single for tables)"
    echo ""
elif [ "$fail_count" -le 3 ]; then
    printf "  ${YELLOW}${BOLD}RESULT: MOSTLY COMPLIANT — %d issue(s) to fix${NC}\n" "$fail_count"
    echo ""
else
    printf "  ${RED}${BOLD}RESULT: NON-COMPLIANT — %d issue(s) need attention${NC}\n" "$fail_count"
    echo ""
fi

echo "  Visual checks you should still do manually:"
echo "    1. Open the PDF and check page numbers are at bottom centre"
echo "    2. Verify paragraph text is indented (12.7mm) on second paragraph onward"
echo "    3. Confirm body text is justified (even left and right edges)"
echo "    4. Check that chapter titles are centred and bold"
echo "    5. Verify 1.5 line spacing in body text"
echo "    6. Confirm cover/title pages have NO visible page number"
echo ""

exit "$fail_count"
