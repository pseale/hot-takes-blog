+++
title = "WSL2 Tips: By Example: A Cheatsheet"
tags = []
date = "2021-02-01"
draft = true
+++

###### Spicy Peppers Rating System: [🚫 | Mild and Nutritious; Blandly Educational ]

## What is WSL, and how is it useful?

WSL is the Windows Subsystem for Linux, and I use it to:

- ssh
- develop shell scripts
- run curl, base64, openssl, and whatnot
- run seedy bash one-liners found in on the internet
- run Windows-incompatible tools - most notably, TUIs like `tig` don't run in Windows
- configure neovim plugins for 17-20 hours every month (this is a joke, don't hurt me)

WSL2 is also well-isolated, such that I have already installed, deleted, reinstalled, and re-reinstalled distros without issue. In other words, it's doesn't do spooky things to your host like 👻👻👻cygwin👻👻👻. Spoken in love, cygwin.

## Installing: WSL2 itself

Installing is as simple as running `wsl --install` if you're lucky; read this if you're not lucky: https://docs.microsoft.com/en-us/windows/wsl/install#install

You will need to Enable Virtualization in your BIOS if it isn't already enabled. Good luck. Everyone's BIOS is different. These instructions are pretty good? https://bce.berkeley.edu/enabling-virtualization-in-your-pc-bios.html - anyway my expert technique to access the BIOS menu is to reboot and use both hands to repeatedly tap `Del`, `F1`, `F2`, `F8`, `F12` all together, as quickly as possible, and think happy thoughts.

## Installing: a linux distro

Installing a specific distro happens through the Windows Store. I don't know why, either. Maybe forcing die-hard CLI advocates to install their favorite GPL-licensed distro through the comically commercialized Windows Store is a kind of joke? Well, intentional or no, it's hilarious.

If you don't know what distro to install, pick the most recent version of Ubuntu. And if you think you want to argue with this deliberately simplistic advice, then you are **definitely** not the target audience for it. Go in peace.

## Surprisingly useful things

WSL can launch Windows programs and use them in pipelines. There are some great things you can do with this _synergy_.

```bash
# launch Windows Explorer here
cmd.exe /c start .

# works on links too
cmd.exe /c start https://google.com/search?q=wsl+by+example+cheatsheet

# pipe directly to the Windows clipboard
echo "${WSL_DISTRO_NAME}" | clip.exe
```

You can access WSL from PowerShell on Windows, but I haven't found many good uses for it. I guess I could do something like the following?

```powershell
# base64-encode whatever's on the clipboard, and put that back on the clipboard
Get-Clipboard | wsl base64 | Set-Clipboard
```

## Accessing files

**From Windows:**

- `\\wsl$\Ubuntu-20.04\home\p\.bashrc` - The full path is formed as such: `\\wsl$\Ubuntu-20.04` is the root of the Ubuntu 20.04 filesystem, and `/home/p/.bashrc` is the path within that filesystem
- Typing `\\wsl$` into the Explorer address bar shows all distros (and lets you lazily navigate with the mouse and other GUI affordances. BUT I WOULD NEVER)
- `cd \\wsl$\Ubuntu-20.04` works in PowerShell, and even cmd.exe has limited support for UNC-style paths

**From Linux:**

- Windows drives are mounted to `/mnt/<driveletter>`.
- `mount` shows WSL2's special mounts:
  ```bash
  > mount
  C:\ on /mnt/c type drvfs (rw,noatime,uid=1000,gid=1000,case=off)
  D:\ on /mnt/d type drvfs (rw,noatime,uid=1000,gid=1000,case=off)
  # ... boring parts redacted ...
  ```
- So, to reference Windows files and paths, do something like e.g. `ls -al /mnt/c/Users/p/Desktop`. The full path is formed as such: `/mnt/c` gets you to the C:, and `\Users\p\Desktop` is the path within the C: drive.
- Windows paths referenced from WSL are case-sensitive.

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

# these echo back       WSL distro: Ubuntu-20.04
wsl echo "WSL distro: `${WSL_DISTRO_NAME}"
wsl -- echo "WSL distro: `${WSL_DISTRO_NAME}"

# this echoes back      WSL Distro: ${WSL_DISTRO_NAME}
wsl --exec echo "WSL Distro: `${WSL_DISTRO_NAME}"
```

## Seamless Text Editing: VS Code

VS Code (running in Windows) seamlessly edits files in WSL2. `code .` launches VS Code with the current directory as its workspace.

## Seamless Terminal Experience: Windows Terminal

I launch the Ubuntu 20.04 shell in a new tab in Windows Terminal with `CTRL` + `SHIFT` + `2`. Windows Terminal is highly configurable, so your experience may vary.

You can (if desired) set WSL as the default Profile for Windows Terminal.

## WSL: Turning it off and on again

There are two options here: the one you hope works, and the one you know works. WSL's `--shutdown` command is usually effective.

- `wsl --shutdown`
- reboot (sorry)

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
