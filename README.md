# vim-tagattsort (tag attributes sorter)
Vim plugin for alphabetically sorting attributes of tags (html, jsx, etc). It also enhances their format to improve readability.

## Example

The following example shows a tag before and after using the plugin.

Before:

        <Box z={ 1   } color="red" onPress={ () => onClick( id ) } style={ handleStyle() }  a={ 5 } >

After:

        <Box a={ 5 } color="red" onPress={ () => onClick( id ) } style={ handleStyle() } z={ 1 }>

## Usage

The plugin works in normal mode. To use it, place your cursor anywhere inside a tag and then hit the spacebar twice. It also works if you place the cursor at the beginning of a line; in this case, the target would be the left-most tag in that line.

## Installation

### Using Plug

1. Add the following line to your *~/.vimrc*:

        Plug 'jose-villar/vim-tagattsort'

2. From within vim, run:

        PlugInstall


## Modification of Default Mappings

This is easier to explain with an example: Let's pretend you wanted to change the default mapping to '\<Leader\>h'. The way to accomplish this, is to add the following line to your *vimrc*:

        nmap <unique><Leader>h <Plug>TagattsortNMode

## Limitations

- The plugin won't work for tags whose attributes are spread across multiple lines.
