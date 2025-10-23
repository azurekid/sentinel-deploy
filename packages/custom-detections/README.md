This folder contains sample Defender XDR custom detection and hunting artifacts.

Place custom detection YAML and advanced hunting files here. The `scripts/deploy_defenderxdr_artifacts.sh` helper will look for `*.yaml`/`*.yml` files and prepare them for deployment.

Notes:
- This repository contains a placeholder deploy script. For full automation you will need a tool or script that converts your YAML to the correct ARM template or calls Microsoft Graph APIs to create custom detections and hunting queries in Defender XDR.
- See `DEPLOYMENT-GUIDE.md` for guidance and manual steps.
