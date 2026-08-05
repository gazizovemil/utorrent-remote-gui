# Embed Win32 manifest + application icon into utorrentgui.exe after link.
# Needed because Lazarus resource generation breaks on paths containing '#'.
$ErrorActionPreference = 'Stop'
$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
$Exe = Join-Path $Root 'utorrentgui.exe'
$Manifest = Join-Path $Root 'win32.manifest'
$Ico = Join-Path $Root 'images\app.ico'
if (-not (Test-Path $Exe)) { Write-Error "Missing $Exe"; exit 1 }

Add-Type -TypeDefinition @"
using System;
using System.IO;
using System.Runtime.InteropServices;
using System.Collections.Generic;
public static class EmbedRes {
  [DllImport("kernel32", SetLastError=true, CharSet=CharSet.Unicode)]
  static extern IntPtr BeginUpdateResource(string pFileName, bool bDeleteExistingResources);
  [DllImport("kernel32", SetLastError=true)]
  static extern bool UpdateResource(IntPtr hUpdate, IntPtr lpType, IntPtr lpName, ushort wLanguage, byte[] lpData, uint cbData);
  [DllImport("kernel32", SetLastError=true)]
  static extern bool EndUpdateResource(IntPtr hUpdate, bool fDiscard);

  public static int EmbedManifest(string exe, string manifestPath) {
    byte[] data = File.ReadAllBytes(manifestPath);
    IntPtr h = BeginUpdateResource(exe, false);
    if (h == IntPtr.Zero) return Marshal.GetLastWin32Error();
    if (!UpdateResource(h, (IntPtr)24, (IntPtr)1, 0, data, (uint)data.Length)) {
      int e = Marshal.GetLastWin32Error(); EndUpdateResource(h, true); return e;
    }
    if (!EndUpdateResource(h, false)) return Marshal.GetLastWin32Error();
    return 0;
  }

  public static int EmbedIcon(string exe, string icoPath) {
    byte[] ico = File.ReadAllBytes(icoPath);
    if (ico.Length < 6) return -1;
    ushort count = BitConverter.ToUInt16(ico, 4);
    var images = new List<byte[]>();
    var entries = new List<byte[]>();
    for (int i = 0; i < count; i++) {
      int e = 6 + i * 16;
      byte[] entry = new byte[16];
      Array.Copy(ico, e, entry, 0, 16);
      entries.Add(entry);
      uint size = BitConverter.ToUInt32(ico, e + 8);
      uint offset = BitConverter.ToUInt32(ico, e + 12);
      byte[] img = new byte[size];
      Array.Copy(ico, (int)offset, img, 0, (int)size);
      images.Add(img);
    }
    IntPtr h = BeginUpdateResource(exe, false);
    if (h == IntPtr.Zero) return Marshal.GetLastWin32Error();
    for (int i = 0; i < images.Count; i++) {
      if (!UpdateResource(h, (IntPtr)3, (IntPtr)(i + 1), 0, images[i], (uint)images[i].Length)) {
        int err = Marshal.GetLastWin32Error(); EndUpdateResource(h, true); return err;
      }
    }
    using (var ms = new MemoryStream())
    using (var bw = new BinaryWriter(ms)) {
      bw.Write((ushort)0); bw.Write((ushort)1); bw.Write(count);
      for (int i = 0; i < count; i++) {
        bw.Write(entries[i][0]); bw.Write(entries[i][1]);
        bw.Write(entries[i][2]); bw.Write(entries[i][3]);
        bw.Write(BitConverter.ToUInt16(entries[i], 4));
        bw.Write(BitConverter.ToUInt16(entries[i], 6));
        bw.Write(BitConverter.ToUInt32(entries[i], 8));
        bw.Write((ushort)(i + 1));
      }
      byte[] grp = ms.ToArray();
      if (!UpdateResource(h, (IntPtr)14, (IntPtr)1, 0, grp, (uint)grp.Length)) {
        int err = Marshal.GetLastWin32Error(); EndUpdateResource(h, true); return err;
      }
    }
    if (!EndUpdateResource(h, false)) return Marshal.GetLastWin32Error();
    return 0;
  }
}
"@ -ErrorAction SilentlyContinue

if (Test-Path $Manifest) {
  $c = [EmbedRes]::EmbedManifest($Exe, $Manifest)
  if ($c -ne 0) { Write-Error "Manifest embed failed: $c"; exit $c }
  Write-Host "Manifest OK"
}
if (Test-Path $Ico) {
  $c = [EmbedRes]::EmbedIcon($Exe, $Ico)
  if ($c -ne 0) { Write-Error "Icon embed failed: $c"; exit $c }
  Write-Host "Icon OK"
}
