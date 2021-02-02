# vim-tagasort


This plugin is a tag attributes sorter. It sorts the attributes of html and jsx tags alphabetically. Also, it enhances their format to improve readability.

## Example

The following case shows a tag before and after using the plugin.

Before:

        <Box z={ 1   } color="red" onPress={()=>onClick(id )} style={ handleStyle(  ) }  a={ 5 } >

After:

        <Box a={ 5 } color="red" onPress={ () => onClick( id ) } style={ handleStyle() } z={ 1 }>

## Usage

*Tagasort* works in normal mode. To use it, place your cursor anywhere inside a tag and then hit the spacebar twice. It also works if you place the cursor at the beginning of a line, before any tag; in this case, the target is the left-most tag in that line.

## Installation

### Using Plug

1. Add the following line to your *~/.vimrc*:

        Plug 'jose-villar/vim-tagasort'

2. From within vim, run:

        PlugInstall


## Configuration

You can easily change the key combination that triggers the plugin. For example, if you wanted to change the default mapping to `<Leader>h` , you would have to add the following line to your *vimrc*:

        nmap <unique><Leader>h <Plug>Tagasort_FormatTag

## Limitations

This plugin doesn't work with tags whose attributes are spread across multiple lines.

## License

Copyright (c) José Villar. Distributed under the same terms as Vim itself. See ``:help license``.
