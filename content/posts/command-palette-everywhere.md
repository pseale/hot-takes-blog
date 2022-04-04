+++
title = "Command Palettes (Omnisearch) Everywhere"
tags = []
date = "2022-03-18"
draft = false
+++

##### Spicy Peppers Rating System | 🚫 | Zero Peppers: Inoffensive and Sincere

### Summary

1. Command Palettes let you search for and run commands by descriptive name.
1. Thus for rare or obscure tasks, using the Command Palette is much easier than hunting down commands in `Nested->Edit->Menus` or memorizing arcane key chords. This is a big productivity boost, and I'm the only person I know who does this. You people are doing it all wrong! "You people are doing it all wrong" is generally true, _but I digress._
1. Command Palettes are in every major text editor and IDE.
1. They're also in weird places like Windows Terminal and Chrome Developer Tools.

### By example

In VS Code, I sometimes run `>Format Document`. I know this is available through either a deeply nested `File->Etc` menu or a hotkey.

In the case of `Format Document`, it is apparently bound by default to `ALT`+`SHIFT`+`F`. Reasonable, but unmemorable for something I do rarely in my part-time text editor. In days of yore, I might have tried to memorize this keybind! Or worse, ｃｕｓｔｏｍｉｚｅ ｍｙ ｋｅｙｂｉｎｄｓ!

But now that I've acclimated to relying on Command Palettes, I'll open the Command Palette, lazily type a few letters of `format`, lazily arrow up and down, lazily press `ENTER`, lazily be done with it. And all effortlessly, without expending my precious brain energy!

### Command Palettes: Give your brain a break

`Format Document` is just one example of something I do once a month or so. I've also messed with BOM encodings via `Change File Encoding`, fiddled with with line endings via `Change End of Line Sequence`, and even used the `Fold` command to collapse some XML that one time!

In Windows Terminal, I've split the terminal pane so I could watch several things at once. Thanks to the Command Palette, I didn't have to hunt down the settings and memorize `ALT`+`SHIFT`+`+`. Instead, I put my brain on vacation, opened the Command Palette, searched for `split`, ran it, and moved on with my life.

### Your IDE and You

Command Palettes are available in:

1. [Sublime Text](https://docs.sublimetext.io/guide/extensibility/command_palette.html) - the original!
1. [VS Code](https://code.visualstudio.com/docs/getstarted/userinterface#_command-palette) - VS Code did a great job harvesting Sublime Text's best features, and the Command Palette is one such feature. Well done, thieves!
1. [Visual Studio](https://docs.microsoft.com/en-us/visualstudio/ide/visual-studio-search?view=vs-2019) - here it is called Search
1. [JetBrains Products](https://www.jetbrains.com/help/rider/Navigating_to_Action.html) - here it is available through either Find Action, or Search Everywhere--either will do the trick
1. [Google Chrome Dev Tools](https://developer.chrome.com/docs/devtools/command-menu/) - here it is called Command Menu
1. [Windows Terminal](https://docs.microsoft.com/en-us/windows/terminal/command-palette) - as weird as it sounds, the Command Palette exists here!
1. [Vim](https://superuser.com/q/671149) - as with all things Vim, there are many paths up the mountain, none of which is the 'true' one. Vim plugin universalism: you heard it here first.

### Command Palette Conventions

1. I have the Command Palette bound to `CTRL`+`SHIFT`+`P` everywhere. This is already the default keybind in many places. MacOS users: as with all things, mentally replace `CTRL` with `CMD`.
1. Similarly, `CTRL`+`P` should navigate to files. MacOS: `CMD`+`P`.
1. Command Palettes support a kind of forgiving fuzzy search<sup>[1]</sup> syntax and a convenient dropdown list of commands. If you've never seen this before, the key word here is **fuzzy**. It's fuzzy search. It's not strict.
1. The Command Palette shows keybinds (if any exist) for the command. Use the Command Palette like a cheatsheet.
1. VS Code, JetBrains, and Google Chrome support mode swapping through the addition or removal of the `>` prefix. So, by example:
   - Searching for `>format` gives the `Format Document` command
   - Searching for `format` without the `>` prefix gives `formatter.js`.

#### Footnotes:

<sup><sub>
[1] Is Command Palette fuzzy search fuzzy like `fzf`? Who can say? Not I! Not I.
</sub></sup>
