#### Known incomplete things:

- "Comment line's first expression" command does nothing
- Most structural-editing commands assume you don't have any text highlighted
- Once you connect to nREPL, the only way to disconnect is to quit Leviathan
- The nREPL support is really, really basic
- Using "Use Different Settings Folder" feature requires restarting Leviathan
- The "Find File in Project" fuzzy-matching algorithm is kinda crappy
- "Open Test in Split" only knows about the "test/foo/bar_test.clj" structure
- Although the settings allow for vim-style modality, there's no especially-vim-like commands yet
- It doesn't stop you from deleting or commenting out parentheses/brackets/etc
- Once you close a whole project-window, all the undos in that project's files are reset

#### Known bugs:

- Line numbers are kinda buggy in general (disabled for now)
- If you have syntax errors in your settings/theme files, Leviathan will probably just crash
- Project file tree should be part of the window, not just a drawer (disabled for now)

#### Internal things left to do:

- Change the way we modify text in NSTextView to stop relying on Cocoa at all (hard!)
