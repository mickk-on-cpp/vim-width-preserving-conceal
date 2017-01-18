# vim-width-preserving-conceal

## Motivation

Vim comes with a very nice conceal feature that can be used to substitute syntax elements with a nicer alternative.
Unfortunately simple usage of the feature can sometimes fall short of expectations. Consider this example designed for
Haskell syntax:

```vimL
syntax match /->/ conceal cchar=→
```

The intent here is to replace ASCII-art arrows as they appear e.g. in Haskell declarations by Unicode arrows. What might
not be intended is the resulting shift in the lines depending on the `'conceallevel'`:

![naive conceal](naive_conceal.gif)

This can be especially problematic when e.g. a programmer would like to code with the `'concealcursor'` option set to
`""`: the lines and characters will dance as he or she works on and navigates the source code. This plugin aims to
remedy that situation by making it easier to define *width-preserving substitutions*, i.e. substituting a syntax element
by an alternative with the same width:

![width-preserving conceal](preserving_conceal.gif)

## Installation & Options

Install using your favourite plugin manager.

If you don't set highlighting settings for the `Conceal` group, or your colorscheme doesn't do it for you or you don't
like what it does you will have to do it yourself somewhere in your configuration. (The plugin won't do it in order to
play nice with other concealing plugins.) I personally use the following, although it's nothing special and you're
encouraged to find something you like:
```vimL
highlight! link Conceal NonText
```

You can set the following options to true in your configuration files:
 - `g:width_preserving_conceal_no_links` to prevent the generation of highlighting rules--this only impacts highlighting
   when `'conceallevel'` is set to 0
 - `g:width_preserving_conceal_no_haskell_presets` to prevent the generation of conceal rules for Haskell

All options are documented in more detail at `:help width-preserving-conceal-options`

## Limitations

* When concealing is on, all substitutions are highlighted as the `Conceal` group and will have a common appearance.
  This is inherent to the conceal functionality of Vim.

* Conceal rules can produce a large amount of actual syntax and highlighting rules.

* Substituting a multi-column piece of syntax with a one-column replacement does not necessarily look that great. Can
  you tell these one-column things apart in a monospaced font? How does that compare to their multi-column equivalents?

  ```
  →  ⇒   ↔   ⇔  ←  ⇐
  -> => <-> <=> <- <=
  ```

  It's possible to try and be clever by using double-wide glyphs. However Vim works under the assumption that everything
  is one-column wide (ambiguous width class East Asian symbols aside), so results are unreliable. Depending on the
  particular combination of editor (Vim, Vim graphical, Neovim, etc.), OS, and font you may or may not like the results.
  As a hint, you can try substituting things like these in `syntax/haskell/width-preserving-conceal.vim`:

  ```vimL
  call s:haskell_conceal.operator('RArrow', '->', '→')
  ```

  by this:

  ```vimL
  call s:haskell_conceal.operator('RArrow', '->', '⟶')
  ```

* The Haskell presets are bare-bones and conservative (see above).

## Future Work

The plugin has room for expansion. Unfortunately I'm not sure I will find the time to resume work on it, so don't expect
any of these soon:
 - more presets
 - more fine-grained settings for the Haskell presets--in particular, give an option to try the long Unicode arrows at
   own risk (see Limitations)
 - multi-replacements, i.e. not just one column at one index
