# NSO Docker & Debug

NSO Docker container with VSCode debugger integration for Python package

## Getting Started

Before running any make target, make sure you satisfy the prerequisites listed below:

### Prerequisites

1. Download and place the NSO installation file (*installer.bin) under the ```nso-install-files``` directory
2. Place your packages under the ```packages``` directory (optional)
3. Set values in ```config.env```. Example:
    ```sh
    NSO_INSTALL_FILE=nso-5.6.5.linux.x86_64.installer.bin
    DEBUG_PACKAGE=my_package (optional)
    ```
4. Add Python package dependencies under ```requirements.txt``` (optional)
5. Add required NSO config under ```nso_config.xml``` (optional)

## Running

* ```make start```:
    Deploy you custom NSO Docker container setup
* ```make clean```:
    Remove containers and images
* ```make reload-package```:
    Reload the package selected as ```DEBUG_PACKAGE```, in the NSO
* ```make shell```:
    Enter the NSO CLI
* ```NAME=<name of your new package> make package```:
    Create a new package for ```NSO_INSTALL_FILE``` NSO version with a name of your choosing under ```packages```

## VSCode debugging

The debugger used is the Microsoft [debugpy](https://github.com/microsoft/debugpy) debugger. Breakpoints in the code may be introduced with the following statement:
```python
import debugpy; debugpy.breakpoint()
```
In VSCode:
1. Enter the "Run & Debug" mode from the Activity Bar on the left hand side by default
2. Make sure you're in the directory where ```.vscode``` is in (the dropdown "Start Debugging" menu, should read "NSO Remote Attach")
3. Choose "Start Debugging" once your container is up and running 
4. Typically, breakpoints are placed in the service/ action callback body. In this case, requesting the action be run, or the service be commited or dry-run commited, will halt your code at the breakpoints you've previously defined and allow you to debug in VSCode

### Debugging remotely
If running on a remote host, the only change required, assuming port 55678 is not blocked, would be changing the ```"host"``` value in ```.vscode/launch.json``` to that of the remote host
