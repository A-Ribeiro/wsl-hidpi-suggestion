> For this is how God loved the world:  
he gave his only Son, so that everyone  
who believes in him may not perish  
but may have eternal life.  
  \
John 3:16

## WSL Hi-DPI Suggestion Script

Use this script to suggest DPI scale configuration to your WSL environment.

## How to Use?

Run the following script, and see the result:

```bash
(curl -o- https://raw.githubusercontent.com/A-Ribeiro/wsl-hidpi-suggestion/main/run.sh | xargs -0 -o bash -c) && . ~/.wsl-hidpi-suggestion
```

```bash
(wget -qO- https://raw.githubusercontent.com/A-Ribeiro/wsl-hidpi-suggestion/main/run.sh | xargs -0 -o bash -c) && . ~/.wsl-hidpi-suggestion
```

## Result

```
1) [DPI 100%]
2) DPI 125%
3) DPI 150%
4) DPI 175%
5) DPI 200%
6) DPI 225%
7) DPI 250%
Select the zoom you want to apply: 1

# wsl-hidpi-suggestion
# 
# Variable suggestion to use in the following files:
#   ~/.bashrc
#   /etc/profile
# 
# DPI scale info:
#  - Main size
#      (px): 2560x1600
#      (mm): 344x215
#      (DPI-100%): 189.023257 DPI
#  - Scale set to: 1.968992
# 
export GDK_SCALE=1.968992
export GDK_DPI_SCALE=1.968992
export GTK_SCALE=1.968992
export QT_SCALE_FACTOR=1.968992

creating ~/.wsl-hidpi-suggestion

Do you want to add changes to ~/.bashrc? (yes/no) y

adding '. ~/.wsl-hidpi-suggestion' to ~/.bashrc
 - adding entry to ~/.bashrc
```

## Authors

***Alessandro Ribeiro da Silva*** obtained his Bachelor's degree in Computer Science from Pontifical Catholic 
University of Minas Gerais and a Master's degree in Computer Science from the Federal University of Minas Gerais, 
in 2005 and 2008 respectively. He taught at PUC and UFMG as a substitute/assistant professor in the courses 
of Digital Arts, Computer Science, Computer Engineering and Digital Games. He have work experience with interactive
software. He worked with OpenGL, post-processing, out-of-core rendering, Unity3D and game consoles. Today 
he work with freelance projects related to Computer Graphics, Virtual Reality, Augmented Reality, WebGL, web server 
and mobile apps (andoid/iOS).

More information on: https://alessandroribeiro.thegeneralsolution.com/en/
