### CHANGELOG

#### Version 4.14

- New option: change logo

#### Version 4.13

- Script divided into modules
- New option: direct SSH connection to the device

#### Version 4.12

- Added a download tool for EV chargers software

#### Version 4.11

- Added updating of Disp10TC software
- Improved file checking for display languages
- Moved required packages to `packages.txt`

#### Version 4.10

- Changed execution shell from sh to bash
- Updated the process to work with GitLab
- Added progress bars
- Added configuration for Lovato (Daimler)
- Refactored repetitive text into functions
- Fixed language settings for display (again)
- Fixed missing title bars

#### Version 4.9

- Displayed connection status in the main menu

#### Version 4.8

- Added support for Ionity

#### Version 4.7

- Added hyperlinks to the EOS system in the [Ładowarka / main] tab
- Changed hyperlink display style

#### Version 4.6

- Added automatic installation of the cURL package if missing

#### Version 4.5

- Text display improvements

#### Version 4.4

- Improved update downloading

#### Version 4.3

- Improved auto-update functionality

#### Version 4.2

- Exited beta phase

#### Version 4.1b

- Minor update improvements

#### Version 4.0b

- Introduced automatic update checking

#### Version 3.3b

- Updated password encryption algorithm
- Added customization options for program colors (Option 8: Personalizacja)

#### Version 3.2b

- Fixed time synchronization issues
- Added automatic transfer of `attenuation.atn` in the "Satelitka / ext" section
- Added EVSE preview in the "Ładowarka / main" section

#### Version 3.1b

- Added option to set CAN counter speed
- Minor updates
- Added password protection for startup

#### Version 3.0b

- Introduced demo carousel option for the display
- Added early developer options (password-protected)
- Enabled module integration into the configuration process
- Added CAN transmitter monitoring option
- Fixed an issue ensuring the existence of the `languages.json` file
- Generalized menu layout
  - Restart mapped to key R
  - Unified return and exit options under keys 0 and 00 respectively
  - Reordered some items

#### Version 2.3b

- Code improvements
- Minor updates

#### Version 2.2b

- [BETA] Added router configuration options
- Enhanced code functionality

#### Version 2.1b

- Added support for transferring the `attenuation.atn` file in the "Ładowarka / main" section
- Minor updates

#### Version 2.0b

- Added the ability to adjust voltage and current in testers
- Introduced language options in the display (primary language change, sorting, adding, and removing languages)

#### Version 1.6b

- Option to create a desktop program shortcut
- Minor updates
- Changed date formatting

#### Version 1.5b

- Menu now shows option paths instead of connection status
- Renamed the program window

#### Version 1.4b

- Automated SSH fingerprint addition
- Displayed current tester values in the menu
- Code optimization
- Tester exited WIP phase

#### Version 1.3b

- Added a submenu for satellites / ext
- Introduced a counter for device name changes
- Updated the wording of some messages
- Added an option to modify the tester charge indicator (SoC)

#### Version 1.2b

- Added the ability to change colors in the source code
- Highlighted internal sections in the source code
- Improved connection checking

#### Version 1.1b

- Added a "Ładowarka / main" submenu, allowing data checks, renaming, service restarts, and device restarts

#### Version 1.0b

- Added options for charger tester configuration
- Enabled returning to the previous option window

#### Version 0.2b

- Added colors to the script
- Continued work on tester tools
- Exit via [0] key
- Added a few error messages
- Enabled skipping QP changes
