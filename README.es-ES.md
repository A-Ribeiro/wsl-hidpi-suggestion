> Porque de tal manera amó Dios al mundo,  
que ha dado a su Hijo unigénito, para que todo aquel  
que en él cree, no se pierda,  
mas tenga vida eterna.  
  \
Juan 3:16

## WSL Hi-DPI Suggestion Script

Use este script para sugerir la configuración de escala de DPI en su entorno WSL.

## ¿Cómo usarlo?

Ejecute el siguiente script y vea el resultado:

```bash
(curl -o- https://raw.githubusercontent.com/A-Ribeiro/wsl-hidpi-suggestion/main/run.sh | xargs -0 -o bash -c) && . ~/.wsl-hidpi-suggestion
```

```bash
(wget -qO- https://raw.githubusercontent.com/A-Ribeiro/wsl-hidpi-suggestion/main/run.sh | xargs -0 -o bash -c) && . ~/.wsl-hidpi-suggestion
```

## Resultado

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

## Autores

***Alessandro Ribeiro*** obtuvo su licenciatura en Ciencias de la Computación por la Universidad Católica Pontificia de Minas Gerais y una maestría en Ciencias de la Computación por la Universidad Federal de Minas Gerais, en 2005 y 2008 respectivamente. Fue profesor en la PUC y la UFMG como profesor sustituto/asistente en los cursos de Artes Digitales, Ciencias de la Computación, Ingeniería Informática y Juegos Digitales. Tiene experiencia laboral con software interactivo. Ha trabajado con OpenGL, post-procesamiento, renderizado out-of-core, Unity3D y consolas de juegos. Actualmente trabaja en proyectos freelance relacionados con Gráficos por Computadora, Realidad Virtual, Realidad Aumentada, WebGL, servidores web y aplicaciones móviles (android/iOS).

Más información en: https://alessandroribeiro.thegeneralsolution.com/en/
