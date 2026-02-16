#!/usr/bin/env bash
set -euo pipefail

# Validate marketplace and plugin structure.
# Used by CI (.github/workflows/validate.yml) and the pre-commit hook.

cd "$(git rev-parse --show-toplevel)"

ERRORS=0

# --- Marketplace catalog ---

if [ ! -f ".claude-plugin/marketplace.json" ]; then
  echo "Error: .claude-plugin/marketplace.json not found"
  exit 1
fi

if ! jq empty .claude-plugin/marketplace.json 2>/dev/null; then
  echo "Error: .claude-plugin/marketplace.json is not valid JSON"
  exit 1
fi

# --- Check for unregistered plugins ---

REGISTERED_SOURCES=$(jq -r '.plugins[].source' .claude-plugin/marketplace.json)

for DIR in plugins/*/; do
  [ -d "$DIR" ] || continue
  RELATIVE="./$(echo "$DIR" | sed 's:/$::')"
  if ! echo "$REGISTERED_SOURCES" | grep -qxF "$RELATIVE"; then
    echo "Error: plugin directory '$DIR' exists on disk but is not registered in marketplace.json"
    ERRORS=$((ERRORS + 1))
  fi
done

# --- Plugins ---

PLUGINS=$(jq -r '.plugins[].source' .claude-plugin/marketplace.json)

for SOURCE in $PLUGINS; do
  PLUGIN_DIR="${SOURCE#./}"
  PLUGIN_NAME=$(jq -r ".plugins[] | select(.source == \"$SOURCE\") | .name" .claude-plugin/marketplace.json)
  PLUGIN_ERRORS=0

  echo "Validating plugin: $PLUGIN_NAME ($PLUGIN_DIR)"

  # Check plugin source directory exists
  if [ ! -d "$PLUGIN_DIR" ]; then
    echo "  Error: plugin directory '$PLUGIN_DIR' not found (listed in marketplace.json but missing on disk)"
    ERRORS=$((ERRORS + 1))
    continue
  fi

  # Check plugin.json exists
  if [ ! -f "$PLUGIN_DIR/.claude-plugin/plugin.json" ]; then
    echo "  Error: $PLUGIN_DIR/.claude-plugin/plugin.json not found"
    ERRORS=$((ERRORS + 1))
    continue
  fi

  # Validate plugin.json is valid JSON
  if ! jq empty "$PLUGIN_DIR/.claude-plugin/plugin.json" 2>/dev/null; then
    echo "  Error: $PLUGIN_DIR/.claude-plugin/plugin.json is not valid JSON"
    ERRORS=$((ERRORS + 1))
    continue
  fi

  # Check required fields
  for FIELD in name description version; do
    VALUE=$(jq -r ".$FIELD // empty" "$PLUGIN_DIR/.claude-plugin/plugin.json")
    if [ -z "$VALUE" ]; then
      echo "  Error: missing required field '$FIELD' in plugin.json"
      ERRORS=$((ERRORS + 1))
      PLUGIN_ERRORS=$((PLUGIN_ERRORS + 1))
    fi
  done

  # Check that declared component directories exist
  for COMPONENT in commands skills agents hooks; do
    if jq -e ".$COMPONENT" "$PLUGIN_DIR/.claude-plugin/plugin.json" > /dev/null 2>&1; then
      COMPONENT_VALUE=$(jq -r ".$COMPONENT" "$PLUGIN_DIR/.claude-plugin/plugin.json")
      # Handle both string and array values
      if jq -e ".$COMPONENT | type == \"array\"" "$PLUGIN_DIR/.claude-plugin/plugin.json" > /dev/null 2>&1; then
        DIRS=$(jq -r ".$COMPONENT[]" "$PLUGIN_DIR/.claude-plugin/plugin.json")
      else
        DIRS="$COMPONENT_VALUE"
      fi
      for DIR in $DIRS; do
        FULL_PATH="$PLUGIN_DIR/${DIR#./}"
        if [ ! -d "$FULL_PATH" ]; then
          echo "  Error: declared $COMPONENT directory '$FULL_PATH' not found"
          ERRORS=$((ERRORS + 1))
          PLUGIN_ERRORS=$((PLUGIN_ERRORS + 1))
        fi
      done
    fi
  done

  if [ $PLUGIN_ERRORS -eq 0 ]; then
    echo "  OK"
  fi
done

if [ $ERRORS -gt 0 ]; then
  echo ""
  echo "Validation failed with $ERRORS error(s)"
  exit 1
fi

echo ""
echo "All plugins validated successfully"
