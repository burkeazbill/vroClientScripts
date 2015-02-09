Param(
  [string]$vcoHost="localhost",
  [string]$vcoPort="8281",
  [string]$user="vcoadmin",
  [string]$pass="vcoadmin",
  [Parameter(Mandatory=$true)]
  [string]$wid='440c9173-0866-4819-b4c9-f5e15004fd4c',
  [string]$fileName=$wid + ".workflow"
)

add-type @"
    using System.Net;
    using System.Security.Cryptography.X509Certificates;
    public class TrustAllCertsPolicy : ICertificatePolicy {
        public bool CheckValidationResult(
            ServicePoint srvPoint, X509Certificate certificate,
            WebRequest request, int certificateProblem) {
            return true;
        }
    }
"@
[System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy

function ConvertTo-Base64($string) {
   $bytes  = [System.Text.Encoding]::UTF8.GetBytes($string);
   $encoded = [System.Convert]::ToBase64String($bytes); 

   return $encoded;
}


$vcoUrl = "https://$($vcoHost):$($vcoPort)/vco/api";

# Authentication token
$token = ConvertTo-Base64("$($user):$($pass)");
$auth = "Basic $($token)";

$headers = @{"Authorization"= $auth;'Accept'='Application/zip'; 'Accept-Encoding'='gzip, deflate'; };
$expWorkflowURI = "https://$($vcoHost):$($vcoPort)/vco/api/workflows/$($wid)";
$ret = Invoke-WebRequest -uri $expWorkflowURI -Headers $headers -ContentType "application/zip;charset=utf-8" -Method Get

$ret.Content | Set-Content -Path  $fileName -Encoding Byte

write-host "";
write-host "$expWorkflowURI";
write-host "Exported  to: $fileName";