# ConEmu Colorscheme Graft

Use `.Xresources` color declarations as ConEmu colorschemes.

## Usage

#### **0. Create directory structure**

Open ConEmu "Settings" dialog to see where your ConEmu config file locates (`C:\Users\You\AppData\Roaming\ConEmu.xml` by default). Go to the directory where `ConEmu.xml` locates, and then:

- Create a sub-directory named `ConEmu_Colorschemes`.
- Paste the `graft.ps1` there.

#### **1. Prepare `.Xresources` file**

Save the Xsources content with the following pattern to a file as `ConEmu_Colorschemes/[NAME].Xresources`, where `[NAME]` stands for the colorscheme name.

    *.color0:       #1c1b19
    *.color8:       #918175
    *.color2:       #519f50
    *.color10:      #98bc37

For example, in order to apply [hybrid.vim](https://gist.github.com/w0ng/3278077) colorscheme, create `ConEmu_Colorschemes/hybrid.vim.Xresources` and paste the given stuff into it. And now you should have the following dir structure:

    .
    graft.ps1
    ConEmu.xml
    ConEmu_Colorschemes
      |- hybrid.vim.Xresources

#### **2. Run the script**

Run the PowerShell script `graft.ps1`. The config file `ConEmu.xml` will be updated and the previous one will be saved as `ConEmu.bak.xml`.

#### **3. Reload ConEmu configuration file**

Restart ConEmu or reload configuration file in ConEmu. Check whether there is something new in "Setting" dialog -> Features -> Colors -> Schemes.

#### **Then, add more**

Free feel to create other `ConEmu_Colorschemes/*.Xresources` for more ConEmu colorschemes.
