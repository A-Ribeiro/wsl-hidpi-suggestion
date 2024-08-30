#!/bin/bash

powershell_script='
Add-Type @"
using System;
using System.Runtime.InteropServices;
public class DCOps {
    [DllImport("user32.dll")] public static extern IntPtr GetDC(IntPtr hwnd);
    [DllImport("user32.dll")] public static extern int ReleaseDC(IntPtr hwnd, IntPtr hdc);
    [DllImport("gdi32.dll")] public static extern int GetDeviceCaps(IntPtr hdc, int nIndex);

    public static int HORZSIZE = 4;
    public static int VERTSIZE = 6;
    public static int DESKTOPVERTRES = 117;
    public static int DESKTOPHORZRES = 118;
}
"@

$hdc = [DCOps]::GetDC([IntPtr]::Zero)
if ($hdc -eq [IntPtr]::Zero){
    echo "1,1,1,1"
    exit
}
$w=[DCOps]::GetDeviceCaps($hdc, [DCOps]::DESKTOPHORZRES)
$h=[DCOps]::GetDeviceCaps($hdc, [DCOps]::DESKTOPVERTRES)

$wm=[DCOps]::GetDeviceCaps($hdc, [DCOps]::HORZSIZE)
$hm=[DCOps]::GetDeviceCaps($hdc, [DCOps]::VERTSIZE)

$rc=[DCOps]::ReleaseDC([IntPtr]::Zero, $hdc)

echo "$w,$h,$wm,$hm"
'

dpi_scale_suggestion() {

    MainDisplayInfo=$("/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe" "$powershell_script")
    # set -f # avoid globbing (expansion of *).
    # array=(${MainDisplayInfo//,/ })
    # array=(`echo $MainDisplayInfo | sed 's/,/\n/g'`)
    array=(`echo $MainDisplayInfo | tr ',' '\n'`)
    w=${array[0]} # width in px
    h=${array[1]} # height in px
    wm=${array[2]} # width in mm
    hm=${array[3]} # height in mm
    dpi_100_percent=`python3 -c "print('%f' % ($w / ($wm / 25.4)) )"`
    dpi_scale=`python3 -c "print('%f' % (($w * 25.4) / ($wm * 96)) )"`

    zoom=1.0
    PS3='Select the zoom you want to apply: '
    options=("DPI 100%" "DPI 125%" "DPI 150%" "DPI 175%" "DPI 200%")
    select opt in "${options[@]}"
    do
        case $opt in
            "DPI 100%")
                zoom=1.0
                break
                ;;
            "DPI 125%")
                zoom=1.25
                break
                ;;
            "DPI 150%")
                zoom=1.5
                break
                ;;
            "DPI 175%")
                zoom=1.75
                break
                ;;
            "DPI 200%")
                zoom=2.0
                break
                ;;
            *) echo "invalid option $REPLY";;
        esac
    done

    echo ""
    echo "# wsl-hidpi-suggestion"
    echo "# "
    echo "# Variable suggestion to use in the following files:"
    echo "#   ~/.bashrc"
    echo "#   /etc/profile"
    echo "# "
    echo "# DPI scale info:"
    echo "#  - Main size"
    echo "#      (px): ${w}x${h}"
    echo "#      (mm): ${wm}x${hm}"

    percent_str=`python3 -c "print('%.0f' % round($zoom * 100))"`

    dpi_custom_percent=`python3 -c "print('%.6f' % round($dpi_100_percent * $zoom, 6))"`
    dpi_scale_custom=`python3 -c "print('%.6f' % round($dpi_scale * $zoom, 6))"`

    echo "#      (DPI-$percent_str%): ${dpi_custom_percent} DPI"
    echo "#  - Scale set to: $dpi_scale_custom"
    echo "# "
    echo "export GDK_SCALE=${dpi_scale_custom}"
    echo "export GDK_DPI_SCALE=${dpi_scale_custom}"
    echo "export GTK_SCALE=${dpi_scale_custom}"
    # https://doc.qt.io/qt-5/highdpi.html
    # export QT_AUTO_SCREEN_SCALE_FACTOR=${QT_AUTO_SCREEN_SCALE_FACTOR:-1}
    # export QT_ENABLE_HIGHDPI_SCALING=${QT_ENABLE_HIGHDPI_SCALING:-1}
    echo "export QT_SCALE_FACTOR=${dpi_scale_custom}"
    echo ""

while true; do
    read -p "Do you want to add changes to ~./bashrc? (yes/no) " yn
    case $yn in
        [Yy]* ) 
            echo ""
            echo "creating ~/.wsl-hidpi-suggestion"
            
            echo "# wsl-hidpi-suggestion" > ~/.wsl-hidpi-suggestion
            echo "# " >> ~/.wsl-hidpi-suggestion
            echo "# Variable suggestion to use in the following files:" >> ~/.wsl-hidpi-suggestion
            echo "#   ~/.bashrc" >> ~/.wsl-hidpi-suggestion
            echo "#   /etc/profile" >> ~/.wsl-hidpi-suggestion
            echo "# " >> ~/.wsl-hidpi-suggestion
            echo "# DPI scale info:" >> ~/.wsl-hidpi-suggestion
            echo "#  - Main size" >> ~/.wsl-hidpi-suggestion
            echo "#      (px): ${w}x${h}" >> ~/.wsl-hidpi-suggestion
            echo "#      (mm): ${wm}x${hm}" >> ~/.wsl-hidpi-suggestion
            echo "#      (DPI-$percent_str%): ${dpi_custom_percent} DPI" >> ~/.wsl-hidpi-suggestion
            echo "#  - Scale set to: $dpi_scale_custom" >> ~/.wsl-hidpi-suggestion
            echo "# " >> ~/.wsl-hidpi-suggestion
            echo "export GDK_SCALE=${dpi_scale_custom}" >> ~/.wsl-hidpi-suggestion
            echo "export GDK_DPI_SCALE=${dpi_scale_custom}" >> ~/.wsl-hidpi-suggestion
            echo "export GTK_SCALE=${dpi_scale_custom}" >> ~/.wsl-hidpi-suggestion
            echo "export QT_SCALE_FACTOR=${dpi_scale_custom}" >> ~/.wsl-hidpi-suggestion


            echo "adding '. ~/.wsl-hidpi-suggestion' to ~/.bashrc"
            if `grep -Fxq ". ~/.wsl-hidpi-suggestion" ~/.bashrc`
            then
                echo " - entry already added to ~/.bashrc"
            else
                echo " - adding entry to ~/.bashrc"
                echo ". ~/.wsl-hidpi-suggestion" >> ~/.bashrc
            fi

            break
        ;;
        [Nn]* ) 

            break
        ;;
        * ) echo "Possible answer: yes or no.";;
    esac
done

    export GDK_SCALE=${dpi_scale_custom}
    export GDK_DPI_SCALE=${dpi_scale_custom}
    export GTK_SCALE=${dpi_scale_custom}
    export QT_SCALE_FACTOR=${dpi_scale_custom}

}

# if dir runtime-dir exists, then ... 
if [[ -d /mnt/wslg/runtime-dir ]] ; then
    dpi_scale_suggestion
else
    echo 'ERROR: Not a WSL Environment'
fi
