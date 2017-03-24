/*****************************************************************************************************
Packer Build Script
Author: Wil Taylor
*****************************************************************************************************/
var target = Argument("target", "Default");
var cm = Argument("cm", "nocm");

var RepoRootFolder = MakeAbsolute(Directory(".")); 
var osdir = RepoRootFolder + "/osconfig";
var PackerCacheFolder = RepoRootFolder + "/packer_cache";
var BoxFolder = RepoRootFolder + "/box";
var oslist = GetOSList();
var hypervisors = GetHypervisors();

Task("ListOS")
    .Does(() => {
        Information("Available OS Templates:");
        foreach(var os in oslist)
            Information(os);
    });

Task("ListHypervisor")
    .Does(() => {
        Information("Available Hypervisors:");
        foreach(var h in hypervisors)
            Information(h);
    });

Task("Clean")
    .IsDependentOn("Clean.PackerCache")
    .IsDependentOn("Clean.Box");

Task("Clean.Box")
    .Does(() => CleanDirectory(BoxFolder));

Task("Clean.PackerCache")
    .Does(() => CleanDirectory(PackerCacheFolder));

Task("Build.Base")
    .IsDependentOn("Build.Base.Windows7x86")
    .IsDependentOn("Build.Base.Windows7x64")
    .IsDependentOn("Build.Base.Windows8x86")
    .IsDependentOn("Build.Base.Windows8x64")
    .IsDependentOn("Build.Base.Windows81x86")
    .IsDependentOn("Build.Base.Windows81x64")
    .IsDependentOn("Build.Base.Windows10x86")
    .IsDependentOn("Build.Base.Windows10x64")
    .IsDependentOn("Build.Base.Windows2008R2")
    .IsDependentOn("Build.Base.Windows2008R2Core")
    .IsDependentOn("Build.Base.Windows2012")
    .IsDependentOn("Build.Base.Windows2012Core")
    .IsDependentOn("Build.Base.Windows2012R2")
    .IsDependentOn("Build.Base.Windows2012R2Core")
    .IsDependentOn("Build.Base.Windows2016")
    .IsDependentOn("Build.Base.Windows2016Core");

Task("Build.Base.Windows7x86")
    .Does(() => StartProcess("packer", "build -var-file=\"osconfig\\Windows 7 x86\\vars.json\" -var patchvm=false -var boxtag=base -var cm=" + cm +" .\\packerbase.json"));
Task("Build.Base.Windows7x64")
    .Does(() => StartProcess("packer", "build -var-file=\"osconfig\\Windows 7 x64\\vars.json\" -var patchvm=false -var boxtag=base -var cm=" + cm +" .\\packerbase.json"));
Task("Build.Base.Windows8x86")
    .Does(() => StartProcess("packer", "build -var-file=\"osconfig\\Windows 8 x86\\vars.json\" -var patchvm=false -var boxtag=base -var cm=" + cm +" .\\packerbase.json"));
Task("Build.Base.Windows8x64")
    .Does(() => StartProcess("packer", "build -var-file=\"osconfig\\Windows 8 x64\\vars.json\" -var patchvm=false -var boxtag=base -var cm=" + cm +" .\\packerbase.json"));
Task("Build.Base.Windows81x86")
    .Does(() => StartProcess("packer", "build -var-file=\"osconfig\\Windows 8.1 x86\\vars.json\" -var patchvm=false -var boxtag=base -var cm=" + cm +" .\\packerbase.json"));
Task("Build.Base.Windows81x64")
    .Does(() => StartProcess("packer", "build -var-file=\"osconfig\\Windows 8.1 x64\\vars.json\" -var patchvm=false -var boxtag=base -var cm=" + cm +" .\\packerbase.json"));
Task("Build.Base.Windows10x86") 
    .Does(() => StartProcess("packer", "build -var-file=\"osconfig\\Windows 10 x86\\vars.json\" -var patchvm=false -var boxtag=base -var cm=" + cm +" .\\packerbase.json"));
Task("Build.Base.Windows10x64")
    .Does(() => StartProcess("packer", "build -var-file=\"osconfig\\Windows 10 x64\\vars.json\" -var patchvm=false -var boxtag=base -var cm=" + cm +" .\\packerbase.json"));
Task("Build.Base.Windows2008R2")
    .Does(() => StartProcess("packer", "build -var-file=\"osconfig\\Windows 2008 R2\\vars.json\" -var patchvm=false -var boxtag=base -var cm=" + cm +" .\\packerbase.json"));
Task("Build.Base.Windows2008R2Core")
    .Does(() => StartProcess("packer", "build -var-file=\"osconfig\\Windows 2008 R2 Core\\vars.json\" -var patchvm=false -var boxtag=base -var cm=" + cm +" .\\packerbase.json"));
Task("Build.Base.Windows2012")
    .Does(() => StartProcess("packer", "build -var-file=\"osconfig\\Windows 2012\\vars.json\" -var patchvm=false -var boxtag=base -var cm=" + cm +" .\\packerbase.json"));
Task("Build.Base.Windows2012Core")
    .Does(() => StartProcess("packer", "build -var-file=\"osconfig\\Windows 2012 Core\\vars.json\" -var patchvm=false -var boxtag=base -var cm=" + cm +" .\\packerbase.json"));
Task("Build.Base.Windows2012R2")
    .Does(() => StartProcess("packer", "build -var-file=\"osconfig\\Windows 2012 R2\\vars.json\" -var patchvm=false -var boxtag=base -var cm=" + cm +" .\\packerbase.json"));
Task("Build.Base.Windows2012R2Core")
    .Does(() => StartProcess("packer", "build -var-file=\"osconfig\\Windows 2012 R2 Core\\vars.json\" -var patchvm=false -var boxtag=base -var cm=" + cm +" .\\packerbase.json"));
Task("Build.Base.Windows2016")
    .Does(() => StartProcess("packer", "build -var-file=\"osconfig\\Windows 2016\\vars.json\" -var patchvm=false -var boxtag=base -var cm=" + cm +" .\\packerbase.json"));
Task("Build.Base.Windows2016Core")
    .Does(() => StartProcess("packer", "build -var-file=\"osconfig\\Windows 2016 Core\\vars.json\" -var patchvm=false -var boxtag=base -var cm=" + cm +" .\\packerbase.json"));
//Task("Build.Base.NanoServer")
//    .Does(() => StartProcess("packer", "build -var-file=\"osconfig\\NanoServer\\vars.json\" -var patchvm=false -var boxtag=base -var cm=" + cm +" .\\packerbase.json"));

Task("Build.Patch")
    .IsDependentOn("Build.Patch.Windows7x86")
    .IsDependentOn("Build.Patch.Windows7x64")
    .IsDependentOn("Build.Patch.Windows8x86")
    .IsDependentOn("Build.Patch.Windows8x64")
    .IsDependentOn("Build.Patch.Windows81x86")
    .IsDependentOn("Build.Patch.Windows81x64")
    .IsDependentOn("Build.Patch.Windows10x86")
    .IsDependentOn("Build.Patch.Windows10x64")
    .IsDependentOn("Build.Patch.Windows2008R2")
    .IsDependentOn("Build.Patch.Windows2008R2Core")
    .IsDependentOn("Build.Patch.Windows2012")
    .IsDependentOn("Build.Patch.Windows2012Core")
    .IsDependentOn("Build.Patch.Windows2012R2")
    .IsDependentOn("Build.Patch.Windows2012R2Core")
    .IsDependentOn("Build.Patch.Windows2016")
    .IsDependentOn("Build.Patch.Windows2016Core");

Task("Build.Patch.Windows7x86")
    .Does(() => StartProcess("packer", "build -var-file=\"osconfig\\Windows7x86\\vars.json\" -var boxtag=patchedWMF5 -var cm=" + cm +" .\\packerbase.json"));
Task("Build.Patch.Windows7x64")
    .Does(() => StartProcess("packer", "build -var-file=\"osconfig\\Windows7x64\\vars.json\" -var boxtag=patchedWMF5 -var cm=" + cm +" .\\packerbase.json"));
Task("Build.Patch.Windows8x86")
    .Does(() => StartProcess("packer", "build -var-file=\"osconfig\\Windows8x86\\vars.json\" -var boxtag=patchedWMF5 -var cm=" + cm +" .\\packerbase.json"));
Task("Build.Patch.Windows8x64")
    .Does(() => StartProcess("packer", "build -var-file=\"osconfig\\Windows8x64\\vars.json\" -var boxtag=patchedWMF5 -var cm=" + cm +" .\\packerbase.json"));
Task("Build.Patch.Windows81x86")
    .Does(() => StartProcess("packer", "build -var-file=\"osconfig\\Windows8.1x86\\vars.json\" -var boxtag=patchedWMF5 -var cm=" + cm +" .\\packerbase.json"));
Task("Build.Patch.Windows81x64")
    .Does(() => StartProcess("packer", "build -var-file=\"osconfig\\Windows8.1x64\\vars.json\" -var boxtag=patchedWMF5 -var cm=" + cm +" .\\packerbase.json"));
Task("Build.Patch.Windows10x86") 
    .Does(() => StartProcess("packer", "build -var-file=\"osconfig\\Windows10x86\\vars.json\" -var boxtag=patchedWMF5 -var cm=" + cm +" .\\packerbase.json"));
Task("Build.Patch.Windows10x64")
    .Does(() => StartProcess("packer", "build -var-file=\"osconfig\\Windows10x64\\vars.json\" -var boxtag=patchedWMF5 -var cm=" + cm +" .\\packerbase.json"));
Task("Build.Patch.Windows2008R2")
    .Does(() => StartProcess("packer", "build -var-file=\"osconfig\\Windows2008R2\\vars.json\" -var boxtag=patchedWMF5 -var cm=" + cm +" .\\packerbase.json"));
Task("Build.Patch.Windows2008R2Core")
    .Does(() => StartProcess("packer", "build -var-file=\"osconfig\\Windows2008R2Core\\vars.json\" -var boxtag=patchedWMF5 -var cm=" + cm +" .\\packerbase.json"));
Task("Build.Patch.Windows2012")
    .Does(() => StartProcess("packer", "build -var-file=\"osconfig\\Windows2012\\vars.json\" -var boxtag=patchedWMF5 -var cm=" + cm +" .\\packerbase.json"));
Task("Build.Patch.Windows2012Core")
    .Does(() => StartProcess("packer", "build -var-file=\"osconfig\\Windows2012Core\\vars.json\" -var boxtag=patchedWMF5 -var cm=" + cm +" .\\packerbase.json"));
Task("Build.Patch.Windows2012R2")
    .Does(() => StartProcess("packer", "build -var-file=\"osconfig\\Windows2012R2\\vars.json\" -var boxtag=patchedWMF5 -var cm=" + cm +" .\\packerbase.json"));
Task("Build.Patch.Windows2012R2Core")
    .Does(() => StartProcess("packer", "build -var-file=\"osconfig\\Windows2012R2Core\\vars.json\" -var boxtag=patchedWMF5 -var cm=" + cm +" .\\packerbase.json"));
Task("Build.Patch.Windows2016")
    .Does(() => StartProcess("packer", "build -var-file=\"osconfig\\Windows2016\\vars.json\" -var boxtag=patchedWMF5 -var cm=" + cm +" .\\packerbase.json"));
Task("Build.Patch.Windows2016Core")
    .Does(() => StartProcess("packer", "build -var-file=\"osconfig\\Windows2016Core\\vars.json\" -var boxtag=patchedWMF5 -var cm=" + cm +" .\\packerbase.json"));
//Task("Build.Patch.NanoServer")
//    .Does(() => StartProcess("packer", "build -var-file=\"osconfig\\NanoServer\\vars.json\" -var boxtag=patchedWMF5 -var cm=" + cm +" .\\packerbase.json"));

string[] GetHypervisors()
{
    var result = new List<string>();

    if(FileExists(@"C:\Program Files\Oracle\VirtualBox\VirtualBox.exe"))
        result.Add("virtualbox");

    if(FileExists(@"C:\Program Files (x86)\VMware\VMware Workstation\vmware.exe"))
        result.Add("vmwareworkstation");

    if(FileExists(@"C:\Windows\system32\vmcompute.exe"))
    result.Add("hyperv");

    return result.ToArray();
}

/*****************************************************************************************************
End of script
*****************************************************************************************************/
RunTarget(target);