+++
title = "WSL2 Tips: By Example: A Cheatsheet"
tags = []
date = "2021-02-01"
draft = true
+++

###### Spicy Peppers Rating System: [🚫 | Mild and Nutritious; Blandly Educational ]

## How is WSL useful?

WSL is the Windows Subsystem for Linux, and I find it useful doing linuxy things, such as:

- ssh
- developing shell scripts
- running curl, base64, openssl, and similar utilities
- running bash one-liners found in internet tutorials
- incompatible toolchains - most notably, TUIs like `tig` don't run in Windows
- configuring neovim plugins for 17-20 hours every month (this is a joke, don't hurt me)

WSL2 is also well-isolated, such that I have already installed, deleted, reinstalled, and re-reinstalled distros, all without poisoning the Windows host. In other words, it's not 👻👻👻cygwin👻👻👻. Spoken in love, cygwin.

## Installing

Installing is as simple as running `wsl --install` if you're lucky; read this if you're not lucky: https://docs.microsoft.com/en-us/windows/wsl/install#install

Installing a specific distro happens through the Windows Store. I don't know why, either. Maybe forcing die-hard CLI advocates to install their favorite\* GPL-licensed distro through the comically commercialized Windows Store is a kind of joke? Well, intentional or no, it's hilarious.

As an aside, good luck with the Windows Store. It's somewhat buggy and opaque.

## Choosing a distro to install

If you don't know what to install, pick the most recent version of Ubuntu.

If you think you want to argue with this deliberately simplistic advice, then you are **definitely** not the target audience for it. Go in peace and install your modified DragonflyBSD or whatever.

## Surprisingly useful

```bash
# the following commands are all available from the WSL shell

# launch Windows Explorer here
cmd.exe /c start .

# works on links too
cmd.exe /c start https://google.com/search?q=wsl+by+example+cheatsheet

# pipe directly to the Windows clipboard
echo "${WSL_DISTRO_NAME}" | clip.exe
```

## Accessing files

**From Windows:**

- `\\wsl$\Ubuntu-20.04\home\p\.bashrc` - Two parts here. `\\wsl$\Ubuntu-20.04` gets you to the root of your Ubuntu 20.04 filesystem, and `/home/p/.bashrc` is the path within that filesystem)
- Typing `\\wsl$` into the Explorer address bar shows all distros (and lets you lazily navigate with the mouse and other GUI affordances. I WOULD NEVER)
- `cd \\wsl$\Ubuntu-20.04` works in PowerShell, and even cmd.exe has limited support for UNC-style paths

**From Linux:**

- Windows drives are mounted to `/mnt/<driveletter>`.
- `mount` shows WSL2's special mounts:
  ```bash
  > mount
  C:\ on /mnt/c type drvfs (rw,noatime,uid=1000,gid=1000,case=off)
  D:\ on /mnt/d type drvfs (rw,noatime,uid=1000,gid=1000,case=off)
  # ...
  # boring parts redacted
  # ...
  ```
- So, to reference Windows files and paths, do something like e.g. `ls -al /mnt/c/Users/p/Desktop`. Two parts here. `/mnt/c` gets you to the C:, and `C:\Users\p\Desktop` is the path within the C: drive.
- Windows paths from WSL are case-sensitive.

## wsl.exe usage

`wsl.exe` is useful for specific things, but I mostly launch WSL directly from Windows Terminal. Here are the specific things I've done with `wsl.exe`:

```powershell
# start default distro and launch shell
wsl

# list - useful if you installed both 'ubuntu' and 'ubuntu-20.04' - whoops - anyway if so, get rid of one
wsl --list

# shutdown - frees memory and (more useful) sometimes fixes my weird DNS issues
wsl --shutdown

# both   --exec   and   --   run a command
wsl --exec echo "I'm in unix! PowerShell version: $($PSVersionTable.PSVersion) <--evaluated in PowerShell in Windows"
wsl -- ls -al


# SUBTLE DIFFERENCE BELOW - PAY ATTENTION:

# this echoes back      WSL distro: Ubuntu-20.04
wsl -- echo "WSL distro: `${WSL_DISTRO_NAME}"

# this echoes back      WSL Distro: ${WSL_DISTRO_NAME}
wsl --exec echo "WSL Distro: `${WSL_DISTRO_NAME}"
```

## VS Code

VS Code (running in Windows) seamlessly edits files in WSL2. `code .` loads the current directory into VS Code.

## Accessing WSL From Windows Terminal

I launch the Ubuntu 20.04 shell with `CTRL` + `SHIFT` + `2`. Windows Terminal is highly configurable, so your experience may vary.

You can (if desired) set WSL as the default Profile for Windows Terminal.

## WSL: Turning it off and on again

These are the Baby Bear, Mama Bear, and Papa Bear of WSL troubleshooting options. (We don't talk about the Reboot-Windows Bear.)

- `wsl --terminate Ubuntu-20.04`
- `wsl --shutdown`
- `get-service | ? { $_.displayname -like "*hyper*" -and $_.status -eq "Running" } | restart-service`
- reboot (sorry)

## WSL2 file operations are slower

Be aware. I usually don't notice.

## WSL2 uses RAM

- If you're running WSL on a Windows OS with only 16GB of RAM, consider upgrading to 32GB. With 16GB, you're likely using all your RAM and relying on swap.
- WSL2 appears as `Vmmem` in Task Manager. Ubuntu 20.04 on my machine is currently using just under 2GB of RAM.
- To check your available RAM, look at Performance->Memory in Task Manager.

## Line endings

This is a really boring topic, but if you need it, you need it.

Git for Windows is probably checking out files with CRLF line endings (the specifics are configurable and too boring to fully explain - go read https://docs.github.com/en/get-started/getting-started-with-git/configuring-git-to-handle-line-endings). For most of us, if you commit files in Windows, push to GitHub, and pull them down in WSL, the line endings are LF in WSL and CRLF in Windows, which is probably what you want. However, if you're manipulating/accessing files across Linux and Windows boundaries, consider several solutions:

- `dos2unix` to manually convert a file from LF to CRLF from inside WSL
- Manually load and change line endings in your text editor. E.g. in VS Code in the status bar, it will say LF or CRLF. You can change this by clicking on the LF (or CRLF) indicator in the status bar. Or change it by running `>Change End of Line Sequence` from the Command Palette.

More permanent, team-friendly defaults:

- via `.gitattributes` in specific repos, always checkout some file types (e.g. shell scripts) as LF
- via `.gitattributes` in specific repos, always checkout all files as LF

More permanent, isolated defaults:

- via `git config --global core.autocrlf`
- via `git config --global core.eol`
