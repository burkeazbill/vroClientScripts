Param(
    [string]$user = 'myvROUser',
    [string]$pass = 'myPassword',
    [string]$vroHost = 'vRO-Server.domain.lab',
    [string]$vroPort = '8281',
    [string]$wfid = '8A8080808080808080808080808080809C8080800127197184441049b4e6c2cc2',
    [string]$apiFormat = 'json', # either xml or json
    [Parameter(Mandatory=$true)]
    [System.IO.FileInfo] $file
)

#### Make changes above this line AND Lines 56-> 61 #########################################
# Usage:
# If you run the script with no parameters specified, the default values defined above will be used.
# to run with params, See following example: (Should be all one line)
# NOTE: It is not required to specify name of each parameter, but order will need to match the order in the above params section
# PS E:\> .\runWorkflowWithMimeInput.ps1 -user vcoadmin -pass vcoadmin -vroHost vro6.demo.lab -vroPort 8281 -wfid 8A8080808080808080808080808080809C8080800127197184441049b4e6c2cc2 -apiFormat json -file C:\hol\vcd-users.csv
#
# The vcd-users.csv file and the workflow with that id (Import Users from CSV) reside with this script on Github so that you may test before 
# customizing to fit your own needs
#
#############################################################################################
 
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

function Encode-File($string){
    $Content = Get-Content -Path $string -Encoding Byte
    $encoded = [System.Convert]::ToBase64String($Content) 

    return $encoded;
}

$body = (Encode-File($file.FullName))

#### Make changes here to build your json body for the POST operation #######################
#
$json = '{"parameters": ['
$json += '{"name":"csvFile","type":"MimeAttachment","scope":"local","value": {"mime-attachment":{"name":"' + $file.Name + '","mime-type":"application/octet-stream","content":"'+$body+'"}}}'
# Modify the line above to have a comma at the end and add more input params as needed, each with a comma at the end, except for last one.
$json += ']}'
# Uncomment the next line to test your generated json, use www.jsonlint.com to validate if necessary
# Write-Output $json
#############################################################################################

$token = ConvertTo-Base64("$($user):$($pass)")

$auth = "Basic $($token)"
 
$headers = @{"Authorization"=$auth;"Content-Type"="application/$($apiFormat)";"Accept"="application/$($apiFormat)"}
# $body = Get-Content $inputFile -Raw


# write-output "Using body: " + $body
$URL = "https://$($vroHost):$($vroPort)/vco/api/workflows/$($wfid)/executions"
Write-Output $URL
$ret = Invoke-WebRequest -Method Post -uri $URL -Headers $headers -body $json
$headers = $ret.Headers
ForEach ($header in $headers){
    Write-Output $header
}
