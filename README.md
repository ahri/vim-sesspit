# SessPit for Vim
Simple, automatic session management for Vim

- [x] Simple
- [x] Masterless
- [x] Sensible defaults
- [x] No dependencies

## What?

It's a session manager for Vim that strives to work when you ask it to and then
get out of your way. It will drop a session file either in your current
directory, or, preferably, in a suitable project directory above your current
one that contains a project marker (configurable, but something like a .git
directory). Once a session file exists it'll keep it updated when you swap
buffers or exit Vim. That's it. Magic.

## Why?

Vim includes session saving via `mksession` and restore via `source` but I
wanted to make things a bit simpler; I wanted to be able to say "this project is
worth being able to jump right back into" and for that to be easy. I wanted it
automatic but not too automatic, and I wanted it to stay out of my way as much
as possible.

## How?

- Vundle
  `Bundle 'ahri/vim-sesspit'`

- vim-plug
  `Plug 'ahri/vim-sesspit'`

Then just `:SessPit` to start tracking to `.vimsession~`.

## Config?

```
sesspit#set_filename(".mysession") " default: ".vimsession~"

sesspit#set_sessionoptions("buffers,tabpages") " default: "buffers"

sesspit#set_project_markers(".git,.svn,MY_PROJECT_MARKER") " default: ".git"
```

## Versus

- [Obsession](https://github.com/tpope/vim-obsession)

  Not automatic.

- [Prosession](https://github.com/dhruvasagar/vim-prosession)

  Dependent on Obsession. Global session registry.

- [Startify](https://github.com/mhinz/vim-startify)

  Global session registry. Heavyweight.
