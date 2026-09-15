param(
    [string]$KeyName = 'Enter'
)

$sigSrc = @'
using System;
using System.Runtime.InteropServices;
public class SendKey {
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
    public static void Press(ushort vk) {
        INPUT[] ins = new INPUT[2];
        ins[0] = new INPUT(); ins[0].type = 1; ins[0].ki.wVk = vk; ins[0].ki.time = 0; ins[0].ki.dwExtraInfo = IntPtr.Zero;
        ins[1] = new INPUT(); ins[1].type = 1; ins[1].ki.wVk = vk; ins[1].ki.dwFlags = KEYEVENTF_KEYUP; ins[1].ki.time = 0; ins[1].ki.dwExtraInfo = IntPtr.Zero;
        uint r = SendInput(2, ins, Marshal.SizeOf(typeof(INPUT)));
        if (r == 0) throw new Exception("SendInput failed: " + Marshal.GetLastWin32Error());
    }
}
'@

if (-not ('SendKey' -as [type])) { Add-Type -TypeDefinition $sigSrc }

$vk = 0x0D
if ($KeyName -eq 'Space') { $vk = 0x20 }
if ($KeyName -eq 'Tab') { $vk = 0x09 }

[SendKey]::Press($vk)
Start-Sleep -Milliseconds 300
"sent='$KeyName'"