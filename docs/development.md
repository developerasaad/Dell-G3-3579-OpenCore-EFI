# Development and Debugging

I worked on this configuration using a Dell G3 3579 with Windows, macOS Sonoma, and
macOS Sequoia installed separately.

Sonoma was already working, which made it useful as a recovery and debugging
environment while configuring Sequoia.

One of the more difficult issues involved the internal display. Sequoia could boot,
but the screen would remain almost completely dark for several minutes. Since I
couldn't reliably use the desktop immediately after boot, collecting logs manually
wasn't practical.

I worked around this by preparing diagnostic scripts from Sonoma and configuring
them to run automatically in Sequoia through macOS services. This made it possible
to capture startup information without depending on the display being usable, then
inspect the results from Sonoma.

The exact scripts, service configuration, and setup procedure are documented in
[Cross-OS Automatic Logging](debugging/cross-os-automatic-logging.md).

I also used AI-assisted tools throughout development for hardware research,
OpenCore configuration analysis, script development, and troubleshooting. I checked
recommendations against documentation and available logs, and used actual hardware
testing to determine what worked.

The Sonoma and Sequoia configurations are maintained separately because their
requirements and behavior are not necessarily identical, even on the same laptop.
