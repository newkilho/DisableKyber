### Key Features
- **Disable TLS 1.3 Hybrid Kyber Support**: Disables TLS 1.3 Hybrid Kyber encryption support in Google Chrome, Microsoft Edge, and Naver Whale browsers.
- **Check Browser Support Status**: Checks the current status of TLS 1.3 Hybrid Kyber support for each browser and prints the result to the console.

### How to Use
1. **Standard Usage**:  
   Run the program, and it will search for the settings file for Chrome, Edge, and Whale browsers to check the status of TLS 1.3 Hybrid Kyber encryption.
   - If Kyber support is enabled, it will disable it.
   - The current Kyber status for each browser is displayed as either `Default`, `Enabled`, or `Disabled`.

2. **Command-line Options**:  
   You can use `/enable` or `/disable` options when running the program in the command line:
   - `/enable`: Enables Kyber support without displaying any menu, then exits.
   - `/disable`: Disables Kyber support without displaying any menu, then exits.

Example usage:
```shell
DisableKyber.exe /enable
DisableKyber.exe /disable
```

This allows you to automate the enabling or disabling of Kyber support without manual intervention.