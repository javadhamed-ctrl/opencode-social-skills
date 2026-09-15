param(
    [string]$WindowTitle = 'Bale Web',
    [string]$KeyName = 'Enter'
)

$sigSrc = @'
using System;
using System.Runtime.InteropServices;
using System.Text;

public class ActWin {
    [DllImport("user32.dll")] public static extern IntPtr GetForegroundWindow();
    [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr hwnd);
    [DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr hwnd, int nCmdShow);
    [DllImport("user32.dll")] public static extern bool EnumWindows(EnumProc cb, IntPtr lp);
    [DllImport("user32.dll")] public static extern int GetWindowText(IntPtr hwnd, StringBuilder sb, int max);
    [DllImport("user32.dll")] public static extern bool IsWindowVisible(IntPtr hwnd);
    public delegate bool EnumProc(IntPtr hwnd, IntPtr lp);

    [StructLayout(LayoutKind.Sequential)]
    public struct KEYBDINPUT {
        public ushort wVk; public ushort wScan; public uint dwFlags; public uint time;
        public IntPtr dwExtraInfo; public uint unused1; public uint unused2;
    }
    [StructLayout(LayoutKind.Sequential)]
    public struct INPUT { public uint type; public KEYBDINPUT ki; }
    [DllImport("user32.dll", SetLastError=true)]
    public static extern uint SendInput(uint n, INPUT[] ins, int size);

    public const uint KEYEVENTF_KEYUP = 0x0002;

    public static IntPtr FindVisibleByPrefix(string prefix) {
        IntPtr found = IntPtr.Zero;
        EnumWindows((hwnd, lp) => {
            if (found != IntPtr.Zero) return false;
            if (!IsWindowVisible(hwnd)) return true;
            StringBuilder sb = new StringBuilder(512);
            GetWindowText(hwnd, sb, 512);
            if (sb.Length > 0 && sb.ToString().StartsWith(prefix, StringComparison.OrdinalIgnoreCase)) {
                found = hwnd; return false;
            }
            return true;
        }, IntPtr.Zero);
        return found;
    }

    public static void BringToFront(IntPtr hwnd) {
        // release foreground lock
        INPUT key = new INPUT(); key.type = 1; key.ki.wVk = 0x12; // VK_MENU
        INPUT[] ins = new INPUT[2];
        ins[0] = key; key.ki.dwFlags = KEYEVENTF_KEYUP; ins[1] = key;
        SendInput(2, ins, Marshal.SizeOf(typeof(INPUT)));
        System.Threading.Thread.Sleep(80);
        SetForegroundWindow(hwnd);
        ShowWindow(hwnd, 9); // SW_RESTORE
        System.Threading.Thread.Sleep(150);
    }

    public static void PressKey(ushort vk) {
        INPUT[] ins = new INPUT[2];
        ins[0] = new INPUT(); ins[0].type = 1; ins[0].ki.wVk = vk; ins[0].ki.time = 0; ins[0].ki.dwExtraInfo = IntPtr.Zero;
        ins[1] = new INPUT(); ins[1].type = 1; ins[1].ki.wVk = vk; ins[1].ki.dwFlags = KEYEVENTF_KEYUP; ins[1].ki.time = 0; ins[1].ki.dwExtraInfo = IntPtr.Zero;
        uint r = SendInput(2, ins, Marshal.SizeOf(typeof(INPUT)));
        if (r == 0) throw new Exception("SendInput failed: " + Marshal.GetLastWin32Error());
    }
}
'@

if (-not ('ActWin' -as [type])) { Add-Type -TypeDefinition $sigSrc }

$hwnd = [ActWin]::FindVisibleByPrefix($WindowTitle)
if ($hwnd -eq [IntPtr]::Zero) { throw "Window not found: $WindowTitle" }
[ActWin]::BringToFront($hwnd)

$vk = 0x0D  # VK_RETURN (Enter)
if ($KeyName -eq 'Space') { $vk = 0x20 }
if ($KeyName -eq 'Tab') { $vk = 0x09 }

[ActWin]::PressKey($vk)
Start-Sleep -Milliseconds 400
"activated='$WindowTitle' hwnd=$hwnd sent='$KeyName'"