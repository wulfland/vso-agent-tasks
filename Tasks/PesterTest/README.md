#PowerShell on Target Machines 

### Overview
The task is used run PowerShell on the target machines. The task can run both PowerShell scripts and PowerShell-DSC scripts. For PowerShell scripts, PowerShell 2.0 is needed on the machines and for PowerShell-DSC scripts [Windows Management Framework 4.0](https://www.microsoft.com/en-in/download/details.aspx?id=40855&40ddd5bd-f9e7-49a6-3526-f86656931a02=True) needs to be installed on the machines. WMF 4.0 ships in-the-box in Windows 8.1 and Windows Server 20012 R2.

###The different parameters of the task are explained below: 

 * **Machines**: Specify comma separated list of machine FQDNs/ip addresses along with port(optional). For example dbserver.fabrikam.com, dbserver_int.fabrikam.com:5986,192.168.34:5986. Port when not specified will be defaulted to WinRM defaults based on the specified protocol. i.e., (For *WinRM 2.0*):  The default HTTP port is 5985, and the default HTTPS port is 5986. Machines field also accepts 'Machine Groups' defined under 'Test' hub, 'Machines' tab. 
 * **Admin Login**: Domain/Local administrator of the target host. Format: &lt;Domain or hostname&gt;\ &lt; Admin User&gt;. Mandatory when used with list of machines, optional for Test Machine Group (will override test machine group value when specified). 
 * **Password**:  Password for the admin login. It can accept variable defined in Build/Release definitions as '$(passwordVariable)'. You may mark variable type as 'secret' to secure it. Mandatory when used with list of machines, optional for Test Machine Group (will override test machine group value when specified). 
 * **Protocol**:  Specify the protocol that will be used to connect to target host, either HTTP or HTTPS.
 * **Test Certificate**: Select the option to skip validating the authenticity of the machine's certificate by a trusted certification authority. The parameter is required for the WinRM HTTPS protocol. 
* **PowerShell Script**: The location of the PowerShell script on the target machine like c:\FabrikamFibre\Web\deploy.ps1. Environment variables can be also used like $env:windir, $env:systemroot etc. 
* **Script Arguments**: The arguments needed by the script, if any provided in the following format -applicationPath $(applicationPath) -username $(vmusername) -password $(vmpassword). 
* **Initialization Script**: The location of the data script that is used by PowerShell-DSC and the location has to be on the target machine. It is advisable to use arguments in place of the initialization script.  
* **Session Variables**: Used for setting-up the session variables for the PowerShell scripts and the input is a comma separated list like $varx=valuex, $vary=valuey. This is mostly used for backward compatibility with the earlier versions of Release Management product and it is advisable to use arguments in place of the session variables.
* **Advanced Options**: The advanced options provide more fine-grained control on the deployment. 
* **Run PowerShell in Parallel**: Checking this option will execute the PowerShell in-parallel on all VMs in the Resource Group.  
      

### Machine Pre-requisites for the Task :


| S.NO | Target Machine State                                       | Target Machine trust with Automation agent | Machine Identity | Authentication Account | Authentication Mode | Authentication Account permission on Target Machine | Connection Type | Pre-requisites in Target machine for Deployment Task to succeed                                                                                                                                                                                                                                                                                                                                                                                                |
|------|------------------------------------------------------------|--------------------------------------------|------------------|------------------------|---------------------|-----------------------------------------------------|-----------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| 1    | Domain joined machine in Corp network                      | Trusted                                    | DNS name         | Domain account         | Kerberos            | Machine Administrator                               | WinRM HTTP      | <ul><li>WinRM HTTP port (default 5985) opened in Firewall.</li></ul>                                                                                                                                                                                                                                                                                                                                                                                           |
| 2    | Domain joined machine in Corp network                      | Trusted                                    | DNS name         | Domain account         | Kerberos            | Machine Administrator                               | WinRM HTTPS     | <ul><li>WinRM HTTPS port  (default 5986) opened in Firewall.</li><li>Trusted certificate in Automation agent.</li><li>If Trusted certificate not in Automation agent then Test certificate option enabled in Task for deployment.</li></ul>                                                                                                                                                                                                                    |
| 3    | Domain joined machine,or Workgroup machine in Corp network | Any                                        | DNS name         | Local machine account  | NTLM                | Machine Administrator                               | WinRM HTTP      | <ul><li>WinRM HTTP port (default 5985) opened in Firewall.</li><li>Disable UAC remote restrictions<a href="https://support.microsoft.com/en-us/kb/951016">(link)</a></li><li>Credential in <MachineName>\<Account> format.</li><li>Set "AllowUnencrypted" option and add remote machines in "Trusted Host" list in Automation Agent<a href="https://msdn.microsoft.com/en-us/library/aa384372(v=vs.85).aspx">(link)</a></li></ul>                              |
| 4    | Domain joined machine or Workgroup machine,in Corp network | Any                                        | DNS name         | Local machine account  | NTLM                | Machine Administrator                               | WinRM HTTPS     | <ul><li>WinRM HTTPS port  (default 5986) opened in Firewall.</li><li>Disable UAC remote restrictions<a href="https://support.microsoft.com/en-us/kb/951016">(link)</a></li><li>Credential in <MachineName>\<Account> format.</li><li>Trusted certificate in Automation agent.</li><li>If Trusted certificate not in Automation agent then Test Certificate option enabled in Task for deployment.</li></ul>                                                    |
| 5    | Workgroup machine in Azure                                 | Un Trusted                                 | DNS name         | Local machine account  | NTLM                | Machine Administrator                               | WinRM HTTP      | <ul><li>WinRM HTTP port (default 5985) opened in Firewall.</li><li>Disable UAC remote restrictions<a href="https://support.microsoft.com/en-us/kb/951016">(link)</a></li><li>Credential in <MachineName>\<Account> format.</li><li>Set "AllowUnencrypted" option and add remote machines in "Trusted Host" list in Automation Agent<a href="https://msdn.microsoft.com/en-us/library/aa384372(v=vs.85).aspx">(link)</a></li></ul>                              |
| 6    | Workgroup machine in Azure                                 | Un Trusted                                 | DNS name         | Local machine account  | NTLM                | Machine Administrator                               | WinRM HTTPS     | <ul><li>WinRM HTTPS port  (default 5986) opened in Firewall.</li><li>Disable UAC remote restrictions<a href="https://support.microsoft.com/en-us/kb/951016">(link)</a></li><li>Credential in <MachineName>\<Account> format.</li><li>Trusted certificate in Automation agent.</li><li>If Trusted certificate not in Automation agent then Test Certificate option enabled in Task for deployment.</li></ul>                                                    |
| 7    | Any                                                        | Any                                        | IP address       | Any                    | NTLM                | Machine Administrator                               | WinRM HTTP      | <ul><li>WinRM HTTP port (default 5985) opened in Firewall.</li><li>Disable UAC remote restrictions<a href="https://support.microsoft.com/en-us/kb/951016">(link)</a></li><li>Credential in <MachineName>\<Account> format.</li><li>Set "AllowUnencrypted" option and add remote machines in "Trusted Host" list in Automation Agent<a href="https://msdn.microsoft.com/en-us/library/aa384372(v=vs.85).aspx">(link)</a></li></ul>                              |
| 8    | Any                                                        | Any                                        | IP address       | Any                    | NTLM                | Machine Administrator                               | WinRM HTTPS     | <ul><li>WinRM HTTPS port  (default 5986) opened in Firewall.</li><li>Disable UAC remote restrictions<a href="https://support.microsoft.com/en-us/kb/951016">(link)</a></li><li>Credential in <MachineName>\<Account> format.</li><li>Trusted certificate in Automation agent.</li><li>If Trusted certificate not in Automation agent then Test Certificate option enabled in Task for deployment.</li></ul>                                                    |

### Known Issues :

Write-Host command is not supported in PowerShell script.