#!/bin/bash

# === Configuration ===
BDS_DIR="$HOME/bedrock"
BP_DIR="$BDS_DIR/behavior_packs"
RP_DIR="$BDS_DIR/resource_packs"
MCPACK_DIR="$BDS_DIR/mcpack"
WORLD_NAME="Bedrock level"
WORLD_DIR="$BDS_DIR/worlds/$WORLD_NAME"
MANIFEST_NAME="manifest.json"

# === Utility ===
pause() {
  read -p "Press Enter to continue..."
}

add_to_json() {
  local uuid="$1"
  local version="$2"
  local target_json="$3"

  [ ! -f "$target_json" ] && echo "[]" > "$target_json"

  if jq -e --arg uuid "$uuid" '.[] | select(.pack_id == $uuid)' "$target_json" >/dev/null; then
    echo "⚠️ Already registered. Skipping."
  else
    tmp=$(mktemp)
    jq --arg uuid "$uuid" --argjson version "$version" \
      '. + [{"pack_id": $uuid, "version": $version}]' "$target_json" > "$tmp"
    mv "$tmp" "$target_json"
    echo "✅ Registered: $uuid"
  fi
}

# === Add from mcpack ===
add_from_mcpack() {
  echo "=== Listing mcpack directory ==="
  files=()
  mapfile -t files < <(find "$MCPACK_DIR" -mindepth 1 -maxdepth 1)

  if [ "${#files[@]}" -eq 0 ]; then
    echo "⚠️ No files found in mcpack directory."
    pause
    return
  fi

  for i in "${!files[@]}"; do
    echo "$((i + 1))) $(basename "${files[$i]}")"
  done
  echo "0) Cancel"
  read -p "Select number to add: " index
  [[ "$index" == "0" || -z "$index" ]] && return
  ((index--))

  selected="${files[$index]}"
  name=$(basename "$selected" .zip)
  name=${name%.mcpack}
  DEST="$BDS_DIR/tmp_unpack/$name"
  rm -rf "$DEST"
  mkdir -p "$DEST"

  # Extract
  if [[ -f "$selected" ]]; then
    unzip -o "$selected" -d "$DEST" >/dev/null
  elif [[ -d "$selected" ]]; then
    cp -r "$selected"/* "$DEST"
  fi

  mapfile -t manifest_files < <(find "$DEST" -type f -name "$MANIFEST_NAME")

  if [ "${#manifest_files[@]}" -eq 0 ]; then
    echo "❌ manifest.json not found"
    pause
    return
  fi

  used=()
  while true; do
    echo "== Available manifest.json files =="
    count=0
    for i in "${!manifest_files[@]}"; do
      if [[ " ${used[*]} " =~ " $i " ]]; then continue; fi
      parent_dir=$(basename "$(dirname "${manifest_files[$i]}")")
      echo "$((count + 1))) $parent_dir"
      index_map[$count]=$i
      ((count++))
    done

    if [ "$count" -eq 0 ]; then
      echo "✅ All manifest.json files registered."
      break
    fi

    echo "$((count + 1))) ❌ Exit"
    read -p "Select number to register (or exit): " sel
    [[ -z "$sel" ]] && continue
    ((sel--))

    if [ "$sel" -ge "$count" ]; then
      echo "⏹️ Exiting"
      break
    fi

    manifest="${manifest_files[${index_map[$sel]}]}"
    used+=("${index_map[$sel]}")

    uuid=$(jq -r .header.uuid "$manifest")
    version=$(jq -c .header.version "$manifest")

    echo "Register this pack as:"
    echo "1) Behavior Pack (BP)"
    echo "2) Resource Pack (RP)"
    read -p "Enter choice: " choice
    if [ "$choice" == "1" ]; then
      TARGET_DIR="$BP_DIR"
      TARGET_JSON="$WORLD_DIR/world_behavior_packs.json"
    elif [ "$choice" == "2" ]; then
      TARGET_DIR="$RP_DIR"
      TARGET_JSON="$WORLD_DIR/world_resource_packs.json"
    else
      echo "Invalid selection"
      continue
    fi

    pack_dir=$(dirname "$manifest")
    pack_name=$(basename "$pack_dir")
    final_dest="$TARGET_DIR/$pack_name"

    if [ -e "$final_dest" ]; then
      echo "⚠️ Folder already exists: $final_dest"
      read -p "Overwrite? (y/N): " overwrite
      if [[ ! "$overwrite" =~ ^[yY]$ ]]; then
        echo "⏭️ Skipped."
        continue
      fi
      rm -rf "$final_dest"
    fi

    mv "$pack_dir" "$final_dest"
    add_to_json "$uuid" "$version" "$TARGET_JSON"
    echo "✅ Registered: $pack_name"
    pause
  done

  rm -rf "$DEST"
}

# === Main Loop ===
while true; do
  clear
  echo "==== BDS Add-on Management Script ===="
  echo "1) Add add-on from mcpack"
  echo "2) Register from existing folder"
  echo "3) Remove add-on"
  echo "0) Exit"
  read -p "Enter your choice: " main_choice

  case "$main_choice" in
    1) add_from_mcpack ;;
    # 2) register_from_existing ;; (optional)
    # 3) remove_addon ;; (optional)
    0) exit 0 ;;
    *) echo "Invalid input"; pause ;;
  esac
  echo
done
