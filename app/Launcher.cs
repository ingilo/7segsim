// Standalone launcher for 7-Segment Logic Lab.
// index.html is embedded as a resource; on start it is written to
// %LOCALAPPDATA%\7SegmentLogicLab and opened in an Edge/Chrome app window.
using System;
using System.Diagnostics;
using System.IO;
using System.Reflection;
using System.Windows.Forms;
using Microsoft.Win32;

[assembly: AssemblyTitle("7-Segment Logic Lab")]
[assembly: AssemblyProduct("7-Segment Logic Lab")]
[assembly: AssemblyDescription("Logic gate simulator for 7-segment displays")]
[assembly: AssemblyVersion("1.0.0.0")]
[assembly: AssemblyFileVersion("1.0.0.0")]

static class Program
{
    const string AppName = "7-Segment Logic Lab";

    [STAThread]
    static void Main()
    {
        try
        {
            // A fixed location keeps the page's autosave (localStorage) between runs.
            string dir = Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData), "7SegmentLogicLab");
            Directory.CreateDirectory(dir);
            string html = Path.Combine(dir, "index.html");
            using (Stream src = Assembly.GetExecutingAssembly().GetManifestResourceStream("index.html"))
            using (FileStream dst = File.Create(html))
            {
                src.CopyTo(dst);
            }

            string url = new Uri(html).AbsoluteUri;
            string browser = FindBrowser();
            if (browser != null)
            {
                ProcessStartInfo psi = new ProcessStartInfo(browser, "--app=\"" + url + "\" --window-size=1440,900");
                psi.UseShellExecute = false;
                Process.Start(psi);
            }
            else
            {
                Process.Start(html); // default browser as a fallback
            }
        }
        catch (Exception ex)
        {
            MessageBox.Show("Could not start " + AppName + ":\n\n" + ex.Message, AppName,
                MessageBoxButtons.OK, MessageBoxIcon.Error);
        }
    }

    static string FindBrowser()
    {
        foreach (string exe in new[] { "msedge.exe", "chrome.exe" })
        {
            foreach (RegistryKey root in new[] { Registry.CurrentUser, Registry.LocalMachine })
            {
                using (RegistryKey key = root.OpenSubKey(@"SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\" + exe))
                {
                    string path = key == null ? null : key.GetValue(null) as string;
                    if (!string.IsNullOrEmpty(path) && File.Exists(path.Trim('"'))) return path.Trim('"');
                }
            }
        }
        string pf86 = Environment.GetFolderPath(Environment.SpecialFolder.ProgramFilesX86);
        string pf = Environment.GetFolderPath(Environment.SpecialFolder.ProgramFiles);
        foreach (string path in new[] {
            Path.Combine(pf86, @"Microsoft\Edge\Application\msedge.exe"),
            Path.Combine(pf, @"Microsoft\Edge\Application\msedge.exe"),
            Path.Combine(pf, @"Google\Chrome\Application\chrome.exe") })
        {
            if (File.Exists(path)) return path;
        }
        return null;
    }
}
