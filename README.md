# vim-tagasort

## INTRODUCTION

The idea of *Tagasort* is to improve the readability of attributes of *html*
and *jsx* tags. To do so, the attributes are sorted alphabetically and
formatted to enforce a consistent style.

Note that this plugin was designed with Vim's autoload functionality in mind to
keep your Vim startup time low.

## EXAMPLE

The following case shows a tag before and after using the plugin.

Before:

        <Box z={ 1   } color="red" onPress={()=>onClick(id )} a={5 } >

After:

        <Box a={ 5 } color="red" onPress={ () => onClick( id ) } z={ 1 }>

## USAGE

Tagasort works in normal mode. To use it, place your cursor anywhere inside a
tag and then hit the spacebar twice. If you use it outside a tag, it will
search for the next tag in the current line and use that as the target.

## INSTALLATION

Use your favorite plugin manager.

### USING PLUG

1. Add the following line to your *vimrc*:

        Plug 'jose-villar/vim-tagasort'

2. From within Vim, run:

        :PlugInstall


## MAPPINGS

You can easily change the key combination that triggers the plugin. For
example, if you wanted to change the default mapping to `<Leader>0` , you would
have to add the following line to your *vimrc*:

        nmap <unique><Leader>0 <Plug>Tagasort_FormatTag

## LIMITATIONS

- This plugin doesn't work with tags whose attributes are spread across
multiple lines. - Nvim has `magic` enabled by default. Make sure to keep it
this way, or else the plugin will have serious performance issues.

## LICENSE

Copyright (c) José Villar. Distributed under the same terms as Vim itself. See
``:help license``.
