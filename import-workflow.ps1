Param(
  [string]$vroHost="localhost",
  [string]$vroPort="8281",
  [string]$user="vcoadmin",
  [string]$pass="vcoadmin",
  [Parameter(Mandatory=$true)]
  [string]$categoryId,
  [Parameter(Mandatory=$true)]
  [System.IO.FileInfo] $file
 
)

#### Make no changes below this line ###############################
# Usage:
# If you run the script with no parameters specified, the default values defined above will be used.
# to run with params, See following example: (Should be all one line)
# NOTE: It is not required to specify name of each parameter, but order will need to match the order in the above params section
# Use quotes for values in the following example when the value includes a space
# PS C:\> ./import-workflow.ps1 -vroHost vro6.demo.lab -vroPort 8281 -user vcoadmin -pass vcoadmin -categoryId PASTE-CATEGORYID-HERE -file "c:\workflows\test import.workflow"
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
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        
[byte[]]$CRLF = 13, 10

function Get-AsciiBytes([String] $str) {
    return [System.Text.Encoding]::ASCII.GetBytes($str)            
}

function ConvertTo-Base64($string) {
   $bytes  = [System.Text.Encoding]::UTF8.GetBytes($string);
   $encoded = [System.Convert]::ToBase64String($bytes); 

   return $encoded;
}

    
$body = New-Object System.IO.MemoryStream

$method = 'POST'
$boundary = [Guid]::NewGuid().ToString().Replace('-','')
$ContentType = 'multipart/form-data; boundary=' + $boundary
$b2 = Get-AsciiBytes ('--' + $boundary)
$body.Write($b2, 0, $b2.Length)
$body.Write($CRLF, 0, $CRLF.Length)
            
$b = (Get-AsciiBytes ('Content-Disposition: form-data; name="categoryId"'))
$body.Write($b, 0, $b.Length)

$body.Write($CRLF, 0, $CRLF.Length)
$body.Write($CRLF, 0, $CRLF.Length)
            
$b = (Get-AsciiBytes $categoryId)
$body.Write($b, 0, $b.Length)

$body.Write($CRLF, 0, $CRLF.Length)
$body.Write($b2, 0, $b2.Length)
$body.Write($CRLF, 0, $CRLF.Length)
            
$b = (Get-AsciiBytes ('Content-Disposition: form-data; name="file"; filename="$($file.Name)";'))
$body.Write($b, 0, $b.Length)
$body.Write($CRLF, 0, $CRLF.Length)            
$b = (Get-AsciiBytes 'Content-Type:application/octet-stream')
$body.Write($b, 0, $b.Length)
            
$body.Write($CRLF, 0, $CRLF.Length)
$body.Write($CRLF, 0, $CRLF.Length)
            
$b = [System.IO.File]::ReadAllBytes($file.FullName)
$body.Write($b, 0, $b.Length)

$body.Write($CRLF, 0, $CRLF.Length)
$body.Write($b2, 0, $b2.Length)
            
$b = (Get-AsciiBytes '--');
$body.Write($b, 0, $b.Length);
            
$body.Write($CRLF, 0, $CRLF.Length);
            
             

# Authentication token
$token = ConvertTo-Base64("$($user):$($pass)");
$auth = "Basic $($token)";

#request URL
$impUrl = "https://$($vroHost):$($vroPort)/vco/api/workflows?categoryId=$($categoryId)&overwrite=true";
$header = @{"Authorization"= $auth;
            "Accept"= "application/json";
            "Accept-Encoding"= "gzip,deflate,sdch";};                

$impUrl
Invoke-RestMethod -Method $method -Uri $impUrl -ContentType $ContentType -Body $body.ToArray() -Headers $header
