
#  BDS Add-on Management Script

This is a Bash script for managing **Add-ons (Behavior Packs / Resource Packs)** for Bedrock Dedicated Server (BDS).  
It helps you easily add, register, or remove add-ons from your BDS worlds.

---

##  Default Directory Structure

```plaintext
~/bedrock/
├── behavior_packs/
├── resource_packs/
├── mcpack/               ← Place your .mcpack or .zip files here
├── tmp_unpack/           ← Temporary extraction folder (auto-generated)
└── worlds/
    └── Bedrock level/    ← World name
        ├── world_behavior_packs.json
        └── world_resource_packs.json
````

---

##  How to Use

Run the script in your terminal:

```bash
./addon_manager.sh
```

You will see a menu like this:

```
==== BDS Add-on Management Script ====
1) Add add-on from mcpack
2) Register add-on from existing folder
3) Remove add-on
0) Exit
```

---

## Environment Variable Customization

You can modify the following variables at the top of the script to fit your environment:

```bash
# === Configuration ===
BDS_DIR="$HOME/bedrock"           # Root directory of your BDS setup
BP_DIR="$BDS_DIR/behavior_packs"  # Directory for behavior packs
RP_DIR="$BDS_DIR/resource_packs"  # Directory for resource packs
MCPACK_DIR="$BDS_DIR/mcpack"      # Folder containing .mcpack or .zip files
WORLD_NAME="Bedrock level"        # Target world name (folder name)
WORLD_DIR="$BDS_DIR/worlds/$WORLD_NAME" # World directory
MANIFEST_NAME="manifest.json"     # Add-on metadata file name
```

### Example: Change your world folder or directory paths

```bash
BDS_DIR="/home/ubuntu/minecraftbe"
WORLD_NAME="MyWorld"
```

After making changes, save the script and rerun it.

---

## Features

### 1. Add Add-on from mcpack

* Browse and extract `.mcpack` or `.zip` files from the `mcpack/` directory.
* Automatically detects `manifest.json` and allows registration of each pack.
* You can choose whether it's a **Behavior Pack** or **Resource Pack**.
* UUID and version are automatically added to `world_behavior_packs.json` or `world_resource_packs.json`.

---

### 2. Register from Existing Folder

* If your add-ons are already unpacked in `behavior_packs/` or `resource_packs/`, this option registers them to the world.
* Official packs like `vanilla`, `preview`, etc., are excluded to avoid accidental edits.

---

### 3. Remove Add-on

* Select a registered add-on and remove its entry from the JSON config file.
* Optionally, delete the actual folder from disk.
* Only user-installed add-ons are shown; official ones are excluded.

---

##  Required Tools

The script relies on the following command-line tools:

* `jq` – for handling JSON files
* `unzip` – for extracting `.mcpack` and `.zip` files

To install required tools:

```bash
sudo apt install jq unzip
```

---

## FAQ

### Q. My `.mcpack` is not working / `manifest.json` not found?

→ Ensure the `.mcpack` is a valid `.zip` archive and contains a proper `manifest.json` file in the expected directory structure.

### Q. Add-on doesn't load in the world?

→ Some add-ons require experimental gameplay to be enabled. Also, check if the UUID is correctly added in `world_behavior_packs.json`.

---

## License

MIT License — You are free to use, modify, and distribute this script at your own risk.

---

## Support

For bug reports or feature requests, feel free to open an issue or submit a pull request.
