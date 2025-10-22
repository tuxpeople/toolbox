#!/usr/bin/env bash
# sanitize_text.sh
# Nutzung:
#   ./sanitize_text.sh INPUT [OUTPUT]
# Schreibt standardmäßig nach INPUT.cleaned.txt, falls OUTPUT nicht angegeben ist.

set -euo pipefail

if [[ $# -lt 1 || $# -gt 2 ]]; then
  echo "Usage: $0 INPUT [OUTPUT]" >&2
  exit 1
fi

infile="$1"
if [[ ! -f "$infile" ]]; then
  echo "Input file not found: $infile" >&2
  exit 1
fi

# Standard-Ausgabedatei: <name>.cleaned.txt (Dateiendung wird entfernt, falls vorhanden)
base="${infile##*/}"
stem="${base%.*}"
outfile="${2:-${infile%/*}/${stem}.cleaned.txt}"
# Falls infile keinen Slash enthält, obiges ergibt /stem.cleaned.txt — auffangen:
if [[ "$infile" != */* ]]; then
  outfile="${2:-${stem}.cleaned.txt}"
fi

python3 - <<'PY' "$infile" "$outfile"
import sys, unicodedata, re, io, os

inf, outf = sys.argv[1], sys.argv[2]

def replace_special_spaces(s: str) -> str:
    # Verschiedene Space-Varianten -> normales Space
    space_like = {
        "\u00A0",  # NBSP
        "\u202F",  # NARROW NBSP
        "\u2007",  # FIGURE SPACE
        "\u2008",  # PUNCTUATION SPACE
        "\u2009",  # THIN SPACE
        "\u200A",  # HAIR SPACE
        "\u2002", "\u2003", "\u2004", "\u2005", "\u2006",  # EN/EM/THREE-PER-EM etc.
        "\u205F",  # MEDIUM MATHEMATICAL SPACE
        "\u3000",  # IDEOGRAPHIC SPACE
        "\u180E",  # MONGOLIAN VOWEL SEPARATOR (als Space behandeln)
        "\u2000", "\u2001",  # weitere Spaces
    }
    for ch in space_like:
        s = s.replace(ch, " ")
    return s

def map_typography(s: str) -> str:
    # Smarte Quotes / Striche -> ASCII
    replacements = {
        "\u2018": "'", "\u2019": "'", "\u201A": "'", "\u201B": "'",
        "\u201C": '"', "\u201D": '"', "\u201E": '"', "\u00AB": '"', "\u00BB": '"',
        "\u2032": "'", "\u2033": '"',
        "\u2013": "-", "\u2014": "-", "\u2212": "-",  # en dash, em dash, minus
    }
    return s.translate(str.maketrans(replacements))

# Emojis & relevante Kombinatoren beibehalten
def is_emoji_cp(cp: int) -> bool:
    return (
        0x1F300 <= cp <= 0x1FAFF or  # diverse Emojis/Symbole
        0x1F900 <= cp <= 0x1F9FF or
        0x2600  <= cp <= 0x27BF  or  # Misc symbols, Dingbats
        0x1F1E6 <= cp <= 0x1F1FF or  # Flaggen (Regional Indicators)
        0x1F3FB <= cp <= 0x1F3FF or  # Hauttöne
        cp in (0x200D, 0xFE0F)       # ZWJ & Variation Selector
    )

# Buchstaben mit spezieller Transliteration
special_letter_map = {
    "ß": "ss",
    "Æ": "AE", "æ": "ae",
    "Ø": "O",  "ø": "o",
    "Đ": "D",  "đ": "d",
    "Ł": "L",  "ł": "l",
    "Þ": "Th", "þ": "th",
    "Œ": "OE", "oe": "oe", "Œ": "OE", "œ": "oe",
}

# Häufige Währungen -> ASCII
symbol_map = {
    "€": "EUR", "£": "GBP", "¥": "JPY", "₩": "KRW", "₽": "RUB",
    "₹": "INR", "₿": "BTC", "¢": "c",
}

def ascii_sanitise(text: str) -> str:
    # 1) Unicode-Kompatibilitätsnormalisierung (komponiert i. d. R. zu NFC)
    text = unicodedata.normalize("NFKC", text)
    # 2) Typografie vereinheitlichen
    text = map_typography(text)
    # 3) Spezielle Spaces vereinheitlichen
    text = replace_special_spaces(text)

    out = []
    for ch in text:
        cp = ord(ch)

        # ASCII direkt
        if 0x20 <= cp <= 0x7E or ch in "\n\r\t":
            out.append(ch)
            continue

        # Emojis & relevante Modifikatoren behalten
        if is_emoji_cp(cp):
            out.append(ch)
            continue

        # Währungssymbole & Sondertransliteration
        if ch in symbol_map:
            out.append(symbol_map[ch])
            continue
        if ch in special_letter_map:
            out.append(special_letter_map[ch])
            continue

        # Gängige lateinische Bereiche BEIBEHALTEN (Umlaute/Akzentbuchstaben etc.)
        # Latin-1 Supplement, Latin Extended-A, Latin Extended-B
        if (0x00C0 <= cp <= 0x024F) or ch in ("\u00E4","\u00F6","\u00FC","\u00C4","\u00D6","\u00DC"):
            out.append(ch)
            continue

        # Sonst vereinfachen: Diakritika entfernen und nur ASCII behalten
        nfd = unicodedata.normalize("NFD", ch)
        stripped = "".join(c for c in nfd if unicodedata.category(c) != "Mn")

        ascii_only = []
        for c in stripped:
            if 0x20 <= ord(c) <= 0x7E:
                ascii_only.append(c)
        out.append("".join(ascii_only))
    return "".join(out)

def collapse_spaces_keep_lines(text: str) -> str:
    # Pro Zeile: Mehrfach-Spaces/Tabs -> 1 Space; führende/trailing Spaces entfernen.
    # Zeilenstruktur bleibt erhalten.
    lines = text.splitlines(keepends=False)
    norm = []
    for ln in lines:
        ln = re.sub(r"[ \t]+", " ", ln)
        ln = ln.strip()
        norm.append(ln)
    # ursprünglichen finalen Zeilenumbruch beibehalten (falls vorhanden)
    return "\n".join(norm) + ("\n" if text.endswith(("\n", "\r", "\r\n")) else "")

with io.open(inf, "r", encoding="utf-8", errors="strict") as f:
    raw = f.read()

clean = ascii_sanitise(raw)
clean = collapse_spaces_keep_lines(clean)

with io.open(outf, "w", encoding="utf-8", newline="") as f:
    f.write(clean)

print(f"Wrote cleaned text to: {os.path.abspath(outf)}")
PY

echo "✅ Output: $outfile"
