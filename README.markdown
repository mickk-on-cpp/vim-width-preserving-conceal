# vim-width-preserving-conceal

## Motivation

Vim comes with a very nice conceal feature that can be used to substitute syntax elements with a nicer alternative.
Unfortunately simple usage of the feature can sometimes fall short of expectations. Consider this Haskell example:

```vimL
syntax match /->/ conceal cchar=→
```

The intent here is to replace ASCII-art arrows as they appear e.g. in Haskell declarations by nicer Unicode arrows. What
might not be intended is the resulting shift in the lines depending on the `conceallevel`:

![naive conceal](naive_conceal.gif)

This can be especially problematic when e.g. a programmer would like to code with the `concealcursor` option on: the
lines and characters will dance as she navigates and works on the source code. This plugin aims to remedy that situation
by making it easier to define *width-preserving substitutions*, i.e. substituting a syntax element by an alternative
with the same width:

![width-preserving conceal](preserving_conceal.gif)

## Quick reference

## Limitations


