## Leviathan

*Clojure IDE for OS X*

* Current version: **0.1**
* Requires: OS X 10.9 and up
* Download: get [.zip file](https://raw.github.com/sdegutis/Leviathan/master/Builds/Leviathan-LATEST.app.tar.gz), unzip, right-click app, choose "Open"

#### Known incomplete things

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
- Instead of MovableLeviathanSettingsFolder, it should just be symlinkable, so that you can symlink it right into Dropbox if you want to (might be better as `~/.leviathan` in that case)

#### Known bugs

- Line numbers are kinda buggy in general (disabled for now)
- If you have syntax errors in your settings/theme files, Leviathan will probably just crash
- Project file tree should be part of the window, not just a drawer (disabled for now)

#### Internal things left to do

- Change the way we modify text in NSTextView to stop relying on Cocoa at all (hard!)
- Make it easier to manipulate the internal AST
- Make it easier to generate a new string based on the internal AST
- Start modifying the NSTextStorage by generating new strings based on the internal AST and replacing the contents wholesale (with proper undo support)
- Undo support should handle not only text but also selection range(s)
- Support multiple cursors (maybe)
- Split coll/atom types into multiple types (possible semantic/syntactic) to support >64 types

#### License

> Released under MIT license.
>
> Copyright (c) 2013 Steven Degutis
>
> Permission is hereby granted, free of charge, to any person obtaining a copy
> of this software and associated documentation files (the "Software"), to deal
> in the Software without restriction, including without limitation the rights
> to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
> copies of the Software, and to permit persons to whom the Software is
> furnished to do so, subject to the following conditions:
>
> The above copyright notice and this permission notice shall be included in
> all copies or substantial portions of the Software.
>
> THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
> IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
> FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
> AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
> LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
> OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
> THE SOFTWARE.
