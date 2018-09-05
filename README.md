# cli_psp2sdk-addon
Some small tools for PS Vita development

# psp2psarc_utils
* (psp2psarc_info file.psarc)
* psp2psarc_extract file.psarc
  * dependencies: psp2psarc.exe
* psp2psarc_list file.psarc
  * dependencies: psp2psarc.exe
* psp2psarc_xml file.psarc
* psp2psarc_create file_new.xml
  * dependencies: psp2psarc.exe
* (del /q file_list.txt)
* (del /q file_new.xml)

# elf_tools
* self2elf (unpack)
  * dependencies: [vita-unmake-fself.exe](https://github.com/CelesteBlue-dev/PSVita-RE-tools/raw/master/vita-unmake-fself/release/vita-unmake-fself.exe)
* elf2self (repack)
  * dependencies: [vita-elf-inject.exe](https://github.com/CelesteBlue-dev/PSVita-RE-tools/raw/master/elf_injector/build/vita-elf-inject.exe)
