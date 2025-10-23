#!/usr/bin/env bash
set -euo pipefail

RG="$1"
WORKSPACE="$2"
PACKAGE_PATH="$3"

echo "Deploy helper: RG=${RG}, WORKSPACE=${WORKSPACE}, PACKAGE_PATH=${PACKAGE_PATH}"

if [ ! -d "${PACKAGE_PATH}" ]; then
  echo "Package path does not exist: ${PACKAGE_PATH}"
  exit 0
fi

# Find detection YAMLs or other artifact types
shopt -s nullglob
yaml_files=("${PACKAGE_PATH}"/*.yaml "${PACKAGE_PATH}"/*.yml)

if [ ${#yaml_files[@]} -eq 0 ]; then
  echo "No YAML files found in ${PACKAGE_PATH}. Nothing to deploy."
  exit 0
fi

echo "Found ${#yaml_files[@]} YAML files. Processing..."

for f in "${yaml_files[@]}"; do
  echo "Processing $f"
  # Basic detection: check if file contains 'kind: CustomDetection' or 'type: AdvancedHunting'
  if grep -qi "CustomDetection" "$f" || grep -qi "custom detection" "$f"; then
    echo "Detected custom detection rule. Converting and deploying..."
    # Placeholder conversion: in repo there may be SecureHats/YamlTo-Arm or custom tools
    # If conversion tool exists, call it. Otherwise, call the Microsoft Graph API or az cli (requires additional auth).
    if command -v SecureHats_YamlToArm >/dev/null 2>&1; then
      SecureHats_YamlToArm --input "$f" --output /tmp/deploy.json
      az deployment group create --resource-group "$RG" --template-file /tmp/deploy.json --parameters workspace="$WORKSPACE"
    else
      echo "No conversion tool available. Saving $f to /tmp for manual deployment."
      cp "$f" /tmp/
      echo "Manual steps: convert $f to ARM template or deploy via Microsoft Graph API for Defender XDR custom detections."
    fi
  elif grep -qi "AdvancedHunting" "$f" || grep -qi "Advanced Hunting" "$f"; then
    echo "Detected advanced hunting query. Deploying via Microsoft Graph API (placeholder)."
    # Placeholder: write file to /tmp for manual Graph API upload
    cp "$f" /tmp/
    echo "To deploy advanced hunting queries, use Microsoft Graph Security APIs or MSAL-based script to upload the query as a Detection/Bookmark in Defender XDR."
  else
    echo "Unknown artifact type for $f. Copying to /tmp for inspection."
    cp "$f" /tmp/
  fi
done

echo "Done processing package ${PACKAGE_PATH}."
