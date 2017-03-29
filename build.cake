/*****************************************************************************************************
Packer Build Script
Author: Wil Taylor
*****************************************************************************************************/
#addin "Cake.Powershell"

var target = Argument("target", "Default");
var cm = Argument("cm", "nocm");
var hypervisor = Argument("hypervisor", "virtualbox");

var RepoRootFolder = MakeAbsolute(Directory(".")); 
var osdir = RepoRootFolder + "/osconfig";
var PackerCacheFolder = RepoRootFolder + "/packer_cache";
var BoxFolder = RepoRootFolder + "/box";
var testFolder = RepoRootFolder + "/test";

Task("Clean")
    .IsDependentOn("Clean.PackerCache")
    .IsDependentOn("Clean.Box");

Task("Clean.Box")
    .Does(() => CleanDirectory(BoxFolder));

Task("Clean.PackerCache")
    .Does(() => CleanDirectory(PackerCacheFolder));

Task("VMware.CopyTools")
    .WithCriteria(hypervisor == "vmware")
    .WithCriteria()
    .WithCriteria(!FileExists(RepoRootFolder + "/vmtools/vmware/vmtools.exe"))
    .Does(() => {
        if(FileExists("C:/Program Files (x86)/VMware/VMware Workstation/tools-upgraders/VMwareToolsUpgrader.exe"))
            CopyFile("C:/Program Files (x86)/VMware/VMware Workstation/tools-upgraders/VMwareToolsUpgrader.exe", RepoRootFolder + "/vmtools/vmware/vmtools.exe"));
        else
            System.IO.File.WriteAll(RepoRootFolder + "/vmtools/vmware/vmtools.exe", "");
        };

var buildbase = Task("Build.Base");
var patchbase = Task("Build.Patch");

Array.ForEach(System.IO.Directory.GetDirectories(osdir), folder =>
{
    var osName = System.IO.Path.GetFileName(folder);
    var baseboxfile = "box/" + osName + "-base-" + cm + "-" + hypervisor + ".box";
    var patchboxfile = RepoRootFolder + "/box/" + osName + "-patch-" + cm + "-" + hypervisor +".box";

    if(osName.ToLower().Contains("disabled"))
        return;

    buildbase.IsDependentOn("Build.Base." + osName);

    Task("Build.Base." + osName)
        .IsDependentOn("VMware.CopyTools")
        .WithCriteria(!FileExists(baseboxfile))
        .Does(() => StartPacker(osName, "base"));

    Task("Debug.Base." + osName)
        .IsDependentOn("VMware.CopyTools")
        .WithCriteria(!FileExists(baseboxfile))
        .Does(() => StartPacker(osName, "base", debug: true));

    Task("Test.Base." + osName)
        .WithCriteria(FileExists(baseboxfile))
        .Does(() => 
        {
            var ret = StartProcess("powershell", "-executionpolicy bypass -noprofile -noninteractive -file \"" + testFolder + "/RunTests.ps1\" -box \"" + baseboxfile + "\" -hypervisor " + hypervisor + " -boxname Base." + osName + "." + hypervisor);
            if(ret != 0)
                throw new Exception("Tests failed!");
        });
            

    patchbase.IsDependentOn("Build.Patch." + osName);

    Task("Build.Patch." + osName)
        .IsDependentOn("VMware.CopyTools")
        .WithCriteria(!FileExists(patchboxfile))
        .Does(() => StartPacker(osName, "patch", patch: true));

    Task("Debug.Patch." + osName)
        .IsDependentOn("VMware.CopyTools")
        .WithCriteria(!FileExists(patchboxfile))
        .Does(() => StartPacker(osName, "patch", debug: true, patch: true));

    Task("Test.Patch." + osName)
        .WithCriteria(FileExists(patchboxfile))
        .Does(() => 
        {
            var ret = StartProcess("powershell", "-executionpolicy bypass -noprofile -noninteractive -file \"" + testFolder + "/RunTests.ps1\" -box \"" + patchboxfile + "\" -hypervisor " + hypervisor + " -boxname Patch." + osName + "." + hypervisor);
            if(ret != 0)
                throw new Exception("Tests failed!");
        });           

});

void StartPacker(string os, string tag, bool debug=false, bool patch=false) 
{

    var command = "build -var-file=\"osconfig\\" + os + "\\vars.json\" -var boxtag=" + tag + " -var cm=" + cm + " -only=" + hypervisor + " "; 

    if(patch)
        command += "-var patchvm=true ";
    else
        command += "-var patchvm=false ";

    if(debug)
        command += "-debug ";

    command += " .\\packerbase.json";

    StartProcess("packer", command);
}

/*****************************************************************************************************
End of script
*****************************************************************************************************/
RunTarget(target);