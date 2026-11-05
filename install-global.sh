#!/usr/bin/env bash
# Installe le kit de routage modèle/effort pour TOUS les projets (~/.claude).
# Usage : ./install-global.sh        (depuis la racine du dépôt)
# Sûr : sauvegarde ce qu'il remplace, ne duplique jamais la section CLAUDE.md,
# et ne touche pas à un "model" déjà défini dans settings.json.
set -euo pipefail

SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEST="${CLAUDE_HOME:-$HOME/.claude}"
STAMP="$(date +%Y%m%d-%H%M%S)"
MARK="# Routage des tâches (économie de tokens)"

for f in .claude/agents CLAUDE.md .claude/skills/revue-rapide; do
  [ -e "$SRC/$f" ] || { echo "Erreur : $SRC/$f introuvable." >&2; exit 1; }
done

mkdir -p "$DEST/agents" "$DEST/skills"

backup() { # sauvegarde un fichier/dossier existant avant de l'écraser
  if [ -e "$1" ]; then cp -a "$1" "$1.bak-$STAMP"; echo "  sauvegarde : $1.bak-$STAMP"; fi
}

echo "Agents..."
for a in "$SRC"/.claude/agents/*.md; do
  t="$DEST/agents/$(basename "$a")"
  if [ -e "$t" ] && ! cmp -s "$a" "$t"; then backup "$t"; fi
  cp "$a" "$t"
done

echo "Skill revue-rapide..."
if [ -d "$DEST/skills/revue-rapide" ] && ! diff -rq "$SRC/.claude/skills/revue-rapide" "$DEST/skills/revue-rapide" >/dev/null; then
  backup "$DEST/skills/revue-rapide"
fi
rm -rf "$DEST/skills/revue-rapide"
cp -r "$SRC/.claude/skills/revue-rapide" "$DEST/skills/revue-rapide"

echo "CLAUDE.md..."
if [ -f "$DEST/CLAUDE.md" ] && grep -qF "$MARK" "$DEST/CLAUDE.md"; then
  echo "  section de routage déjà présente, rien à faire."
else
  [ -f "$DEST/CLAUDE.md" ] && backup "$DEST/CLAUDE.md"
  { [ -s "$DEST/CLAUDE.md" ] && printf '\n'; cat "$SRC/CLAUDE.md"; } >> "$DEST/CLAUDE.md"
  echo "  section de routage ajoutée."
fi

echo "settings.json..."
S="$DEST/settings.json"
if [ ! -f "$S" ]; then
  printf '{\n  "model": "sonnet"\n}\n' > "$S"
  echo "  créé avec model=sonnet."
elif grep -q '"model"' "$S"; then
  echo "  un modèle est déjà défini, non modifié (vérifiez qu'il vous convient)."
elif command -v python3 >/dev/null 2>&1; then
  backup "$S"
  python3 -I - "$S" <<'PY'
import json, sys
p = sys.argv[1]
with open(p, encoding="utf-8") as f:
    d = json.load(f)
d["model"] = "sonnet"
with open(p, "w", encoding="utf-8") as f:
    json.dump(d, f, indent=2, ensure_ascii=False); f.write("\n")
PY
  echo "  model=sonnet ajouté."
else
  echo "  python3 absent : ajoutez manuellement \"model\": \"sonnet\" dans $S"
fi

echo
echo "Terminé. Relancez Claude Code puis tapez /agents pour vérifier."
