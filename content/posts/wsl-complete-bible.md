+++
title = "WSL Bible: Everything you could possibly want to know about WSL2"
tags = []
date = "2021-02-01"
draft = false
+++

##### Spicy Peppers Rating System | 🚫 | Zero Peppers: Mild and Nutritious; Blandly Educational

### What is WSL, and how is it useful?

WSL is the Windows Subsystem for Linux, and I use it to:

- ssh
- test and develop shell scripts
- run curl, base64, openssl, and whatnot
- run seedy bash one-liners found on the internet
- run Windows-incompatible tools - most notably, TUIs like `tig` don't run in Windows
- configure neovim plugins for 7-20 hours every week (this is a joke, don't hurt me)

WSL2 is also well-isolated, such that I have already installed, deleted, reinstalled, and re-reinstalled distros without issue. In other words, it doesn't do spooky things to your host like 👻👻👻cygwin👻👻👻 did all those years ago. Spoken in love, cygwin.

### Installing: WSL2 itself

Installing is as simple as running `wsl --install` if you're lucky; read this if you're not lucky: https://docs.microsoft.com/en-us/windows/wsl/install#install

You will need to Enable Virtualization in your BIOS if it isn't already enabled. Good luck. Everyone's BIOS is different. These instructions are pretty good? https://bce.berkeley.edu/enabling-virtualization-in-your-pc-bios.html - anyway my expert technique to access the BIOS menu is to reboot and use both hands to repeatedly tap `Del`, `F1`, `F2`, `F8`, `F12` all together, as quickly as possible, and think happy thoughts.

It's important to note that there are older, out-of-date instructions for installing WSL. Don't be fooled! Trust no one! (except me)

### Installing: a linux distro

Installing a specific distro happens through the Windows Store. I don't know why, either. Maybe forcing die-hard CLI advocates to install their favorite GPL-licensed distro through the comically, almost ludicrously commercialized Windows Store is a kind of joke? Well, intentional or no, it's hilarious.

If you don't know which distro to install, pick the most recent version of Ubuntu. And if you think you want to argue with this deliberately simplistic advice, then you are **definitely** not the target audience for it. Go in peace.

### Surprisingly useful things

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

### Accessing files

Windows can access the WSL distro's filesystem, and the WSL distro can access Windows' filesystem.

**From Windows:**

- `\\wsl$\Ubuntu-20.04\home\p\.bashrc` - The full path is formed as such: `\\wsl$\Ubuntu-20.04` is the root of the Ubuntu 20.04 filesystem, and `/home/p/.bashrc` is the path within that filesystem
- Typing `\\wsl$` into the Explorer address bar shows all distros and lets you lazily navigate with the mouse and other GUI affordances (BUT I WOULD NEVER!)
- `cd \\wsl$\Ubuntu-20.04` works in PowerShell, and even cmd.exe has limited support for UNC-style paths

**From WSL:**

- Windows drives are mounted to `/mnt/<driveletter>`.
- `mount` shows WSL's special mounts:
  ```bash
  > mount
  C:\ on /mnt/c type drvfs (rw,noatime,uid=1000,gid=1000,case=off)
  D:\ on /mnt/d type drvfs (rw,noatime,uid=1000,gid=1000,case=off)
  # ... boring parts redacted ...
  ```
- To reference Windows files and paths, do something like e.g. `ls -al /mnt/c/Users/p/Desktop`. The full path is formed as such: `/mnt/c` gets you to the C:, and `\Users\p\Desktop` is the path within the C: drive.
- Windows paths referenced from WSL are case-sensitive.

### wsl.exe usage

`wsl.exe` is of specific, limited utility. Here are the specific things I've done with `wsl.exe`:

```powershell
# start default distro and launch shell - also kicks the WSL subsystem into gear if WSL's not running, for whatever reason
wsl

# list - useful if you installed both 'ubuntu' and 'ubuntu-20.04' - whoops
# anyway, I should also point out that you can simultaneously install multiple distros
wsl --list

# shutdown
wsl --shutdown

# both   --exec   and   (any unrecognized parameter)   run a command in the WSL guest OS
# and as is becoming a convention in CLIs everywhere, everything after   --   is delegated to the WSL distro
# --you know, like git does. See https://stackoverflow.com/a/13321491 for a good explanation of -- in git
wsl --exec echo "I'm in unix! PowerShell version: $($PSVersionTable.PSVersion) <--evaluated in PowerShell in Windows"
wsl ls -al
wsl -- ls -al


# SUBTLE DIFFERENCE BELOW - PAY ATTENTION:

# these echo back       WSL distro: Ubuntu-20.04
wsl echo "WSL distro: `${WSL_DISTRO_NAME}"
wsl -- echo "WSL distro: `${WSL_DISTRO_NAME}"

# this echoes back      WSL Distro: ${WSL_DISTRO_NAME}
wsl --exec echo "WSL Distro: `${WSL_DISTRO_NAME}"
```

### Seamless Text Editing: VS Code

VS Code (running in Windows) seamlessly edits files in WSL2. To quickly launch the current directory in WSL, do a `code .`.

### Seamless Terminal Experience: Windows Terminal

I launch the Ubuntu 20.04 shell in a new tab in Windows Terminal with `CTRL` + `SHIFT` + `2`. Windows Terminal is highly configurable, so your hotkeys may vary.

Small nitpick: there are occasional display bugs in Windows Terminal. It's not just you noticing.

### WSL: Turning it off and on again

There are two options here: the one you hope works, and the one you know works. WSL's `--shutdown` command is usually effective.

- `wsl --shutdown` followed by `wsl`
- reboot Windows (sorry)

### WSL uses RAM

- If you're running WSL on a Windows OS with only 16GB of RAM, consider upgrading to 32GB. With 16GB, you're likely using all your RAM and relying on swap. This will slow you down noticeably.
- WSL2 appears as `Vmmem` in Task Manager. Ubuntu 20.04 on my machine is currently using just under 2GB of RAM.
- To check available RAM, look at Performance->Memory in Task Manager.

### Boring and Necessary: Networking issues

Listen up! Networking in WSL is magic. And by magic I mean opaque, mysterious, fickle, and moody. I've done several things to fix networking issues:

- If DNS dies regularly in WSL, fix it permanently with this WSL-specific change: https://superuser.com/a/1533768
- Set MTU to 1400 - I would love to explain this further, but in short, I can't. Good luck, and if you google your mysterious networking-related error message and some of the first results are for setting the 'MTU', then try it, certainly.

My VPN provider seems to interfere with WSL networking, but I'm not certain, and it's just a hypothesis at this point.

### Boring and Necessary: Line endings

This is a really boring topic, but if you need it, you need it.

Git for Windows is probably checking out files with CRLF line endings (the specifics are configurable and too boring to fully explain - go read https://docs.github.com/en/get-started/getting-started-with-git/configuring-git-to-handle-line-endings). For most of us, if you commit files in Windows, push to GitHub, and pull them down in WSL, the line endings are LF in WSL and CRLF in Windows, which is probably what you want. However, if you're manipulating/accessing files across Linux and Windows boundaries, consider several solutions:

- `dos2unix` to manually convert a file from LF to CRLF from inside WSL
- Manually load and change line endings in your text editor. E.g. in VS Code in the status bar, it will indicate either LF or CRLF. You can change this by clicking on the LF (or CRLF) indicator in the status bar. Or change it by running `>Change End of Line Sequence` from the Command Palette.

More permanent, team-friendly defaults:

- set `.gitattributes` in individual repos to always checkout some file types (e.g. shell scripts) as LF
- set `.gitattributes` in specific repos to always checkout all files as LF

More permanent defaults for your git install only:

- via `git config --global core.autocrlf`
- via `git config --global core.eol`
