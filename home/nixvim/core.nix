{ ... }:

{
  programs.nixvim = {
    globals = {
      mapleader = " ";
      maplocalleader = " ";
      translate_source = "ru";
      translate_target = "en";
    };

    opts = {
      backup = false;
      breakindent = true;
      completeopt = [
        "menuone"
        "noselect"
      ];
      cursorline = true;
      encoding = "utf-8";
      expandtab = true;
      fileformat = "unix";
      fileformats = [
        "unix"
        "dos"
        "mac"
      ];
      hlsearch = false;
      ignorecase = true;
      incsearch = true;
      lazyredraw = true;
      mouse = "a";
      number = true;
      relativenumber = true;
      scrolloff = 8;
      shiftwidth = 4;
      showcmd = true;
      showmatch = true;
      showmode = true;
      signcolumn = "yes";
      smartcase = true;
      smartindent = true;
      softtabstop = 4;
      splitbelow = true;
      splitright = true;
      swapfile = false;
      tabstop = 4;
      termguicolors = true;
      title = true;
      undofile = true;
      virtualedit = "all";
      wrap = false;
    };
  };
}
