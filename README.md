## bibget.nvim

Plugin to retrieve BibTeX entries from DOI, arXiv number, or [MathSciNet](https://mathscinet.ams.org) (the latter requiring a subscription to MathSciNet).
The resulting data can either be displayed in a popup or directly inserted into the buffer.
See `:help getbib-intro` for more information.

## Installation

The plugin relies on an external program  to retrieve bibliographic data.
Currently only `pybibget` is supported.
The plugin needs at least version v0.1.1, which currently is not yet available on [PyPI](https://pypi.org).
It can be installed directly though using `pip`, by typing
```sh
pip install git+https://github.com/wirhabenzeit/pybibget.git
```
The plugin can then be installed using your favourite plugin manager. 
For example, for [lazy.nvim](https://github.com/folke/lazy.nvim), use the following:
```lua
{
    "pnaaijkens/getbib.nvim",
    opts = {}
}
```

## Usage
The plugin defines two commands.
The first, `:GetBib`, looks up the BibTeX for the identifier(s) and inserts or
replaces the resulting data in the current buffer. The command `:GetBibPopup`
works similarly, but displays the result in a floating window instead of
inserting it in the buffer.

Identifiers can be specified in more than one way. The plugin tries to be
smart to find identifiers. The options are:

1. Supply the identifiers as arguments to the functions above. Each
   identifier should be separated by a space.

2. Select the identifier(s) in visual mode and run one of the commmands.
   A default keymap `<Leader>gb` is provided. If BibTeX data is found, the 
   selected text is replaced by the BibTeX data, or it is displayed in a
   float.

3. Call the command without any parameters and not from visual mode. In
   this case, the plugin tries to find the `<cword>` under the cursor 
   (with custom settings appropriate for identifiers). The plugin then 
   works the same as in method 2, with the `<cword>` selected in visual
   mode.
