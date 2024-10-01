#!/bin/bash

powershell_script='
Add-Type @"
using System.Runtime.InteropServices;
using System;
using System.Globalization;

[StructLayout(LayoutKind.Sequential, CharSet = CharSet.Ansi)]
public struct DEVMODEA
{
    public const int DMDO_DEFAULT = 0;
    public const int DMDO_D90 = 1;
    public const int DMDO_D180 = 2;
    public const int DMDO_D270 = 3;

    public const int DM_PELSWIDTH = 0x80000;
    public const int DM_PELSHEIGHT = 0x100000;
    private const int CCHDEVICENAME = 32;
    private const int CCHFORMNAME = 32;

    [MarshalAs(UnmanagedType.ByValTStr, SizeConst = CCHDEVICENAME)]
    public string dmDeviceName;
    public short dmSpecVersion;
    public short dmDriverVersion;
    public short dmSize;
    public short dmDriverExtra;
    public int dmFields;

    public int dmPositionX;
    public int dmPositionY;
    public int dmDisplayOrientation; // DMDO
    public int dmDisplayFixedOutput;

    public short dmColor;
    public short dmDuplex;
    public short dmYResolution;
    public short dmTTOption;
    public short dmCollate;
    [MarshalAs(UnmanagedType.ByValTStr, SizeConst = CCHFORMNAME)]
    public string dmFormName;
    public short dmLogPixels;
    public int dmBitsPerPel;
    public int dmPelsWidth;
    public int dmPelsHeight;
    public int dmDisplayFlags;
    public int dmDisplayFrequency;
    public int dmICMMethod;
    public int dmICMIntent;
    public int dmMediaType;
    public int dmDitherType;
    public int dmReserved1;
    public int dmReserved2;
    public int dmPanningWidth;
    public int dmPanningHeight;
}

public class DCOps {

    [DllImport("user32.dll")] public static extern IntPtr GetDC(IntPtr hwnd);
    [DllImport("user32.dll")] public static extern int ReleaseDC(IntPtr hwnd, IntPtr hdc);
    [DllImport("gdi32.dll")] public static extern int GetDeviceCaps(IntPtr hdc, int nIndex);

    public const int HORZRES = 8;
    public const int VERTRES = 10;
    public const int HORZSIZE = 4;
    public const int VERTSIZE = 6;
    public const int DESKTOPVERTRES = 117;
    public const int DESKTOPHORZRES = 118;
    public const int LOGPIXELSX = 88;
    public const int LOGPIXELSY = 90;

    [DllImport("user32.dll", CharSet = CharSet.Ansi, SetLastError = true)]
    public static extern bool EnumDisplaySettingsA(string deviceName, int modeNum, ref DEVMODEA devMode);

    public const int ENUM_CURRENT_SETTINGS = -1;

    public static string mainDisplay = "\\\\.\\DISPLAY1";

    [DllImport("kernel32.dll")]
    static extern IntPtr GetCurrentProcess();

    [DllImport("shcore.dll")]
    static extern int GetProcessDpiAwareness(IntPtr hprocess, out int lpdpiAwareness);
    [DllImport("shcore.dll")]
    static extern int SetProcessDpiAwareness(int value);

    public const int PROCESS_DPI_UNAWARE = 0;
    public const int PROCESS_SYSTEM_DPI_AWARE = 1;
    public const int PROCESS_PER_MONITOR_DPI_AWARE = 2;

    
    [DllImport("Shcore.dll")]
    static extern int GetDpiForMonitor(IntPtr hmonitor, uint dpiType, out uint dpiX, out uint dpiY);

    public const uint MDT_EFFECTIVE_DPI = 0;
    public const uint MDT_ANGULAR_DPI = 1;
    public const uint MDT_RAW_DPI = 2;

    [DllImport("user32.dll")]
    static extern IntPtr MonitorFromWindow(IntPtr hwnd, uint dwFlags);

    public const uint MONITOR_DEFAULTTONULL       = 0;
    public const uint MONITOR_DEFAULTTOPRIMARY    = 1;
    public const uint MONITOR_DEFAULTTONEAREST    = 2;

    [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Ansi)]
    public struct RECT
    {
        public int left;
        public int top;
        public int right;
        public int bottom;
    }

    [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Ansi)]
    public struct MONITORINFOEXA
    {
        public uint cbSize;
        public RECT rcMonitor;
        public RECT rcWork;
        public uint dwFlags;
        [MarshalAs(UnmanagedType.ByValTStr, SizeConst = 32)]
        public string deviceName;
    }

    [DllImport("user32.dll")]
    static extern bool GetMonitorInfoA(IntPtr hmonitor, ref MONITORINFOEXA lpmi);


    [DllImport("user32.dll")]
    static extern IntPtr GetDesktopWindow();

    public static void run() {
        SetProcessDpiAwareness(PROCESS_PER_MONITOR_DPI_AWARE);

        var hwnd = GetDesktopWindow();

        var hdc = GetDC(hwnd);
        if (hdc == IntPtr.Zero){
            Console.WriteLine("1,1,1,1,1,DPI 100%");
            return;
        }

        var hmonitor = MonitorFromWindow(hwnd, MONITOR_DEFAULTTOPRIMARY);
        if (hmonitor == IntPtr.Zero){
            Console.WriteLine("2,2,2,2,1,DPI 100%");
            ReleaseDC(hwnd, hdc);
            return;
        }

        var mi = new MONITORINFOEXA();
        mi.cbSize = (uint)Marshal.SizeOf(typeof(MONITORINFOEXA));

        if (!GetMonitorInfoA(hmonitor, ref mi)){
            Console.WriteLine("3,3,3,3,1,DPI 100%");
            ReleaseDC(hwnd, hdc);
            return;
        }

        var devMode = new DEVMODEA();
        devMode.dmSize = (short)Marshal.SizeOf(typeof(DEVMODEA));

        if (!EnumDisplaySettingsA(mi.deviceName, ENUM_CURRENT_SETTINGS, ref devMode)){
            Console.WriteLine("4,4,4,4,1,DPI 100%");
            ReleaseDC(hwnd, hdc);
            return;
        }

        //var w=GetDeviceCaps(hdc, DESKTOPHORZRES);
        //var h=GetDeviceCaps(hdc, DESKTOPVERTRES);
        
        var w = devMode.dmPelsWidth;
        var h = devMode.dmPelsHeight;

        var wm = GetDeviceCaps(hdc, HORZSIZE);
        var hm = GetDeviceCaps(hdc, VERTSIZE);

        var width_virtual_pixels = GetDeviceCaps(hdc, HORZRES);
        var height_virtual_pixels = GetDeviceCaps(hdc, VERTRES);

        var scaleFactor = ((double)w / (double)(width_virtual_pixels)+
							(double)h / (double)(height_virtual_pixels)) * 0.5;
        scaleFactor = Math.Round(scaleFactor * 100.0) / 100.0;

        int processDpiAwareness;
        if (GetProcessDpiAwareness(GetCurrentProcess(), out processDpiAwareness) >= 0) {
            if (processDpiAwareness == PROCESS_PER_MONITOR_DPI_AWARE) {
                uint dpiX, dpiY;
                if (GetDpiForMonitor(hmonitor, MDT_EFFECTIVE_DPI, out dpiX, out dpiY) >= 0)
                {
                    double scale_x = (double)dpiX;
                    double scale_y = (double)dpiY;
                    double scale = (scale_x + scale_y) * 0.5;
                    scale = Math.Round(scale);
                    scale = scale / 96.0;
                    scaleFactor = scale;
                }
            } else if (processDpiAwareness == PROCESS_SYSTEM_DPI_AWARE) {
                int dpiX = GetDeviceCaps(hdc, LOGPIXELSX);
                int dpiY = GetDeviceCaps(hdc, LOGPIXELSY);
                double scale_x = (double)dpiX;
                double scale_y = (double)dpiY;
                double scale = (scale_x + scale_y) * 0.5;
                scale = Math.Round(scale);
                scale = scale / 96.0;
                scaleFactor = scale;
            }
        }

        ReleaseDC(hwnd, hdc);

        var dpi_str = String.Format(CultureInfo.InvariantCulture,"DPI {0}%", Math.Round( scaleFactor * 100.0 ) ) ;
        Console.WriteLine(
            String.Format(CultureInfo.InvariantCulture,"{0},{1},{2},{3},{4},{5}", w, h, wm, hm, scaleFactor, dpi_str)
        );

    }
}
"@

[DCOps]::run()
'

dpi_scale_suggestion() {

    MainDisplayInfo=$("/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe" "$powershell_script")
    # set -f # avoid globbing (expansion of *).
    # array=(${MainDisplayInfo//,/ })
    # array=(`echo $MainDisplayInfo | sed 's/,/\n/g'`)
    array=(`echo -e "$MainDisplayInfo" | tr ' ' '_' | tr ',' '\n'`)
    
    w=`echo -e "${array[0]}" | tr '_' ' ' | tr -d '\r\n'` # width in px
    h=`echo -e "${array[1]}" | tr '_' ' ' | tr -d '\r\n'` # height in px
    wm=`echo -e "${array[2]}" | tr '_' ' ' | tr -d '\r\n'` # width in mm
    hm=`echo -e "${array[3]}" | tr '_' ' ' | tr -d '\r\n'` # height in mm
    current_zoom=`echo -e "${array[4]}" | tr '_' ' ' | tr -d '\r\n'` # DPI scale
    dpi_str=`echo -e "${array[5]}" | tr '_' ' ' | tr -d '\r\n'` # DPI str
    
    dpi_100_percent=`python3 -c "print('%f' % ($w / ($wm / 25.4)) )"`
    dpi_scale=`python3 -c "print('%f' % (($w * 25.4) / ($wm * 96)) )"`

    # echo "current zoom: $current_zoom"
    # echo "DPI zoom: $dpi_str"

    zoom=1.0
    PS3="Select the zoom you want to apply: "
    options=("DPI 100%" "DPI 125%" "DPI 150%" "DPI 175%" "DPI 200%" "DPI 225%" "DPI 250%")
    options2=()
    for element in "${options[@]}"
    do
        if [[ "$element" == "$dpi_str" ]]; then
            options2+=("[${element}]")
        else
            options2+=("$element")
        fi
    done
    select opt in "${options2[@]}"
    do
        case $REPLY in
            1)
                zoom=1.0
                break
                ;;
            2)
                zoom=1.25
                break
                ;;
            3)
                zoom=1.5
                break
                ;;
            4)
                zoom=1.75
                break
                ;;
            5)
                zoom=2.0
                break
                ;;
            6)
                zoom=2.25
                break
                ;;
            7)
                zoom=2.5
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
    echo ""

while true; do
    read -p "Do you want to add changes to ~/.bashrc? (yes/no) " yn
    case $yn in
        [Yy]* ) 
            echo ""
            echo "adding '. ~/.wsl-hidpi-suggestion' to ~/.bashrc"
            if `grep -Fxq ". ~/.wsl-hidpi-suggestion" ~/.bashrc`
            then
                echo " - entry already added to ~/.bashrc"
            else
                echo " - adding entry to ~/.bashrc"
                echo -e "\n. ~/.wsl-hidpi-suggestion" >> ~/.bashrc
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
    exit 1
fi
