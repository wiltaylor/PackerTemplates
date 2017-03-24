@echo off
DISM /Online /Enable-Feature /FeatureName:NetFx2-ServerCore
DISM /Online /Enable-Feature /FeatureName:MicrosoftWindowsPowerShell
