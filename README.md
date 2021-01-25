# vim-tagattsort (Tags' attributes sorter)
Vim plugin for sorting alphabetically the attributes of html-alike tags. It also enhances their format to improve readability.

## Example

Before:

        <TouchableOpacity z={1} onPress={() => onClick(id)} color="red" a={5} style={handleStyle()}>

After:

        <TouchableOpacity a={ 5 } color="red" onPress={ () => onClick(id) } style={ handleStyle() } z={ 1 } >


## Usage

This plugin works in normal mode. To use it, place your cursor anywhere inside a tag and then type the space character twice.

It also works if you place the cursor at the beginning of a line. In this case, the target tag would be the left-most in the current line.


## Installation

### Using Plug
``` vim
"Add the following line to your ~/.vimrc
Plug 'jose-villar/vim-tagattsort'

"Then, from within vim, run:
:PlugInstall
```


## Modification Of Default Mapping

This is easier to explain with an example: Let's pretend you wanted to change the default mapping to "<Leader>h". The way to accomplish this, is to add the following line to your vimrc

        nmap <unique><Leader>h <Plug>TagattsortNMode
