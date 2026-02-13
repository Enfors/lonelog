# lonelog.el

**Lonelog** is an Emacs minor mode which provides syntax highlighting support for the [Lonelog solo RPG notation system](https://zeruhur.itch.io/lonelog).

It is designed to **mode-agnostic**, meaning that you (hopefully!) can use it on top of any text-based mode, such as Org-mode (which is what I use it for) and Markdown-mode.

## Features

At the moment, there aren't many features. But if there is interest in this project, then I will add more features as time goes on.

* **Syntax highlighting:** Lonelog-mode recognizes and colors the five core Lonelog symbols, and the text following them on the same line:
    * `@` Action
    * `?` Oracle question
    * `d:` Mechanics roll
    * `->` Result
    * `=>` Consequence
* **Smart overrides:** Correctly handles lines with multiple symbols (such as a `d:` mechanics roll followed by a `->` result on the same line).

## Installation

### From MELPA

I'm afraid Lonelog isn't on Melpa yet, but the goal is to get it there as soon as possible.

### Manual installation

```bash
git clone [https://github.com/enfors/lonelog.git](https://github.com/enfors/lonelog.git) ~/.emacs.d/lisp/lonelog
```

Then add the following to your `init.el`:

```elisp
(add-to-list 'load-path "~/.emacs.d/lisp/lonelog")
(require 'lonelog)
```

## Configuration

### Basic setup (hooks)

To automatically enable Lonelog in specific mode (such as Org-mode or Markdown-mode):

```elisp
(add-hook 'org-mode-hook 'lonelog-mode)
(add-hook 'markdown-mode-hook 'lonelog-mode)
```

## Usage guide

Lonelog highlights lines based on standard notation prefixes.

| Symbol | Meaning            | Example                           |
| :----- | :----------------- | :-------------------------------- |
| **@**  | **Action**         | `@ I sneak past the guard.`       |
| **?**  | **Oracle**         | `? Is the door locked?`           |
| **d:** | **Mechanics roll** | `d: Stealth check (DC 15)`        |
| **->** | **Result**         | `-> Success! (18)`                |
| **=>** | **Consequence**    | `=> The guard doesn't notice me.` |

## Customization

All faces are customizable via `M-x customize-group RET lonelog RET`.

## Credits

* **Notation:** The Lonelog system was created by [Loreseed Workshop](https://zeruhur.itch.io/lonelog).
* **Lonelog-mode for Emacs:** Developed by [Christer Enfors](https://ttrpg-hangout.social/Enfors).
