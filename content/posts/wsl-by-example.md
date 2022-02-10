+++
title = "WSL2 Tips: By Example: A Cheatsheet"
tags = []
date = "2021-02-01"
draft = true
+++

# Installing

Install WSL2 via these instructions: https://docs.microsoft.com/en-us/windows/wsl/install#install - installing is as simple as `wsl --install` if you're lucky; read that article if you're not lucky.

# wsl.exe usage

WSL2 is manipulated via wsl.exe.

```powershell
# start default distro and launch shell
wsl

# list - useful if you installed both 'ubuntu' and 'ubuntu-20.04' - whoops - anyway if so, get rid of one
wsl --list

# shutdown - frees memory and (more useful) sometimes fixes my weird DNS issues
wsl --shutdown

# both   --exec   and   --   run a command
wsl --exec echo "I'm in unix! PowerShell version: $($PSVersionTable.PSVersion) (evaluated in PowerShell)"
wsl -- ls -al


# SUBTLE DIFFERENCE BELOW - PAY ATTENTION:

# this echoes back      WSL distro: Ubuntu-20.04
wsl -- echo "WSL distro: `${WSL_DISTRO_NAME}"

# this echoes back      WSL Distro: ${WSL_DISTRO_NAME}
wsl --exec echo "WSL Distro: `${WSL_DISTRO_NAME}"
```

# Surprisingly useful WSL tips

To be clear, the following commands are run from `bash` in my WSL2 instance, not from a Windows shell. While many `.exe` programs may be run from WSL, I find the following surprisingly (and uniquely) useful in WSL2:

```bash
# launch Windows Explorer here
cmd.exe /c start .

# pipe directly to the Windows clipboard
echo "${WSL_DISTRO_NAME}" | clip.exe
```

# Accessing files

From Windows:

- `\\wsl$` - access files from WSL distros
- `\\wsl$\Ubuntu-20.04\home\p\.bashrc` - my bashrc (note everything after `\\wsl$\Ubuntu-20.04` is the Ubuntu filesystem)
- `cd \\wsl$\Ubuntu-20.04` works in PowerShell, but DOS can't see it (not even via `net use`). And that's okay. DOS can slowly die and nobody will mourn. RIP DOS. RIP. But die already.

From Linux:

Windows drives are mounted to `/mnt/<driveletter>`.

`mount` shows WSL2's special mounts:

```bash
> mount
C:\ on /mnt/c type drvfs (rw,noatime,uid=1000,gid=1000,case=off)
D:\ on /mnt/d type drvfs (rw,noatime,uid=1000,gid=1000,case=off)
# ...
# boring parts redacted
# ...
```

So, reference Windows files and paths, do something like e.g. `ls -al /mnt/c/Users/p/Desktop`.

Windows paths from WSL are case-sensitive.

# VS Code

VS Code (running in Windows) seamlessly edits files in WSL2. `code .` loads the current directory into VS Code.

# Accessing WSL From Windows Terminal

I launch the Ubuntu 20.04 shell with `CTRL` + `SHIFT` + `2`. Windows Terminal is highly configurable, so your experience may vary.

You can (if desired) set WSL as the default Profile for Windows Terminal.

# WSL: Turning it off and on again

These are the Baby Bear, Mama Bear, and Papa Bear of WSL troubleshooting options. (We don't talk about the Reboot-Windows Bear.)

- `wsl --terminate Ubuntu-20.04`
- `wsl --shutdown`
- `get-service | ? { $_.displayname -like "*hyper*" -and $_.status -eq "Running" } | restart-service`
- reboot (sorry)

# WSL2 file operations are slower

Be aware. I usually don't notice.

# WSL2 uses RAM

If you're running WSL on a Windows OS with only 16GB of RAM, consider upgrading to 32GB. With 16GB, you're likely using all your RAM and relying on swap.

WSL2 appears as `Vmmem` in Task Manager. Ubuntu 20.04 on my machine is currently using just under 2GB of RAM.

To check your available RAM, look at Performance->Memory in Task Manager.

# Line endings

Git for Windows is probably checking out files with CRLF line endings (the specifics are configurable and way too boring for me to explain - go read https://docs.github.com/en/get-started/getting-started-with-git/configuring-git-to-handle-line-endings). For most of us, if you commit files in Windows, push to GitHub, and pull them down in WSL, the line endings are LF in Linux and CRLF in Windows, which is probably the desired behavior. However, if you're moving files between Linux and Windows manually, consider several solutions:

- `dos2unix` to manually convert a file from LF to CRLF from inside WSL
- Manually load and change line endings in your text editor. E.g. in VS Code in the status bar, it will say LF or CRLF. You can change this by clicking on the LF (or CRLF) indicator in the status bar. Or change it by running `>Change End of Line Sequence` from the Command Palette.
- via `.gitattributes` in specific repos, always checkout some files (e.g. shell scripts) as LF
- via `.gitattributes` in specific repos, always checkout all files as LF
- via `git config --global core.autocrlf`
- via `git config --global core.eol`
