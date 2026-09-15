param(
    [Parameter(Mandatory=$false)][string]$Text = '',
    [int]$BackspaceCount = 0,
    [int]$DelayMs = 20,
    [switch]$Paste
)

$sigSrc = @'
using System;
using System.Runtime.InteropServices;
public class UniInput {
    [StructLayout(LayoutKind.Sequential)]
    public struct KEYBDINPUT {
        public ushort wVk; public ushort wScan; public uint dwFlags; public uint time;
        public IntPtr dwExtraInfo; public uint unused1; public uint unused2;
    }
    [StructLayout(LayoutKind.Sequential)]
    public struct INPUT { public uint type; public KEYBDINPUT ki; }
    [DllImport("user32.dll", SetLastError=true)]
    public static extern uint SendInput(uint nInputs, INPUT[] pInputs, int cbSize);
    public const uint KEYEVENTF_UNICODE = 0x0004;
    public const uint KEYEVENTF_KEYUP = 0x0002;
    private static void SendSeq(INPUT[] ins) {
        uint r = SendInput((uint)ins.Length, ins, Marshal.SizeOf(typeof(INPUT)));
        if (r == 0) throw new Exception("SendInput failed: " + Marshal.GetLastWin32Error());
    }
    private static INPUT Key(uint type, ushort vk, ushort scan, uint flags) {
        INPUT i = new INPUT();
        i.type = type; i.ki.wVk = vk; i.ki.wScan = scan; i.ki.dwFlags = flags;
        i.ki.time = 0; i.ki.dwExtraInfo = IntPtr.Zero;
        return i;
    }
    private static void KeyPair(uint type, ushort vk, ushort scan, uint flags, int delayMs) {
        INPUT[] ins = new INPUT[2];
        ins[0] = Key(type, vk, scan, flags);
        ins[1] = Key(type, vk, scan, flags | KEYEVENTF_KEYUP);
        SendSeq(ins);
        if (delayMs > 0) System.Threading.Thread.Sleep(delayMs);
    }
    public static void TypeUnicode(string text, int delayMs) {
        foreach (char c in text) {
            if (c == '\n') {
                ShiftEnter(delayMs);
                continue;
            }
            KeyPair(1, 0, (ushort)c, KEYEVENTF_UNICODE, delayMs);
        }
    }
    public static void ShiftEnter(int delayMs) {
        INPUT[] ins = new INPUT[4];
        ins[0] = Key(1, 0x10, 0, 0);                      // shift down
        ins[1] = Key(1, 0x0D, 0, 0);                      // return down
        ins[2] = Key(1, 0x0D, 0, KEYEVENTF_KEYUP);        // return up
        ins[3] = Key(1, 0x10, 0, KEYEVENTF_KEYUP);        // shift up
        SendSeq(ins);
        if (delayMs > 0) System.Threading.Thread.Sleep(delayMs);
    }
    public static void PasteClipboard(int delayMs) {
        INPUT[] ins = new INPUT[6];
        ins[0] = Key(1, 0x11, 0, 0);           // ctrl down
        ins[1] = Key(1, 0x56, 0, 0);           // V down
        ins[2] = Key(1, 0x56, 0, KEYEVENTF_KEYUP); // V up
        ins[3] = Key(1, 0x11, 0, KEYEVENTF_KEYUP); // ctrl up
        SendSeq(ins);
        if (delayMs > 0) System.Threading.Thread.Sleep(delayMs);
    }
    public static void PressVk(ushort vk, int count, int delayMs) {
        for (int n = 0; n < count; n++) KeyPair(1, vk, 0, 0, delayMs);
    }
}
'@

if (-not ('UniInput' -as [type])) { Add-Type -TypeDefinition $sigSrc }
if ($BackspaceCount -gt 0) { [UniInput]::PressVk(0x08, $BackspaceCount, $DelayMs) }
if ($Paste) { [UniInput]::PasteClipboard($DelayMs) }
if ($Text) { [UniInput]::TypeUnicode($Text, $DelayMs) }