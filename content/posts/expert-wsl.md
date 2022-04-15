+++
title = "Expert WSL: soup-to-nuts"
tags = []
date = "2022-04-01"
draft = false
+++

##### Spicy Peppers Rating System | 🚫 | Zero Peppers: Mild and Nutritious; Blandly Educational

Covered here:

- what WSL is, and how to install it
- **astonishingly useful WSL tips!**
- ugly network troubleshooting
- boring, specialized topics that target 1% of you. 99% of you will be totally bored, but the remaining 1% will weep for joy

### Introduction: What is WSL, and how is it useful?

WSL is the Windows Subsystem for Linux, and I use it to:

- ssh
- test and develop shell scripts
- run curl, base64, openssl, and whatnot
- run seedy bash one-liners I found on the internet
- run Windows-incompatible tools - most notably, TUIs like `tig` don't run in Windows
- configure neovim plugins for 7-20 hours every week (this is a joke, don't hurt me)

All of these things can be done without WSL, but it's **less effort** to go with the flow and say, run ssh as nature intended. As a good, real example, every complex `kubectl` script I've seen was written in bash. You can convert those scripts to PowerShell, or you can somehow run bash directly on Windows...but why? **It's easier in WSL**.

WSL is also well-isolated, such that I have already installed, deleted, reinstalled, and re-reinstalled distros without issue. In other words, WSL doesn't do spooky things to your host like 👻👻👻cygwin👻👻👻 does. Spoken in love, cygwin.

### Installing: WSL itself

As of 2022, installing WSL2 is as simple as running (as Administrator) `wsl --install` if you're lucky. Read this if you're not lucky: https://docs.microsoft.com/en-us/windows/wsl/install#install

You will need to Enable Virtualization in your BIOS if it isn't already enabled. Good luck. Everyone's BIOS is different. These instructions are pretty good? https://bce.berkeley.edu/enabling-virtualization-in-your-pc-bios.html - anyway my expert technique to access the BIOS menu is to reboot and use both hands to repeatedly tap `Del`, `F1`, `F2`, `F8`, `F9`, `F12` all together, as quickly as possible, while thinking happy thoughts.

Beware of older, outdated instructions for installing WSL1 and even WSL2. And in full disclosure, I'm writing this sentence in April 2022, and I'm sure my instructions will similarly fall out of date. In the future you'll spend 45 minutes begging your Windows Store Personal GAN Shopping Assistant to install WSL, and it won't, of course. Anyway good luck in the future.

### Installing: a linux distro

Installing a specific distro happens through the Windows Store. I don't know why, either. Maybe forcing die-hard CLI advocates to install their favorite GPL-licensed distro through the comically commercialized Windows Store is a kind of joke? Well, intentional or no, it's hilarious.

If you don't know which distro to install, **pick the most recent version of Ubuntu.** And if you think you want to argue with this deliberately simplistic advice, then you are **definitely** not the target audience for it. Go in peace.

### Surprisingly useful things

WSL can launch Windows programs and use them in pipelines. There are some great things you can do with this _synergy_:

```bash
# launch Windows Explorer here - three ways
cmd.exe /c start .
explorer.exe
powershell.exe -Command ii .

# works on links too
cmd.exe /c start https://google.com/search?q=expert+wsl+devsecfailureops

# pipe directly to the Windows clipboard
echo "hunter2" | base64 | clip.exe
```

You can also run WSL processes in your PowerShell pipeline, but I haven't found many good uses for it. I guess I could do something like the following? Anyway, it's possible.

```powershell
# base64-encode whatever's on the clipboard, and put that back on the clipboard
Get-Clipboard | wsl base64 | Set-Clipboard
```

### Accessing files

Windows can access the WSL distro's filesystem, and the WSL distro can access Windows' filesystem.

**From Windows:**

- Files in WSL are accessible. By example, the full path for `\\wsl$\Ubuntu-20.04\home\p\.bashrc` is formed as such:
  - `\\wsl$\Ubuntu-20.04` accesses the root of the Ubuntu 20.04 filesystem
  - `/home/p/.bashrc` is the path within that filesystem
  - thus `\\wsl$\Ubuntu-20.04` + `/home/p/.bashrc` -> `\\wsl$\Ubuntu-20.04\home\p\.bashrc`
- `cd \\wsl$\Ubuntu-20.04` works in PowerShell, and even cmd.exe has limited support for UNC-style paths
- Accessing `\\wsl$` from the Explorer address bar lets you lazily navigate around WSL with the mouse and other GUI affordances--\*audible gasp\* BUT I WOULD NEVER! I haven't touched my mouse since 2018, I swear! And that was an accident!

**From WSL:**

- Files in Windows are accessible. By example, the full path for `/mnt/c/Users/p/Desktop/passwords.txt` is formed as such:
  - `/mnt/c` accesses the root of the C: (all Windows drives are mounted to `/mnt/<driveletter>`)
  - `\Users\p\Desktop\passwords.txt` is the path from within C:
  - thus `/mnt/c` + `\Users\p\Desktop\passwords.txt` -> `/mnt/c/Users/p/Desktop/passwords.txt`
- Windows paths referenced from WSL are **case-sensitive**. This is easier to remember once you've been burned by it 3-4 times (or 300-400 maybe).

### wsl.exe usage

Here are the specific things I've done with `wsl.exe`:

```powershell
# start default distro and launch shell
# also kicks the WSL subsystem into gear if WSL's not running, for whatever reason
wsl

# list - useful if you're playing around with multiple distros, or don't know what you're doing
# I should point out that you can simultaneously install multiple distros
wsl --list

# shutdown
wsl --shutdown
```

You can quickly invoke the WSL shell via wsl.exe. The details are explained by example below:

```powershell
# both   --exec   and   (any unrecognized parameter)   run a command in the WSL distro
# everything after   --   is delegated to the WSL distro
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

VS Code (running in Windows) seamlessly edits files in WSL2, so long as you've installed either of the `Remote - WSL` or `Remote Development` extensions.

To painlessly launch the current directory in WSL, do:

```bash
$ code .
```

### Seamless Terminal Experience: Windows Terminal

I launch the Ubuntu 20.04 shell in a new tab in Windows Terminal with `CTRL` + `SHIFT` + `2`. Windows Terminal is highly configurable, so your hotkeys may vary.

Small nitpick: there are occasional display bugs in Windows Terminal. I've noticed too--it's not just you.

### WSL: Turning it off and on again

There are two options here: the one you hope works, and the one you know works. WSL's `--shutdown` command is usually effective.

- The option you hope works: `wsl --shutdown` followed by `wsl`
- The option you know works, for certain: reboot Windows (sorry)

### WSL uses RAM

- If you're running WSL on a Windows OS with only 16GB of RAM, consider upgrading to 32GB. With 16GB, you're likely using all your RAM and relying on swap. This will slow you down noticeably. I mean, yes, we mostly blame Chrome and curse the day Electron was invented, and they're the worst offenders. I'm just saying that once you start running containers or VMs on 16GB of RAM, you're done. You're done.
- WSL2 appears as `Vmmem` in Task Manager. Ubuntu 20.04 on my machine is currently using just under 2GB of RAM.
- To check available RAM, look at Performance->Memory in Task Manager.

### Boring and Necessary: Networking issues

Listen up! Networking in WSL is magic. And by magic I mean opaque, mysterious, fickle, and moody. I've done several things to fix networking issues:

- If DNS dies regularly in WSL, fix it permanently with this WSL-specific change: https://superuser.com/a/1533768
- Set MTU to 1400 - I would love to explain this further, but in short, I can't. Good luck, and if you google your mysterious networking-related error message and some of the first results are for setting the 'MTU', then try it, certainly. The last time I saw this error, someone was trying to clone a git repo.

### Boring and Necessary: Line endings

This is a really boring topic, but if you need it, you need it.

Git for Windows is probably checking out files with CRLF line endings (the specifics are here: https://docs.github.com/en/get-started/getting-started-with-git/configuring-git-to-handle-line-endings). For most of us, if you commit files in Windows, push to GitHub, and pull them down in WSL, the line endings are LF in WSL and CRLF in Windows, which is probably what you want. However, if you're manipulating/accessing files across Linux and Windows boundaries, consider several solutions to tackling the line ending problem:

- `dos2unix` to manually convert a file from LF to CRLF, or CRLF to LF, from inside WSL
- Manually load and change line endings in your text editor. E.g. in VS Code in the status bar, it will indicate either LF or CRLF. You can change this by clicking on the LF (or CRLF) indicator in the status bar, or from the Command Palette: `>Change End of Line Sequence`.

More permanent, team-friendly defaults:

- set `.gitattributes` in individual repos to always checkout some file types (e.g. shell scripts) as LF
- set `.gitattributes` in specific repos to always checkout all files as LF

More permanent defaults for your git install (only affects you, not the team):

- via `git config --global core.autocrlf`
- via `git config --global core.eol`
