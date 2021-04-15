Script to help sign out of tree kernel modules on a fedora system, but likely easily ported to other systems.
 
Fuzzy finder (fzf) is used to allow user to select from any of the install kernel versions on the system.  This is useful to select a new kernel after a dnf upgrade.

## Dependencies
`dnf install fzf`

## How to use

- Run setup to generate MOK key
`setup_mok_keys.sh`
- Enroll Mok key.  To finish the import a reboot is required.  UEFI will ask for a password at boot time. Once the import has finished you can sign and load kernel modules at runtime.
- Sign kernel modules

## Sign modules for a specific kernel version

`./sign_fedora.sh`
