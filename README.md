# GarminMonkeyCBoilerPlate

Boilerplate with makefiles to quickly start new projects on Linux

Only tested on Ubuntu (KDE Neon, to be precise) with bash.

The highlight of the Makefiles is that you get free autocompletion
if you use a shell that supports it (should be working by default
on Debian/Ubuntu distros), and it's much faster to compile and run
the simulator with the corresponding make targets compared to tinkering
with the VSCode UI. Moreover, you can skip the UI completely and use
a command line editor. If you use vim, you can also have a look at the
monkey-c syntax highlighting plugin [here](https://github.com/cyberang3l/vim-monkey-c)

Note that you need to have some binaries installed to get things working
with all the features of the boilerplated code:
* `vim` and `xmllint` are used by the format-code script to format
   the code (`make format-code`)
* `inkscape` (command line) is used to convert the svg icon to png
* `uuidgen` is required for the `make gen_uuid` target to work

```
$ make <TAB><TAB>
all
build/
clean
clean-all
enduro3
enduro3-run-in-debugger
enduro3-run-in-simulator
export-for-iq-store
format-code
garmin-linux-development-environment/
gen_uuid
update_submodules
```
