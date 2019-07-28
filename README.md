# Global overview

This is my (Sébounet!) environement configuration repository. Everything means to be as automatic as
possible and as unix platform independent as possible (mac and linux supported but not windows !)

Furthermore, git submodules are used as most as possible in order to maintain updated tools as must
as possible

# Architecture

The architecture respect the following paradigm :

    <environment_root>
         |
         +--- install.sh
         |
         +--- local
         |     |
         |     +----- bin
         |     |
         |     +----- include
         |     |
         |     +----- lib
         |     |
         |     +----- ...
         |
         +--- src
         |     |
         |     +----- configuration
         |     |
         |     +----- scripts
         |     |
         |     +----- system
         |     |
         |     +----- ...

-   **install.sh** contains the installation process
-   **local** contains the local environment. It is a replicate of the /usr linux architecture
-   **src** contains all submodules or dedicated source kit. In order to add a new tool you need to
    create a dedicated directory which contains :
    -   **install.sh** for the dedicated installation procedure
    -   **<directory>** which contains the submodule of the dedicated tool or a specific source directory
        if there is not any submodule available

Two specific directories are also present :
-   **src/configuration** contains all the dedicated configuration part
-   **src/00-system** contains system dedicated configuration like package installation,&#x2026;
-   **src/scripts** contains useful scripts

# Current status

1.  List of current supported tools
    -   emacs
    -   colorgcc
    -   inkscapeslide
    -   mu
    -   eclim
    -   oh-my-zsh

2.  List of current supported systems
    -   macos (maverick, yosemite)
    -   ubuntu
