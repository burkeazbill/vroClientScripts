Param(
    [string]$usr = 'myvROUser',
    [string]$pwd = 'myPassword',
    [string]$vroServer = 'vRO-Server.domain.lab:8281', # in format FQDN:PORT
    [string]$wfid = '2a2c773d-4f34-422e-b427-eddce95669d1',
    [string]$apiFormat = 'json', # either xml or json
    [string]$inputFile = 'e:body.json'# path to input file (either json or xml)
)
#### Make no changes below this line ###############################
# Original article: http://bit.ly/powershellvco
# Usage:
# If you run the script with no parameters specified, the default values defined above will be used.
# to run with params, See following example: (Should be all one line)
# NOTE: It is not required to specify name of each parameter, but order will need to match the order in the above params section
# PS E:\> .\runWorkflow.ps1 -usr vcoadmin -pwd vcoadmin -vroServer vro-server.domain.lab:8281 -wfid 2a2c773d-4f34-422e-b427-eddce95669d1 -apiFormat json -inputFile c:\body.json
# 
# NOTE: if the path to the inputFile contains spaces, enclose it in quotes.
#
####################################################################
 
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
 
$token = ConvertTo-Base64("$($usr):$($pwd)")
$auth = "Basic $($token)"
 
$headers = @{"Authorization"=$auth;"Content-Type"="application/$($apiFormat)";"Accept"="application/$($apiFormat)"}
$body = Get-Content $inputFile -Raw
# write-output "Using body: " + $body
$URL = "https://$($vroServer)/vco/api/workflows/$($wfid)/executions"
Write-Output $URL
$ret = Invoke-WebRequest -Method Post -uri $URL -Headers $headers -body $body
$headers = $ret.Headers
ForEach ($header in $headers){
    Write-Output $header
}
