# xilinx-dev-tools
It is a tooling for Xilinx build environment, setting up workspace, building and stuff.  
  
- This flow simplifies the process of building Vitis workspace for Xilinx devices. It is designed to be used with Xilinx Vitis 2023.2. Hardcoded currently.  
- In order to use it replace the path to your Vitis installation in the scripts/setup.sh and scripts/build.sh files.  

# Usage
```bash
chmod +x scripts/setup.sh
chmod +x scripts/build.sh

# setup workspace and build
./scripts/setup.sh xsa/design_1_wrapper.xsa build/vitis_workspace

# build workspace
./scripts/build.sh build/vitis_workspace
