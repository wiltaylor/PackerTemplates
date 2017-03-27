/*****************************************************************************************************
Packer Build Script
Author: Wil Taylor
*****************************************************************************************************/
#addin "Cake.Powershell"

var target = Argument("target", "Default");
var cm = Argument("cm", "nocm");

var RepoRootFolder = MakeAbsolute(Directory(".")); 
var osdir = RepoRootFolder + "/osconfig";
var PackerCacheFolder = RepoRootFolder + "/packer_cache";
var BoxFolder = RepoRootFolder + "/box";
var hypervisors = GetHypervisors();
var testFolder = RepoRootFolder + "/test";

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


var buildbase = Task("Build.Base");
var patchbase = Task("Build.Patch");

Array.ForEach(System.IO.Directory.GetDirectories(osdir), folder =>
{
    var osName = System.IO.Path.GetFileName(folder);
    var baseboxfile = RepoRootFolder + "/box/" + osName + "-base-" + cm + "-virtualbox.box";
    var patchboxfile = RepoRootFolder + "/box/" + osName + "-patch-" + cm + "-virtualbox.box";

    if(osName.ToLower().Contains("disabled"))
        return;

    buildbase.IsDependentOn("Build.Base." + osName);

    Task("Build.Base." + osName)
        .WithCriteria(!FileExists(baseboxfile))
        .Does(() => StartPacker(osName, "base"));

    Task("Debug.Base." + osName)
        .WithCriteria(!FileExists(baseboxfile))
        .Does(() => StartPacker(osName, "base", debug: true));

    Task("Test.Base." + osName)
        .WithCriteria(FileExists(baseboxfile))
        .Does(() => 
        {
            var ret = StartProcess("powershell", "-executionpolicy bypass -noprofile -noninteractive -file \"" + testFolder + "/RunTests.ps1\" -box \"" + baseboxfile + "\" -hypervisor virtualbox");
            if(ret != 0)
                throw new Exception("Tests failed!");
        });
            

    patchbase.IsDependentOn("Build.Patch." + osName);

    Task("Build.Patch." + osName)
        .WithCriteria(!FileExists(patchboxfile))
        .Does(() => StartPacker(osName, "patch", patch: true));

    Task("Debug.Patch." + osName)
        .WithCriteria(!FileExists(patchboxfile))
        .Does(() => StartPacker(osName, "patch", debug: true, patch: true));

    Task("Test.Patch." + osName)
        .WithCriteria(FileExists(patchboxfile))
        .Does(() => StartPowershellFile(testFolder + "/Test-Box.ps1", 
            args => args
                .Append("boxpath",patchboxfile)
                .Append("hypervisor","virtualbox")
                .Append("checkpatches", true)
            ));

});

void StartPacker(string os, string tag, bool debug=false, bool patch=false) 
{

    var command = "build -var-file=\"osconfig\\" + os + "\\vars.json\" -var boxtag=" + tag + " -var cm=" + cm + " "; 

    if(patch)
        command += "-var patchvm=true ";
    else
        command += "-var patchvm=false ";

    if(debug)
        command += "-debug ";

    command += " .\\packerbase.json";

    StartProcess("packer", command);
}

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