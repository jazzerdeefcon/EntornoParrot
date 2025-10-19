#!/bin/sh
# manage_target.sh - Gestiona el fichero target
# Usage: manage_target.sh set <ip> <name> | clear | show

TARGET_DIR="$HOME/.config/bin"
TARGET_FILE="$TARGET_DIR/target"

mkdir -p "$TARGET_DIR"
chmod 700 "$TARGET_DIR"

case "$1" in
  set)
    shift
    ip="$1"
    name="$2"
    if [ -z "$ip" ] || [ -z "$name" ]; then
      echo "Usage: $0 set <ip> <name>"
      exit 1
    fi
    printf "%s %s\n" "$ip" "$name" > "$TARGET_FILE"
    chmod 600 "$TARGET_FILE"
    echo "Target guardado: $ip $name"
    ;;
  clear)
    if [ -f "$TARGET_FILE" ]; then
      : > "$TARGET_FILE"
      echo "Target limpiado."
    else
      echo "No hay target."
    fi
    ;;
  show)
    if [ -f "$TARGET_FILE" ] && [ -s "$TARGET_FILE" ]; then
      cat "$TARGET_FILE"
    else
      echo "No target"
    fi
    ;;
  *)
    echo "Usage: $0 {set|clear|show}"
    exit 2
    ;;
esac
