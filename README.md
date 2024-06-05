# Powershell Collection
Various Powershell scripts that I use for my daily work in the storage and SAN environment. Mainly written for pwsh7 but most of them should also work with 5.1.

How to install

download the package here and place it in an area of your choice and unzip it.
After it is unziped open a Powershell window and navigate to the gui directory.
Example:
```powershell
PowerShell 7.4.2
PS C:\Users\mailt> cd D:\ps_collection-main\ps_collection-main\GUI\
```
You can start the GUi by calling the following *ps1 file.
Example:
```powershell
PS D:\ps_collection-main\ps_collection-main\GUI> .\GUI_Control.ps1
```
Depending on the powershell settings, you may have to answer the warnings with "r", as shown in the picture
<img width="1821" alt="image" src="https://github.com/DocCLF/ps_collection/assets/9890682/d76a4e7b-21e6-45b9-8c2b-1925c0c74d20">

At the end you should see this small window.
<img width="1027" alt="image" src="https://github.com/DocCLF/ps_collection/assets/9890682/36551463-28ea-4b26-b438-5bd17f6111ef">

When you click on drive-info, for example, the function is called in the background and you only need to enter the user name, IP address etc., just like before.
The window is only intended to free you from having to call up the files every time. 
To exit, either click on exit or close the powershell window.
<img width="1338" alt="image" src="https://github.com/DocCLF/ps_collection/assets/9890682/d9157da8-6d55-41ab-b6c1-d1e3a85edb77">


Attention, the Expand_Volume and Vdisk files are currently not supported, you can use them by calling them normally in the Powershell window.
Example:
```powershell
PowerShell 7.4.2
PS C:\Users\mailt> D:\ps_collection-main\ps_collection-main\IBM_Expand_HyperswapVolume.ps1
```
or for non-HyperSwap
```powershell
PowerShell 7.4.2
PS C:\Users\mailt> D:\ps_collection-main\ps_collection-main\IBM_Expand_VdiskSize.ps1
```
